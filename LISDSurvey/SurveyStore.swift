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
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error loading user for survey filtering: \(error.localizedDescription)")
                return
            }
            
            let userTags = (snapshot?.data()?["tags"] as? [String]) ?? []
            let userTagSet = Set(userTags)
            
            self?.db.collection("surveys").getDocuments { snapshot, error in
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
                    guard tags.isEmpty || !Set(tags).isDisjoint(with: userTagSet) else { return nil }
                    
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
    
    // MARK: - Submit Survey  ✅ UPDATED
    func submitSurvey(surveyId: String, answers: [Int: String]) {
        guard let user = Auth.auth().currentUser else { return }

        // 1. Build a WriteBatch so all writes commit together
        let batch = db.batch()

        // ── A) Per-survey “responses/{userId}” document (kept for history) ─────────────
        let responseRef = db.collection("surveyResponses")
            .document(surveyId)
            .collection("responses")
            .document(user.uid)

        let answerStringKeys = answers.reduce(into: [:]) { dict, pair in
            dict["\(pair.key)"] = pair.value
        }

        batch.setData([
            "userId": user.uid,
            "answers": answerStringKeys,
            "completed": true,
            "submittedAt": FieldValue.serverTimestamp()
        ], forDocument: responseRef)

        // ── B) Per-question “questions/{idx}/answers/{userId}” docs used by the live-results listener ──
        for (questionIdx, selectedOption) in answers {
            let answerDoc = db.collection("surveyResponses")
                .document(surveyId)
                .collection("questions")
                .document("\(questionIdx)")
                .collection("answers")
                .document(user.uid)

            batch.setData([
                "option": selectedOption,
                "timestamp": FieldValue.serverTimestamp()
            ], forDocument: answerDoc)
        }

        // ── C) Update the user’s metadata (completed + remove from ongoing) ───────────
        let userRef = db.collection("users").document(user.uid)
        batch.updateData([
            "completedSurveys": FieldValue.arrayUnion([surveyId]),
            "ongoingSurveys.\(surveyId)": FieldValue.delete()
        ], forDocument: userRef)

        // 2. Commit the batch
        batch.commit { [weak self] error in
            if let error = error {
                print("❌ Batch commit error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.completedSurveyIds.insert(surveyId)
                    self?.surveyProgressStates[surveyId] = SurveyProgress(
                        currentQuestionIndex: 0,
                        selectedAnswers: answers,
                        isCompleted: true
                    )
                    print("✅ Submitted survey \(surveyId) & wrote answers for live results")
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
            
            // Load ongoing surveys
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
            
            // Load completed surveys
            if let completed = data["completedSurveys"] as? [String] {
                for surveyId in completed {
                    self?.completedSurveyIds.insert(surveyId)
                    if restored[surveyId] == nil {
                        restored[surveyId] = SurveyProgress(isCompleted: true)
                    } else {
                        restored[surveyId]?.isCompleted = true
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
      
      // MARK: - Internal helper to push canned surveys
      private func createAndUploadTestSurveys() {
          let formatter = ISO8601DateFormatter()
          formatter.formatOptions = [.withInternetDateTime]
          
          // Existing test windows
          let start1 = formatter.date(from: "2025-06-12T12:00:00Z")!
          let end1   = formatter.date(from: "2025-06-12T14:00:00Z")!
          let start2 = formatter.date(from: "2025-06-15T10:00:00Z")!
          let end2   = formatter.date(from: "2025-06-16T23:59:00Z")!
          let start3 = formatter.date(from: "2025-06-15T08:00:00Z")!
          let end3   = formatter.date(from: "2025-06-18T17:00:00Z")!
          
          // New school‑routine survey window (available immediately for 30 days)
          let start4 = Date()
          let end4   = Calendar.current.date(byAdding: .day, value: 30, to: start4)!
          
          let testSurveys: [SurveyModel] = [
              // Physics Timed Quiz
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
                  startTime: start3,
                  endTime: end2
              ),
              // Business Vocabulary
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
              // Leadership Principles
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
              ),
              // 🆕 School Routine Survey ‑ all multiple‑choice
              SurveyModel(
                  id: UUID().uuidString,
                  title: "School Routine Survey",
                  image: "building.columns",
                  questions: [
                      QuestionModel(
                          text: "How many school days are in a typical week at your school?",
                          options: ["3 days", "4 days", "5 days", "6 days"],
                          type: .multipleChoice
                      ),
                      QuestionModel(
                          text: "Which part of the day do you feel most productive for learning?",
                          options: ["Early morning (before 9 AM)", "Mid‑morning (9–11 AM)", "Early afternoon (12–2 PM)", "Late afternoon (after 2 PM)"],
                          type: .multipleChoice
                      ),
                      QuestionModel(
                          text: "How long is your average lunch break?",
                          options: ["30 minutes", "45 minutes", "60 minutes", "More than 60 minutes"],
                          type: .multipleChoice
                      ),
                      QuestionModel(
                          text: "How many homework assignments do you typically receive each week?",
                          options: ["0–1", "2–3", "4–5", "6 or more"],
                          type: .multipleChoice
                      )
                  ],
                  tags: ["School", "MOCK_TEST"],
                  description: "Help us understand typical school routines and workloads.",
                  createdAt: Date(),
                  startTime: start2,
                  endTime: end2
              )
          ]
          
          // Upload each survey
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
    

