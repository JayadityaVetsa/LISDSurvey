import SwiftUI
import FirebaseAuth

struct ProfilePage: View {
    @EnvironmentObject var surveyStore: SurveyStore
    @Binding var isLoggedIn: Bool
    @StateObject private var tagViewModel = TagViewModel()
    @State private var showLogoutConfirmation = false
    @State private var showUploadConfirmation = false
    @State private var showDeleteConfirmation = false

    private var userEmail: String {
        Auth.auth().currentUser?.email ?? "User Email"
    }

    private var userName: String {
        userEmail.components(separatedBy: "@").first?.capitalized ?? "User"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Spacer()
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            Text("Logout")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)

                    // User Info
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                            .background(Circle().fill(Color(.systemGray5)))

                        Text(userName)
                            .font(.system(size: 22, weight: .bold))

                        Text(userEmail)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)

                        Button(action: {}) {
                            Text("Edit profile")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                        .padding(.top, 6)
                    }
                    .padding(.top, 16)

                    // Settings Form
                    Form {
                        Section(header: Text("Content")) {
                            Label("Favorites", systemImage: "plus.circle")
                            Label("Downloads", systemImage: "arrow.down.circle")
                        }

                        Section(header: Text("Preferences")) {
                            NavigationLink(destination: TagSelectionView(viewModel: tagViewModel)) {
                                HStack {
                                    Label("Tags", systemImage: "tag")
                                    Spacer()
                                    if !tagViewModel.selectedTags.isEmpty {
                                        Text(tagViewModel.selectedTags.map { $0.name }.joined(separator: ", "))
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            Label("Language", systemImage: "globe")
                            Label("Notifications", systemImage: "bell")
                            Label("Theme", systemImage: "paintpalette")
                        }

                        Section(header: Text("Dev Tools")) {
                            Button(action: {
                                surveyStore.uploadTestSurveys()
                                showUploadConfirmation = true
                            }) {
                                Label("Upload Mock Surveys", systemImage: "plus.square.on.square")
                                    .foregroundColor(.blue)
                            }

                            Button(role: .destructive, action: {
                                showDeleteConfirmation = true
                            }) {
                                Label("Delete All Surveys", systemImage: "trash")
                            }

                            Text("This replaces old test surveys with 4 fresh ones.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 16)
                }

                // Alerts
                .alert("Sign Out", isPresented: $showLogoutConfirmation) {
                    Button("Sign Out", role: .destructive) {
                        do {
                            try Auth.auth().signOut()
                            surveyStore.resetStore()
                            isLoggedIn = false
                            print("✅ Successfully logged out.")
                        } catch {
                            print("❌ Error during logout: \(error.localizedDescription)")
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to sign out?")
                }

                .alert("Mock Surveys Uploaded", isPresented: $showUploadConfirmation) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Test surveys have been uploaded to Firestore.")
                }

                .alert("Delete All Surveys", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        surveyStore.deleteSurveys(withTag: "MOCK_TEST")
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete all mock surveys?")
                }
            }
            .onAppear {
                tagViewModel.loadTags()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
