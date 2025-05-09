//
//  RouteModel.swift
//  RouteRun
//
//  Created by Andrei Gordienko on 20.04.2025.
//


import Foundation
import CoreLocation

struct Route: Identifiable {
    var id: String
    var name: String
    var description: String
    var date: Date
    var coordinates: [CLLocationCoordinate2D]
    var distance: Double
    var duration: TimeInterval
    var userId: String
    var city: String

    var averageSpeed: Double {
        guard duration > 0 else { return 0 }
        return distance / duration * 3.6 // км/ч
    }

    var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.2f км", distance / 1000)
        } else {
            return String(format: "%.0f м", distance)
        }
    }

    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0:00"
    }

    var formattedAverageSpeed: String {
        return String(format: "%.1f км/ч", averageSpeed)
    }

    init(id: String = UUID().uuidString,
         name: String,
         description: String = "",
         date: Date = Date(),
         coordinates: [CLLocationCoordinate2D],
         distance: Double,
         duration: TimeInterval,
         userId: String,
         city: String) {
        self.id = id
        self.name = name
        self.description = description
        self.date = date
        self.coordinates = coordinates
        self.distance = distance
        self.duration = duration
        self.userId = userId
        self.city = city
    }
}

extension Route: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, description, date, coordinates, distance, duration, userId, city
    }

    struct CoordinateWrapper: Codable {
        let lat: Double
        let lng: Double

        init(_ coord: CLLocationCoordinate2D) {
            self.lat = coord.latitude
            self.lng = coord.longitude
        }

        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(date, forKey: .date)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(userId, forKey: .userId)
        try container.encode(city, forKey: .city)

        let wrappedCoords = coordinates.map(CoordinateWrapper.init)
        try container.encode(wrappedCoords, forKey: .coordinates)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(Date.self, forKey: .date)
        distance = try container.decode(Double.self, forKey: .distance)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        userId = try container.decode(String.self, forKey: .userId)
        city = try container.decode(String.self, forKey: .city)

        let wrappedCoords = try container.decode([CoordinateWrapper].self, forKey: .coordinates)
        coordinates = wrappedCoords.map { $0.coordinate }
    }
}
