// SurveyStore.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class SurveyStore: ObservableObject {
    @Published var availableSurveys: [SurveyModel] = []
    @Published var surveyProgressStates: [String: SurveyProgress] = [:]
    @Published var aggregatedSurveyResults: [String: [Int: [String: Int]]] = [:]
    @Published var completedSurveyIds: Set<String> = []

    private let db = Firestore.firestore()
    private var listenerRegistrations: [String: ListenerRegistration] = [:]

    init() {
        initializeUserData()
        // uploadTestSurveys() now triggered manually via UI
    }

    deinit {
        listenerRegistrations.values.forEach { $0.remove() }
    }

    // MARK: - Initialization

    func initializeUserData() {
        guard let user = Auth.auth().currentUser else {
            print("❌ No authenticated user.")
            return
        }

        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Failed to load user metadata: \(error.localizedDescription)")
                return
            }

            if snapshot?.exists == false {
                let newUserData: [String: Any] = [
                    "email": user.email ?? "",
                    "displayName": user.email?.components(separatedBy: "@").first ?? "User",
                    "tags": ["general"],
                    "completedSurveys": [],
                    "ongoingSurveys": [:]
                ]
                self?.db.collection("users").document(user.uid).setData(newUserData)
            }

            self?.loadSurveyProgress()
            self?.loadSurveys()
        }
    }

    // MARK: - Load Surveys

    func loadSurveys() {
        db.collection("surveys").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error loading surveys: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("❌ No surveys found.")
                return
            }

            let now = Date()

            let surveys: [SurveyModel] = documents.compactMap { doc in
                let data = doc.data()
                guard let title = data["title"] as? String,
                      let questionsRaw = data["questions"] as? [[String: Any]] else { return nil }

                let image = data["image"] as? String ?? "doc.text"
                let tags = data["tags"] as? [String] ?? []
                let description = data["description"] as? String
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
                let startTime = (data["startTime"] as? Timestamp)?.dateValue() ?? Date.distantPast
                let endTime = (data["endTime"] as? Timestamp)?.dateValue() ?? Date.distantFuture

                guard startTime <= now && endTime >= now else { return nil }

                let questions = questionsRaw.compactMap { q -> QuestionModel? in
                    guard let text = q["text"] as? String,
                          let options = q["options"] as? [String],
                          let typeRaw = q["type"] as? String,
                          let type = QuestionType(rawValue: typeRaw) else { return nil }
                    return QuestionModel(text: text, options: options, type: type)
                }

                return SurveyModel(
                    id: doc.documentID,
                    title: title,
                    image: image,
                    questions: questions,
                    tags: tags,
                    description: description,
                    createdAt: createdAt,
                    startTime: startTime,
                    endTime: endTime
                )
            }

            DispatchQueue.main.async {
                self?.availableSurveys = surveys
                self?.beginLiveResultsSync()
            }
        }
    }

    // MARK: - Live Results Sync

    func beginLiveResultsSync() {
        for survey in availableSurveys {
            beginLiveResultsSyncForSurvey(survey.id, questionCount: survey.questions.count)
        }
    }

    func beginLiveResultsSyncForSurvey(_ surveyId: String, questionCount: Int) {
        for index in 0..<questionCount {
            let path = "surveyResponses/\(surveyId)/questions/\(index)/answers"
            if listenerRegistrations[path] != nil { continue }

            let listener = db.collection("surveyResponses")
                .document(surveyId)
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

    // MARK: - Save Progress

    func saveProgress(surveyId: String, progress: SurveyProgress) {
        guard let user = Auth.auth().currentUser else { return }

        let answersWithStringKeys: [String: String] = progress.selectedAnswers.reduce(into: [:]) { dict, pair in
            dict["\(pair.key)"] = pair.value
        }

        let data: [String: Any] = [
            "currentQuestionIndex": progress.currentQuestionIndex,
            "selectedAnswers": answersWithStringKeys,
            "isCompleted": progress.isCompleted,
            "lastUpdated": FieldValue.serverTimestamp()
        ]

        db.collection("users")
            .document(user.uid)
            .setData(["ongoingSurveys.\(surveyId)": data], merge: true)

        DispatchQueue.main.async {
            self.surveyProgressStates[surveyId] = progress
        }
    }

    // MARK: - Submit Survey

    func submitSurvey(surveyId: String, answers: [Int: String]) {
        guard let user = Auth.auth().currentUser else { return }

        let answerStringKeys = answers.reduce(into: [:]) { dict, pair in
            dict["\(pair.key)"] = pair.value
        }

        let responseRef = db.collection("surveyResponses")
            .document(surveyId)
            .collection("responses")
            .document(user.uid)

        let userRef = db.collection("users").document(user.uid)

        db.runTransaction({ transaction, errorPointer in
            transaction.setData([
                "userId": user.uid,
                "answers": answerStringKeys,
                "completed": true,
                "submittedAt": FieldValue.serverTimestamp()
            ], forDocument: responseRef)

            transaction.updateData([
                "completedSurveys": FieldValue.arrayUnion([surveyId]),
                "ongoingSurveys.\(surveyId)": FieldValue.delete()
            ], forDocument: userRef)

            return nil
        }) { [weak self] _, error in
            if let error = error {
                print("❌ Transaction error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.completedSurveyIds.insert(surveyId)
                    self?.surveyProgressStates[surveyId] = SurveyProgress(currentQuestionIndex: 0, selectedAnswers: answers, isCompleted: true)
                    print("✅ Submitted survey \(surveyId)")
                }
            }
        }
    }

    // MARK: - Mark Survey as Expired

    func markSurveyAsExpired(surveyId: String) {
        DispatchQueue.main.async {
            self.availableSurveys.removeAll { $0.id == surveyId }
            self.completedSurveyIds.insert(surveyId)
            self.surveyProgressStates[surveyId] = SurveyProgress(isCompleted: true)
            print("🕒 Survey \(surveyId) auto-marked as expired")
        }

        guard let user = Auth.auth().currentUser else { return }
        db.collection("users").document(user.uid).updateData([
            "completedSurveys": FieldValue.arrayUnion([surveyId]),
            "ongoingSurveys.\(surveyId)": FieldValue.delete()
        ])
    }

    // MARK: - Reset Store

    func resetStore() {
        DispatchQueue.main.async {
            self.availableSurveys = []
            self.surveyProgressStates = [:]
            self.aggregatedSurveyResults = [:]
            self.completedSurveyIds = []
            self.listenerRegistrations.values.forEach { $0.remove() }
            self.listenerRegistrations = [:]
        }
    }

    // MARK: - Load Progress

    func loadSurveyProgress() {
        guard let user = Auth.auth().currentUser else { return }

        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Failed to load user progress: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else { return }

            var restored: [String: SurveyProgress] = [:]

            if let rawOngoing = data["ongoingSurveys"] as? [String: [String: Any]] {
                for (surveyId, item) in rawOngoing {
                    let idx = item["currentQuestionIndex"] as? Int ?? 0
                    let rawAnswers = item["selectedAnswers"] as? [String: String] ?? [:]
                    let isCompleted = item["isCompleted"] as? Bool ?? false

                    let answers = rawAnswers.compactMapKeys { Int($0) }

                    restored[surveyId] = SurveyProgress(
                        currentQuestionIndex: idx,
                        selectedAnswers: answers,
                        isCompleted: isCompleted
                    )
                }
            }

            if let completed = data["completedSurveys"] as? [String] {
                for surveyId in completed {
                    self?.completedSurveyIds.insert(surveyId)
                    if restored[surveyId] == nil {
                        restored[surveyId] = SurveyProgress(isCompleted: true)
                    }
                }
            }

            DispatchQueue.main.async {
                self?.surveyProgressStates = restored
                print("✅ Loaded \(restored.count) ongoing/completed surveys")
            }
        }
    }

    // MARK: - Survey Deletion by Tag

    func deleteSurveys(withTag tag: String) {
        db.collection("surveys")
            .whereField("tags", arrayContains: tag)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching surveys for deletion: \(error.localizedDescription)")
                    return
                }

                let batch = self.db.batch()
                snapshot?.documents.forEach { doc in
                    batch.deleteDocument(doc.reference)
                }

                batch.commit { err in
                    if let err = err {
                        print("❌ Failed to delete surveys: \(err.localizedDescription)")
                    } else {
                        print("🗑️ Deleted all surveys with tag \(tag)")
                        DispatchQueue.main.async {
                            self.loadSurveys()
                        }
                    }
                }
            }
    }

    // MARK: - Upload Test Surveys

    func uploadTestSurveys() {
        db.collection("surveys")
            .whereField("tags", arrayContains: "MOCK_TEST")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error fetching old mock surveys: \(error.localizedDescription)")
                    return
                }

                let batch = self.db.batch()
                snapshot?.documents.forEach { doc in
                    batch.deleteDocument(doc.reference)
                }

                batch.commit { err in
                    if let err = err {
                        print("❌ Failed to delete old mock surveys: \(err.localizedDescription)")
                    } else {
                        print("🧹 Cleared old mock surveys")
                        self.createAndUploadTestSurveys()
                    }
                }
            }
    }

    private func createAndUploadTestSurveys() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let start1 = formatter.date(from: "2025-06-12T12:00:00Z")!
        let end1 = formatter.date(from: "2025-06-12T14:00:00Z")!
        let start2 = formatter.date(from: "2025-06-13T10:00:00Z")!
        let end2 = formatter.date(from: "2025-06-14T23:59:00Z")!
        let start3 = formatter.date(from: "2025-06-20T08:00:00Z")!
        let end3 = formatter.date(from: "2025-06-21T17:00:00Z")!

        let testSurveys: [SurveyModel] = [
            SurveyModel(
                id: UUID().uuidString,
                title: "Physics Timed Quiz",
                image: "atom",
                questions: [
                    QuestionModel(text: "What is Newton’s 2nd law?", options: [], type: .freeResponse),
                    QuestionModel(text: "Speed of light?", options: ["3x10^8 m/s", "1x10^6 m/s"], type: .multipleChoice)
                ],
                tags: ["STEM", "MOCK_TEST"],
                description: "A quick timed quiz on basic physics.",
                createdAt: Date(),
                startTime: start1,
                endTime: end1
            ),
            SurveyModel(
                id: UUID().uuidString,
                title: "Business Vocabulary",
                image: "briefcase",
                questions: [
                    QuestionModel(text: "Define 'market capitalization'.", options: [], type: .freeResponse),
                    QuestionModel(text: "A stock split causes?", options: ["Price falls", "Price rises"], type: .multipleChoice)
                ],
                tags: ["Business", "MOCK_TEST"],
                description: "Short test on business terms.",
                createdAt: Date(),
                startTime: start2,
                endTime: end2
            ),
            SurveyModel(
                id: UUID().uuidString,
                title: "Leadership Principles",
                image: "person.3.sequence",
                questions: [
                    QuestionModel(text: "What is the most important trait in a leader?", options: [], type: .freeResponse),
                    QuestionModel(text: "Which of these is NOT a leadership quality?", options: ["Vision", "Indecisiveness", "Empathy"], type: .multipleChoice)
                ],
                tags: ["Leadership", "MOCK_TEST"],
                description: "Explore leadership behaviors and decision making.",
                createdAt: Date(),
                startTime: start3,
                endTime: end3
            )
        ]

        for survey in testSurveys {
            let surveyDict: [String: Any] = [
                "title": survey.title,
                "image": survey.image,
                "tags": survey.tags,
                "description": survey.description ?? "",
                "createdAt": FieldValue.serverTimestamp(),
                "startTime": Timestamp(date: survey.startTime),
                "endTime": Timestamp(date: survey.endTime),
                "questions": survey.questions.map { q in
                    [
                        "text": q.text,
                        "options": q.options,
                        "type": q.type.rawValue
                    ]
                }
            ]

            db.collection("surveys").document(survey.id).setData(surveyDict) { error in
                if let error = error {
                    print("❌ Error uploading survey \(survey.title): \(error.localizedDescription)")
                } else {
                    print("✅ Uploaded survey: \(survey.title)")
                }
            }
        }
    }
}

// MARK: - Supporting Models

enum QuestionType: String, Codable {
    case multipleChoice
    case freeResponse
}

struct SurveyModel: Identifiable, Codable {
    let id: String
    let title: String
    let image: String
    let questions: [QuestionModel]
    let tags: [String]
    let description: String?
    let createdAt: Date?
    let startTime: Date
    let endTime: Date
}

struct QuestionModel: Codable {
    let text: String
    let options: [String]
    let type: QuestionType
}
struct SurveyProgress: Codable {
    var currentQuestionIndex: Int = 0
    var selectedAnswers: [Int: String] = [:]
    var isCompleted: Bool = false
    var progress: Int {
        selectedAnswers.count
    }
}

extension Dictionary {
    func compactMapKeys<T: Hashable>(_ transform: (Key) throws -> T?) rethrows -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            if let newKey = try transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}
