//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//
//struct Survey: Identifiable, Codable {
//    let id: UUID
//    let title: String
//    let image: String
//    let questions: [Question]
//
//    var totalQuestions: Int { questions.count }
//
//    init(id: UUID = UUID(), title: String, image: String, questions: [Question]) {
//        self.id = id
//        self.title = title
//        self.image = image
//        self.questions = questions
//    }
//}
//
//struct Question: Codable {
//    let text: String
//    let options: [String]
//}
//
//struct SurveyState: Codable {
//    var currentQuestionIndex: Int = 0
//    var selectedAnswers: [Int: String] = [:]
//    var isCompleted: Bool = false
//
//    var progress: Int {
//        selectedAnswers.count
//    }
//}
//
//class SurveyStore: ObservableObject {
//    @Published var allSurveys: [Survey] = []
//    @Published var surveyStates: [UUID: SurveyState] = [:]
//    @Published var userCompletionStatus: [String: [UUID: SurveyState]] = [:]
//
//    init() {
//        loadSurveys()
//        loadStates()
//    }
//
//    private func loadSurveys() {
//        allSurveys = [
//            Survey(
//                title: "Food Habits",
//                image: "leaf",
//                questions: [
//                    Question(
//                        text: "How often do you eat vegetables?",
//                        options: ["Daily", "Weekly", "Occasionally", "Never"]
//                    ),
//                    Question(
//                        text: "Preferred cooking method?",
//                        options: ["Baking", "Frying", "Steaming", "Raw"]
//                    )
//                ]
//            ),
//            Survey(
//                title: "Travel Preferences",
//                image: "car",
//                questions: [
//                    Question(
//                        text: "How often do you travel?",
//                        options: ["Weekly", "Monthly", "Yearly", "Never"]
//                    )
//                ]
//            ),
//            Survey(
//                title: "Fitness Routine",
//                image: "dumbbell",
//                questions: [
//                    Question(
//                        text: "How often do you exercise?",
//                        options: ["Daily", "3x/week", "Weekly", "Never"]
//                    ),
//                    Question(
//                        text: "Preferred workout type?",
//                        options: ["Cardio", "Strength", "Flexibility", "Sports"]
//                    )
//                ]
//            )
//        ]
//    }
//
//    private func loadStates() {
//        if let data = UserDefaults.standard.data(forKey: "surveyStates"),
//           let states = try? JSONDecoder().decode([UUID: SurveyState].self, from: data) {
//            surveyStates = states
//        }
//    }
//
//    func saveStates() {
//        if let data = try? JSONEncoder().encode(surveyStates) {
//            UserDefaults.standard.set(data, forKey: "surveyStates")
//        }
//    }
//
//    func updateUserCompletionStatus(for userId: String, surveyID: UUID, state: SurveyState) {
//        if userCompletionStatus[userId] == nil {
//            userCompletionStatus[userId] = [:]
//        }
//        userCompletionStatus[userId]?[surveyID] = state
//    }
//
//    func loadUserCompletionsFromFirestore() {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        let db = Firestore.firestore()
//        let userDoc = db.collection("userCompletions").document(userId)
//
//        userDoc.getDocument { snapshot, error in
//            guard let data = snapshot?.data() else { return }
//            var newStatus: [UUID: SurveyState] = [:]
//
//            for (key, value) in data {
//                guard let uuid = UUID(uuidString: key),
//                      let dict = value as? [String: Any],
//                      let isCompleted = dict["isCompleted"] as? Bool,
//                      let answers = dict["selectedAnswers"] as? [String: String] else { continue }
//
//                let decodedAnswers = answers.compactMapValues { $0 }
//                let intKeyedAnswers = decodedAnswers.compactMapKeys { Int($0) }
//                let state = SurveyState(currentQuestionIndex: 0, selectedAnswers: intKeyedAnswers, isCompleted: isCompleted)
//                newStatus[uuid] = state
//            }
//
//            DispatchQueue.main.async {
//                self.userCompletionStatus[userId] = newStatus
//            }
//        }
//    }
//}
//
//extension Dictionary {
//    func compactMapKeys<T>(_ transform: (Key) throws -> T?) rethrows -> [T: Value] where T: Hashable {
//        var result: [T: Value] = [:]
//        for (key, value) in self {
//            if let newKey = try transform(key) {
//                result[newKey] = value
//            }
//        }
//        return result
//    }
//}
