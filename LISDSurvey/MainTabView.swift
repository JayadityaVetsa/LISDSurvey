import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomePage()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            OngoingView()
                .tabItem {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Ongoing")
                }
            FinishedView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Finished")
                }
        }
        .accentColor(.blue) // Optional: matches your screenshot
    }
}

#Preview {
    MainTabView()
}
