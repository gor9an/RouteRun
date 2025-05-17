import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: RouteUser?
    @Published var likedRoutes: [Route] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let db = Firestore.firestore()

    init() {
        Task { await loadUserAndRoutes() }
    }

    func loadUserAndRoutes() async {
        isLoading = true
        do {
            guard let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }

            let userDoc = try await db.collection("users").document(authUser.uid).getDocument()
            let user = try userDoc.data(as: RouteUser.self)
            self.user = user

            var routes: [Route] = []
            for routeId in user.likedRoutes {
                let doc = try await db.collection("routes").document(routeId).getDocument()
                if let route = try? doc.data(as: Route.self) {
                    routes.append(route)
                }
            }

            self.likedRoutes = routes

        } catch {
            self.error = error
        }
        isLoading = false
    }

    func getDisplayName() -> String {
        let user = try? AuthenticationManager.shared.getAuthenticatedUser()
        return user?.displayName ?? user?.email ?? "User"
    }

    func logout() throws {
        try AuthenticationManager.shared.signOut()
    }
}
