//
//  Survey.swift
//  LISDSurvey
//
//  Created by Sai venkat Veerapaneni on 6/7/25.
//

import Foundation

struct Survey: Identifiable, Codable {
    let id: UUID
    let title: String
    let image: String
    let questions: [Question]
    
    var totalQuestions: Int { questions.count }

    init(id: UUID = UUID(), title: String, image: String, questions: [Question]) {
        self.id = id
        self.title = title
        self.image = image
        self.questions = questions
    }
}

struct Question: Codable {
    let text: String
    let options: [String]
}

struct SurveyState: Codable {
    var currentQuestionIndex: Int = 0
    var selectedAnswers: [Int: String] = [:]
    var isCompleted: Bool = false

    var progress: Int {
        selectedAnswers.count
    }
}
