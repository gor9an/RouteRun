//
//  AuthenticationManager.swift
//  RouteRun
//
//  Created by Andrei Gordienko on 02.05.2025.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() { }

    func getAuthenticatedUser() throws -> AuthDataModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }

        return AuthDataModel(user: user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: - With Google
extension AuthenticationManager {

    @discardableResult
    func signInWithGoogle(with tokens: GoogleSignInModel) async throws -> AuthDataModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(with: credential)
    }

    func signIn(with credential: AuthCredential) async throws -> AuthDataModel {
        let authData = try await Auth.auth().signIn(with: credential)
        return AuthDataModel(user: authData.user)
    }
}
