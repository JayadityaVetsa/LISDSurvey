import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil

    var body: some View {
        Group {
            if isLoggedIn {
                TabView {
                    HomePage(isLoggedIn: $isLoggedIn)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }

                    OngoingView()
                        .tabItem {
                            Label("Ongoing", systemImage: "chart.bar")
                        }

                    FinishedView()
                        .tabItem {
                            Label("Completed", systemImage: "checkmark")
                        }

                    ProfilePage(isLoggedIn: $isLoggedIn)
                        .tabItem {
                            Label("Profile", systemImage: "person.circle")
                        }
                }
            } else {
                AuthView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // Extra safety net if Auth state changes while app is active
            isLoggedIn = Auth.auth().currentUser != nil
        }
    }
}
