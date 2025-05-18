import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: RouteUser?
    @Published var likedRoutes: [Route] = []
    @Published var myRoutes: [Route] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var newWeight: Int?
    
    private let db = Firestore.firestore()
    
    init() {
        Task { await loadUserAndRoutes() }
    }
    
    func loadUserAndRoutes() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let authenticatedUser = try AuthenticationManager.shared.getAuthenticatedUser()
            let userSnapshot = try await db
                .collection("users")
                .document(authenticatedUser.id)
                .getDocument()
            let routeUser = try userSnapshot.data(as: RouteUser.self)
            self.user = routeUser

            self.likedRoutes = try await fetchRoutes(withIdentifiers: routeUser.likedRoutes)

            let myRoutesQuery = try await db
                .collection("routes")
                .whereField("userId", isEqualTo: authenticatedUser.id)
                .getDocuments()
            self.myRoutes = myRoutesQuery.documents.compactMap {
                try? $0.data(as: Route.self)
            }

        } catch {
            self.error = error
        }
    }

    private func fetchRoutes(withIdentifiers identifiers: [String]) async throws -> [Route] {
        var routes: [Route] = []
        for id in identifiers {
            let snapshot = try await db
                .collection("routes")
                .document(id)
                .getDocument()
            if let route = try? snapshot.data(as: Route.self) {
                routes.append(route)
            }
        }
        return routes
    }

    func updateWeight() {
        guard let _ = try? AuthenticationManager.shared.getAuthenticatedUser().id, let newWeight else { return }
        do {
            try user?.updateWeight(newWeight: newWeight)
            user?.weight = newWeight
        } catch {
            self.error = error
        }
    }
    
    func getDisplayName() -> String {
        let user = try? AuthenticationManager.shared.getAuthenticatedUser()
        return user?.name ?? user?.email ?? "User"
    }
    
    func logout() throws {
        try AuthenticationManager.shared.signOut()
    }
}
