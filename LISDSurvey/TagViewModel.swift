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
        Tag(name: "Science"),
        Tag(name: "Math"),
        Tag(name: "Programming"),
        Tag(name: "Art"),
        Tag(name: "History")
    ]

    private let db = Firestore.firestore()

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
        db.collection("users").document(userID).setData(["tags": tagNames], merge: true)
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
