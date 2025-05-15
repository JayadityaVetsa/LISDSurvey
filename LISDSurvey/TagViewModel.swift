//
//  TagViewModel.swift
//  LISDSurvey
//
//  Created by Sai venkat Veerapaneni on 5/15/25.
//

import Foundation
import SwiftUI

struct Tag: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
}

class TagViewModel: ObservableObject {
    @Published var selectedTags: [Tag] = []

    let allTags: [Tag] = [
        Tag(name: "Science"),
        Tag(name: "Math"),
        Tag(name: "Programming"),
        Tag(name: "Art"),
        Tag(name: "History")
    ]

    func loadTags() {
        // Add Firebase/UserDefaults loading logic here
    }

    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }

    func isSelected(_ tag: Tag) -> Bool {
        selectedTags.contains(tag)
    }
}
