//
//  RoutesViewModel.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import Foundation

class RoutesViewModel: ObservableObject {
    let model = RoutesModel()
    var routes = [Route]()
    init() {
        fetchRoutes()
    }

    func fetchRoutes() {
        Task {
            do {
                self.routes = try await self.model.fetch()
            }
            catch {
                print("Error fetching routes: \(error)")
            }
        }
    }
}
