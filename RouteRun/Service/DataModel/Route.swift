import Foundation
import CoreLocation

struct Route: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var date: Date
    var coordinates: [CLLocationCoordinate2D]
    var distance: Double
    var duration: TimeInterval
    var userId: String
    var city: String
    var terrain: Terrain
    var surface: Surface
    var activityType: ActivityType
    var likers: [String]
    var likesCount: Int { likers.count }
    var searchKeywords: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, date, coordinates, distance, duration, userId, city, terrain, surface, activityType, likers, searchKeywords
    }
    
    struct CoordinateWrapper: Codable {
        let lat: Double
        let lng: Double
        init(_ coord: CLLocationCoordinate2D) {
            lat = coord.latitude
            lng = coord.longitude
        }
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String = "",
        date: Date = Date(),
        coordinates: [CLLocationCoordinate2D],
        distance: Double,
        duration: TimeInterval,
        userId: String,
        city: String,
        terrain: Terrain,
        surface: Surface,
        activityType: ActivityType,
        likers: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.date = date
        self.coordinates = coordinates
        self.distance = distance
        self.duration = duration
        self.userId = userId
        self.city = city
        self.terrain = terrain
        self.surface = surface
        self.activityType = activityType
        self.likers = likers
        self.searchKeywords = (
            [
                city.lowercased(),
                terrain.rawValue,
                surface.rawValue,
                activityType.rawValue
            ] +
            name.lowercased().split(
                separator: " "
            ).map(\.description) +
            description.lowercased().split(
                separator: " "
            ).map(
                \.description
            )
        ).filter {
            !$0.isEmpty
        }
    }
    
    var averageSpeed: Double {
        guard duration > 0 else { return 0 }
        return distance / duration * 3.6
    }
    
    var formattedDistance: String {
        distance >= 1000
        ? String(format: "%.2f км", distance / 1000)
        : String(format: "%.0f м", distance)
    }
    
    var formattedDuration: String {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute, .second]
        f.calendar?.locale = Locale(identifier: "ru_RU")
        f.unitsStyle = .abbreviated
        return f.string(from: duration) ?? "0:00"
    }
    
    var formattedAverageSpeed: String {
        String(format: "%.1f км/ч", averageSpeed)
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        date = try c.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        let wrapped = try c.decodeIfPresent([CoordinateWrapper].self, forKey: .coordinates) ?? []
        coordinates = wrapped.map { $0.coordinate }
        distance = try c.decodeIfPresent(Double.self, forKey: .distance) ?? 0
        duration = try c.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? 0
        userId = try c.decode(String.self, forKey: .userId)
        city = try c.decodeIfPresent(String.self, forKey: .city) ?? ""
        terrain = try c.decode(Terrain.self, forKey: .terrain)
        surface = try c.decode(Surface.self, forKey: .surface)
        activityType = try c.decode(ActivityType.self, forKey: .activityType)
        likers = try c.decodeIfPresent([String].self, forKey: .likers) ?? []
        searchKeywords = try c.decodeIfPresent([String].self, forKey: .searchKeywords) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(description, forKey: .description)
        try c.encode(date, forKey: .date)
        let wrapped = coordinates.map(CoordinateWrapper.init)
        try c.encode(wrapped, forKey: .coordinates)
        try c.encode(distance, forKey: .distance)
        try c.encode(duration, forKey: .duration)
        try c.encode(userId, forKey: .userId)
        try c.encode(city, forKey: .city)
        try c.encode(terrain, forKey: .terrain)
        try c.encode(surface, forKey: .surface)
        try c.encode(activityType, forKey: .activityType)
        try c.encode(likers, forKey: .likers)
        let searchKeywords = [
            name.lowercased()] +
        city.lowercased().split(separator: " ").map({String($0)}) +
        description.lowercased().split(separator: " ").map({String($0)})
            .filter { !$0.isEmpty }
        try c.encode(searchKeywords, forKey: .searchKeywords)
    }
}
