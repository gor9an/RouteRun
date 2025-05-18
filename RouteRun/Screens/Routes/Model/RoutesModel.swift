import Foundation
import FirebaseFirestore
import FirebaseAuth

final class RoutesModel: RoutesModelProtocol {
    private let db = Firestore.firestore()
    
    func fetchRoutes() async throws -> [Route] {
        let snap = try await db.collection("routes").getDocuments()
        return try snap.documents.map { try $0.data(as: Route.self) }
    }
    
    func fetchRecommendedRoutes() async throws -> [Route] {
        let snapshot = try await db.collection("routes").getDocuments()
        let all = try snapshot.documents.map { try $0.data(as: Route.self) }
        return Array(all.sorted { $0.likesCount > $1.likesCount }.prefix(5))
    }
    
    func searchRoutes(query: String) async throws -> [Route] {
        guard !query.isEmpty else { return [] }
        let lower = query.lowercased()
        let snapshot = try await db.collection("routes")
            .whereField("searchKeywords", arrayContains: lower)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: Route.self) }
    }
    
    func fetchCurrentUser(userId: String) async throws -> RouteUser {
        let reference = db.collection("users").document(userId)
        let snapshot = try await reference.getDocument()
        if let user = try snapshot.data(as: RouteUser?.self) {
            return user
        }
        guard let user = Auth.auth().currentUser, user.uid == userId else {
            throw NSError(domain: "AppError", code: -1, userInfo: nil)
        }
        let newUser = RouteUser(
            id: userId,
            email: user.email ?? "",
            name: user.displayName ?? user.email ?? "User",
            photoURL: user.photoURL,
            likedRoutes: []
        )
        try reference.setData(from: newUser)
        return newUser
    }
    
    func likeRoute(routeId: String, userId: String) async throws {
        let reference = db.collection("routes").document(routeId)
        let userReference = db.collection("users").document(userId)
        
        try await reference.updateData([
            "likers": FieldValue.arrayUnion([userId])
        ])
        
        try await userReference.updateData([
            "likedRoutes": FieldValue.arrayUnion([routeId])
        ])
    }
    
    func unlikeRoute(routeId: String, userId: String) async throws {
        let reference = db.collection("routes").document(routeId)
        let userReference = db.collection("users").document(userId)
        
        try await reference.updateData([
            "likers": FieldValue.arrayRemove([userId])
        ])
        try await userReference.updateData([
            "likedRoutes": FieldValue.arrayRemove([routeId])
        ])
    }
}
