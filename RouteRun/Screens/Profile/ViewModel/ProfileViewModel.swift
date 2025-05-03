//
//  ProfileViewModel.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import Foundation
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {

    func logout() throws {
        try AuthenticationManager.shared.signOut()
    }

    func getImageURL() -> URL? {
        guard let photoURL = try? AuthenticationManager.shared.getAuthenticatedUser().phtoroURL else { return nil }
        return URL(string: photoURL)
    }

    func getDisplayName() -> String {
        let user = try? AuthenticationManager.shared.getAuthenticatedUser()
        return user?.displayName ?? user?.email ?? "User"
    }
}
