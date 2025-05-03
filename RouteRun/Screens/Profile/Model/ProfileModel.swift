//
//  ProfileModel.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import Foundation

struct ProfileModel: Codable {
    let name: String
    let avatar: URL
    let favoriteRoutes: [Route]
}
