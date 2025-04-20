//
//  RoutesModel.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import Foundation

struct RouteModel: Codable {
    let id: Int
    let name: String
    let distance: Double
    let duration: Int
}
