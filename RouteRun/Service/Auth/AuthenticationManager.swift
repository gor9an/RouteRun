import Foundation
import FirebaseAuth
import GoogleSignIn

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() { }
    
    func getAuthenticatedUser() throws -> RouteUser {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return RouteUser(
            id: user.uid,
            email: user.email ?? "",
            name: user.displayName ?? user.email ?? "User",
            photoURL: user.photoURL,
            likedRoutes: []
        )
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: - With Email
extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> RouteUser {
        
        let authData = try await Auth.auth().createUser(withEmail: email, password: password)
        try await authData.user.sendEmailVerification()
        let user = authData.user
        
        return RouteUser(
            id: user.uid,
            email: user.email ?? "",
            name: user.displayName ?? user.email ?? "User",
            photoURL: user.photoURL,
            likedRoutes: []
        )
    }
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> RouteUser {
        let authData = try await Auth.auth().signIn(withEmail: email, password: password)
        
        do {
            try isEmailVerified()
        } catch {
            try signOut()
        }
        
        let user = authData.user
        
        return RouteUser(
            id: user.uid,
            email: user.email ?? "",
            name: user.displayName ?? user.email ?? "User",
            photoURL: user.photoURL,
            likedRoutes: []
        )
    }
    
    func resetPassword(with email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    @discardableResult
    func isEmailVerified() throws -> Bool {
        let isVerefied = Auth.auth().currentUser?.isEmailVerified ?? false
        
        if !isVerefied {
            throw AuthError.emailNotVerified
        }
        
        return true
    }
}

// MARK: - With Google
extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(with tokens: GoogleSignInModel) async throws -> RouteUser {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(with: credential)
    }
    
    func signIn(with credential: AuthCredential) async throws -> RouteUser {
        let authData = try await Auth.auth().signIn(with: credential)
        let user = authData.user
        return RouteUser(
            id: user.uid,
            email: user.email ?? "",
            name: user.displayName ?? user.email ?? "User",
            photoURL: user.photoURL,
            likedRoutes: []
        )
    }
}
