import Foundation
import FirebaseFirestore
import Combine
import FirebaseAuth

class SurveyStore: ObservableObject {
    @Published var availableSurveys: [SurveyModel] = []
    @Published var surveyProgressStates: [UUID: SurveyProgress] = [:]
    @Published var userSurveyCompletion: [String: [UUID: SurveyProgress]] = [:]
    @Published var aggregatedSurveyResults: [UUID: [Int: [String: Int]]] = [:]

    private var db = Firestore.firestore()
    private var listenerRegistrations: [String: ListenerRegistration] = [:]

    init() {
        loadLocalSurveys()
        restoreProgressFromDefaults()
        loadUserCompletionsFromFirestore()
        beginLiveResultsSyncForAllSurveys()
    }

    deinit {
        listenerRegistrations.values.forEach { $0.remove() }
    }

    private func loadLocalSurveys() {
        availableSurveys = [
            SurveyModel(
                title: "Food Habits",
                image: "leaf",
                questions: [
                    QuestionModel(text: "How often do you eat vegetables?", options: ["Daily", "Weekly", "Occasionally", "Never"]),
                    QuestionModel(text: "Preferred cooking method?", options: ["Baking", "Frying", "Steaming", "Raw"])
                ]
            ),
            SurveyModel(
                title: "Travel Preferences",
                image: "car",
                questions: [
                    QuestionModel(text: "How often do you travel?", options: ["Weekly", "Monthly", "Yearly", "Never"])
                ]
            ),
            SurveyModel(
                title: "Fitness Routine",
                image: "dumbbell",
                questions: [
                    QuestionModel(text: "How often do you exercise?", options: ["Daily", "3x/week", "Weekly", "Never"]),
                    QuestionModel(text: "Preferred workout type?", options: ["Cardio", "Strength", "Flexibility", "Sports"])
                ]
            )
        ]
    }

    private func restoreProgressFromDefaults() {
        if let data = UserDefaults.standard.data(forKey: "surveyProgressStates"),
           let states = try? JSONDecoder().decode([UUID: SurveyProgress].self, from: data) {
            surveyProgressStates = states
        }
    }

    func persistProgress() {
        if let data = try? JSONEncoder().encode(surveyProgressStates) {
            UserDefaults.standard.set(data, forKey: "surveyProgressStates")
        }
    }

    func logUserCompletion(userId: String, surveyId: UUID, progress: SurveyProgress) {
        if userSurveyCompletion[userId] == nil {
            userSurveyCompletion[userId] = [:]
        }
        userSurveyCompletion[userId]?[surveyId] = progress
    }

    func loadUserCompletionsFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("userCompletions")
            .document(userId)
            .collection("surveys")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }

                var completions: [UUID: SurveyProgress] = [:]

                for doc in documents {
                    guard let uuid = UUID(uuidString: doc.documentID) else { continue }
                    let data = doc.data()
                    let isCompleted = data["isCompleted"] as? Bool ?? false
                    let answers = data["selectedAnswers"] as? [String: String] ?? [:]
                    let convertedAnswers = answers.compactMapKeys { Int($0) }

                    completions[uuid] = SurveyProgress(
                        currentQuestionIndex: 0,
                        selectedAnswers: convertedAnswers,
                        isCompleted: isCompleted
                    )
                }

                DispatchQueue.main.async {
                    self.userSurveyCompletion[userId] = completions
                }
            }
    }

    func beginLiveResultsSyncForAllSurveys() {
        for survey in availableSurveys {
            listenToSurveyResponses(for: survey.id, questionCount: survey.questions.count)
        }
    }

    private func listenToSurveyResponses(for surveyId: UUID, questionCount: Int) {
        for index in 0..<questionCount {
            let path = "surveyResponses/\(surveyId.uuidString)/questions/\(index)/answers"
            if listenerRegistrations[path] != nil { continue }

            let listener = db.collection("surveyResponses")
                .document(surveyId.uuidString)
                .collection("questions")
                .document("\(index)")
                .collection("answers")
                .addSnapshotListener { [weak self] snapshot, _ in
                    guard let self = self, let snapshot = snapshot else { return }

                    var counts: [String: Int] = [:]
                    for doc in snapshot.documents {
                        if let option = doc.data()["option"] as? String {
                            counts[option, default: 0] += 1
                        }
                    }

                    DispatchQueue.main.async {
                        if self.aggregatedSurveyResults[surveyId] == nil {
                            self.aggregatedSurveyResults[surveyId] = [:]
                        }
                        self.aggregatedSurveyResults[surveyId]?[index] = counts
                    }
                }

            listenerRegistrations[path] = listener
        }
    }
}

extension Dictionary {
    func compactMapKeys<T>(_ transform: (Key) throws -> T?) rethrows -> [T: Value] where T: Hashable {
        var result: [T: Value] = [:]
        for (key, value) in self {
            if let newKey = try transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}

struct SurveyModel: Identifiable, Codable {
    let id = UUID()
    let title: String
    let image: String
    let questions: [QuestionModel]
}

struct QuestionModel: Codable {
    let text: String
    let options: [String]
}

struct SurveyProgress: Codable {
    var currentQuestionIndex: Int = 0
    var selectedAnswers: [Int: String] = [:]
    var isCompleted: Bool = false

    var progress: Int {
        selectedAnswers.count
    }
}
