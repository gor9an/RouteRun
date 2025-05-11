import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = true
    
    var body: some View {
        ZStack {
            if showSignInView {
                NavigationStack {
                    AuthenticationView(showSignInView: $showSignInView)
                }
            } else {
                TabView {
                    MapView()
                        .tabItem {
                            Label("Карта", systemImage: "map")
                        }
                    RoutesView()
                        .tabItem {
                            Label("Маршруты", systemImage: "road.lanes.curved.right")
                        }
                    ProfileView(showSignInView: $showSignInView)
                        .tabItem {
                            Label("Профиль", systemImage: "person.fill")
                        }
                }
            }
        }
        .onAppear {
            let user = try? AuthenticationManager.shared.getAuthenticatedUser()
            showSignInView = user == nil
        }
    }
}

#Preview {
    RootView()
}
