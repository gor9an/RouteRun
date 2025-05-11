import Foundation

struct RouteUser: Identifiable, Codable {
    var id: String
    var email: String
    var photoURL: URL?
    var likedRoutes: [String]
    
    init(
        id: String,
        email: String = "",
        photoURL: URL? = nil,
        likedRoutes: [String] = []
    ) {
        self.id = id
        self.email = email
        self.photoURL = photoURL
        self.likedRoutes = likedRoutes
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, photoURL, likedRoutes
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        email = try c.decodeIfPresent(String.self, forKey: .email) ?? ""
        if let urlString = try c.decodeIfPresent(String.self, forKey: .photoURL) {
            photoURL = URL(string: urlString)
        } else {
            photoURL = nil
        }
        likedRoutes = try c.decodeIfPresent([String].self, forKey: .likedRoutes) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(email, forKey: .email)
        try c.encodeIfPresent(photoURL?.absoluteString, forKey: .photoURL)
        try c.encode(likedRoutes, forKey: .likedRoutes)
    }
}
