import Foundation
import MapKit
import FirebaseFirestore

final class RoutesViewModel: ObservableObject {
    @Published var routes: [Route] = []
    @Published var recommendedRoutes: [Route] = []
    @Published var searchResults: [Route] = []
    @Published var currentUser: RouteUser?
    @Published var isLoading = false
    @Published var error: Error?
    private let model: RoutesModelProtocol
    private let authManager: AuthenticationManager
    private let db = Firestore.firestore()

    init(model: RoutesModelProtocol = RoutesModel(), authManager: AuthenticationManager = .shared) {
        self.model = model
        self.authManager = authManager
    }
    
    @MainActor
    func loadAll() async {
        isLoading = true
        do {
            let user = try authManager.getAuthenticatedUser()
            async let all = model.fetchRoutes()
            async let rec = model.fetchRecommendedRoutes()
            async let cu  = model.fetchCurrentUser(userId: user.id)
            let (a, r, u) = try await (all, rec, cu)
            routes = a
            recommendedRoutes = r
            currentUser = u
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func isLiked(_ route: Route) -> Bool {
        guard let uid = try? authManager.getAuthenticatedUser().id else { return false }
        return route.likers.contains(uid)
    }
    
    @MainActor
    func toggleLike(route: Route) async {
        guard let uid = try? authManager.getAuthenticatedUser().id else { return }
        do {
            if route.likers.contains(uid) {
                try await model.unlikeRoute(routeId: route.id, userId: uid)
                updateLocalLikers(routeId: route.id, add: false, userId: uid)
            } else {
                try await model.likeRoute(routeId: route.id, userId: uid)
                updateLocalLikers(routeId: route.id, add: true, userId: uid)
            }
        } catch {
            self.error = error
        }
    }
    
    private func updateLocalLikers(routeId: String, add: Bool, userId: String) {
        func apply(_ array: inout [Route]) {
            if let i = array.firstIndex(where: { $0.id == routeId }) {
                if add {
                    array[i].likers.append(userId)
                } else {
                    array[i].likers.removeAll { $0 == userId }
                }
            }
        }
        apply(&routes)
        apply(&recommendedRoutes)
        apply(&searchResults)
    }
    
    
    @MainActor
    func searchRoutes(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isLoading = true
        do {
            searchResults = try await model.searchRoutes(query: query)
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func routeRegion(for route: Route) -> MKCoordinateRegion {
        guard !route.coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
        let lats = route.coordinates.map(\.latitude)
        let lons = route.coordinates.map(\.longitude)
        let center = CLLocationCoordinate2D(latitude: (lats.min()! + lats.max()!) / 2,
                                            longitude: (lons.min()! + lons.max()!) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (lats.max()! - lats.min()!) * 1.5,
                                    longitudeDelta: (lons.max()! - lons.min()!) * 1.5)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func getRouteLine(for route: Route) -> MKPolyline {
        MKPolyline(coordinates: route.coordinates, count: route.coordinates.count)
    }

    func deleteRoute(for routeId: String) throws {
        guard let userId = currentUser?.id else { return }
        Task {
            try await db.collection("routes").document(routeId).delete()
            try await model.deleteFromLiked(routeId: routeId, userId: userId)
        }
    }
}
