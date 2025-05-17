import Foundation
import FirebaseFirestore

struct RouteUser: Identifiable, Codable {
    var id: String
    var email: String
    var photoURL: URL?
    var likedRoutes: [String]
    var weight: Int?
    private let db = Firestore.firestore()
    
    init(
        id: String,
        email: String = "",
        photoURL: URL? = nil,
        likedRoutes: [String] = [],
        weight: Int? = nil
    ) {
        self.id = id
        self.email = email
        self.photoURL = photoURL
        self.likedRoutes = likedRoutes
        self.weight = weight
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, photoURL, likedRoutes, weight
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        email = try c.decodeIfPresent(String.self, forKey: .email) ?? ""
        if let url = try c.decodeIfPresent(String.self, forKey: .photoURL) {
            photoURL = URL(string: url)
        } else {
            photoURL = nil
        }
        likedRoutes = try c.decodeIfPresent([String].self, forKey: .likedRoutes) ?? []
        weight = try c.decodeIfPresent(Int.self, forKey: .weight)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(email, forKey: .email)
        try c.encodeIfPresent(photoURL?.absoluteString, forKey: .photoURL)
        try c.encode(likedRoutes, forKey: .likedRoutes)
        try c.encodeIfPresent(weight, forKey: .weight)
    }
    
    func updateWeight(newWeight: Int) throws {
        guard let uid = try? AuthenticationManager.shared.getAuthenticatedUser().uid else { return }
        Task {
            do {
                let userReference = db.collection("users").document(uid)
                
                try await userReference.updateData(["weight": newWeight])
            } catch {
                throw error
            }
        }
    }
}
