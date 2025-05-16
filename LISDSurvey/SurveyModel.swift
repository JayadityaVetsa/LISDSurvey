import Foundation

struct Survey: Identifiable, Codable {
    let id = UUID()
    let title: String
    let image: String
    let questions: [Question]
    
    var totalQuestions: Int { questions.count }
}

struct Question: Codable {
    let text: String
    let options: [String]
}

// Persistence Layer
class SurveyStore: ObservableObject {
    @Published var allSurveys: [Survey] = []
    @Published var surveyStates: [UUID: SurveyState] = [:]
    
    init() {
        loadSurveys()
        loadStates()
    }
    
    private func loadSurveys() {
        allSurveys = [
            Survey(
                title: "Food Habits",
                image: "leaf",
                questions: [
                    Question(
                        text: "How often do you eat vegetables?",
                        options: ["Daily", "Weekly", "Occasionally", "Never"]
                    ),
                    Question(
                        text: "Preferred cooking method?",
                        options: ["Baking", "Frying", "Steaming", "Raw"]
                    )
                ]
            ),
            Survey(
                title: "Travel Preferences",
                image: "car",
                questions: [
                    Question(
                        text: "How often do you travel?",
                        options: ["Weekly", "Monthly", "Yearly", "Never"]
                    )
                ]
            ),
            // Additional surveys
            Survey(
                title: "Fitness Routine",
                image: "dumbbell",
                questions: [
                    Question(
                        text: "How often do you exercise?",
                        options: ["Daily", "3x/week", "Weekly", "Never"]
                    ),
                    Question(
                        text: "Preferred workout type?",
                        options: ["Cardio", "Strength", "Flexibility", "Sports"]
                    )
                ]
            )
        ]
    }
    
    private func loadStates() {
        if let data = UserDefaults.standard.data(forKey: "surveyStates"),
           let states = try? JSONDecoder().decode([UUID: SurveyState].self, from: data) {
            surveyStates = states
        }
    }
    
    func saveStates() {
        if let data = try? JSONEncoder().encode(surveyStates) {
            UserDefaults.standard.set(data, forKey: "surveyStates")
        }
    }
}

struct SurveyState: Codable {
    var currentQuestionIndex: Int = 0
    var selectedAnswers: [Int: String] = [:]
    var isCompleted: Bool = false
    
    var progress: Int {
        selectedAnswers.count
    }
}
