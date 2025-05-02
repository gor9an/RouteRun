//
//  AuthenticationViewModel.swift
//  RouteRun
//
//  Created by Andrei Gordienko on 02.05.2025.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel: ObservableObject {

    func signInWithGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else { throw URLError(.cannotFindHost) }
        let gidResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken = gidResult.user.idToken?.tokenString else { throw URLError(.badServerResponse) }
        let accessToken = gidResult.user.accessToken.tokenString

        let tokens = GoogleSignInModel(idToken: idToken, accessToken: accessToken)
        try await AuthenticationManager.shared.signInWithGoogle(with: tokens)
    }
}
