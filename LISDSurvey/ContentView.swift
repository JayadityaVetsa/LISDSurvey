import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            AuthView(isLoggedIn: $isLoggedIn)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomePage()
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
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SurveyStore())
}
