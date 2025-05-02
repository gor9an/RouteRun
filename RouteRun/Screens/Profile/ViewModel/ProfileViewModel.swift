//
//  ProfileViewModel.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {

    func logout() throws {
        try AuthenticationManager.shared.signOut()
    }
}
