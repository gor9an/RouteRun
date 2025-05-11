import Foundation

struct ProfileModel: Codable {
    let name: String
    let avatar: URL
    let favoriteRoutes: [Route]
}
