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

#Preview {
    ContentView()
}
