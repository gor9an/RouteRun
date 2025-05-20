import Foundation

protocol RoutesModelProtocol {
    func fetchRoutes() async throws -> [Route]
    func fetchRecommendedRoutes() async throws -> [Route]
    func searchRoutes(query: String) async throws -> [Route]
    func fetchCurrentUser(userId: String) async throws -> RouteUser
    func likeRoute(routeId: String, userId: String) async throws
    func unlikeRoute(routeId: String, userId: String) async throws
    func deleteFromLiked(routeId: String, userId: String) async throws
}
