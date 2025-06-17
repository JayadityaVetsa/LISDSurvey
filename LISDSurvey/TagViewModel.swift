import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Tag: Identifiable, Hashable, Codable {
    var id = UUID()
    let name: String
}

class TagViewModel: ObservableObject {
    @Published var selectedTags: [Tag] = []

    let allTags: [Tag] = [
        Tag(name: "STEM"),
        Tag(name: "Math"),
        Tag(name: "Physics"),
        Tag(name: "Science"),
        Tag(name: "Programming"),
        Tag(name: "Business"),
        Tag(name: "Finance"),
        Tag(name: "Economics"),
        Tag(name: "Leadership"),
        Tag(name: "Teamwork"),
        Tag(name: "Volunteering"),
        Tag(name: "Entrepreneurship"),
        Tag(name: "General Knowledge"),
        Tag(name: "History"),
        Tag(name: "Literature"),
        Tag(name: "Art"),
        Tag(name: "Design"),
        Tag(name: "Music"),
        Tag(name: "Current Events"),
        Tag(name: "School")
    ]

    private let db = Firestore.firestore()
    
    // Reference to the survey store to allow tag changes to reload surveys
    var surveyStore: SurveyStore?

    func loadTags() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userID).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let tagNames = data["tags"] as? [String] {
                DispatchQueue.main.async {
                    self.selectedTags = tagNames.compactMap { name in
                        self.allTags.first(where: { $0.name == name })
                    }
                }
            }
        }
    }

    func saveTags() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let tagNames = selectedTags.map { $0.name }
        db.collection("users").document(userID).setData(["tags": tagNames], merge: true) { error in
            if let error = error {
                print("❌ Failed to save tags: \(error.localizedDescription)")
            } else {
                print("✅ Tags saved successfully.")
                self.surveyStore?.loadSurveys()
            }
        }
    }

    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
        saveTags()
    }

    func isSelected(_ tag: Tag) -> Bool {
        selectedTags.contains(tag)
    }
}
