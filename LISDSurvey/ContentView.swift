import SwiftUI
import FirebaseAuth
import Combine

struct ContentView: View {
    @State private var isLoggedIn = false
    @StateObject private var surveyStore = SurveyStore()

    var body: some View {
        Group {
            if isLoggedIn {
                TabView {
                    HomePage(isLoggedIn: $isLoggedIn)
                        .tabItem { Label("Home", systemImage: "house") }

                    OngoingView()
                        .tabItem { Label("Ongoing", systemImage: "chart.bar") }

                    FinishedView()
                        .tabItem { Label("Completed", systemImage: "checkmark") }

                    ProfilePage(isLoggedIn: $isLoggedIn)
                        .tabItem { Label("Profile", systemImage: "person.circle") }
                }
                .environmentObject(surveyStore)
            } else {
                AuthView(isLoggedIn: $isLoggedIn)
                    .environmentObject(surveyStore)
            }
        }
        .onAppear {
            isLoggedIn = Auth.auth().currentUser != nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .authStateDidChange)) { _ in
            isLoggedIn = Auth.auth().currentUser != nil
        }
    }
}
extension Notification.Name {
    static let authStateDidChange = Notification.Name("authStateDidChange")
}
