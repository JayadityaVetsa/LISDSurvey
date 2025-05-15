import Foundation

struct Survey: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let questions: [Question]
    var progress: Int
    let total: Int
}

struct Question {
    let text: String
    let options: [String]
}

extension Survey {
    static let mockSurveys = [
        Survey(
            title: "Food Survey",
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
            ],
            progress: 2,
            total: 2
        ),
        Survey(
            title: "Travel Survey",
            image: "car",
            questions: [
                Question(
                    text: "How often do you travel?",
                    options: ["Weekly", "Monthly", "Yearly", "Never"]
                )
            ],
            progress: 1,
            total: 1
        )
    ]

    /// Generates fake results for each question: [option: number of votes]
    var mockResults: [[String: Int]] {
        questions.map { question in
            var result: [String: Int] = [:]
            for option in question.options {
                result[option] = Int.random(in: 5...30)
            }
            return result
        }
    }
}
