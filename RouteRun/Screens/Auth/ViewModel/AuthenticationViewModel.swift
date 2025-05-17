import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else { throw AuthError.emptyData }

        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else { throw AuthError.emptyData }

        try await AuthenticationManager.shared.signIn(email: email, password: password)
    }
    
    func resetPassword() async throws {
        guard !email.isEmpty else { throw AuthError.emptyEmail }

        try await AuthenticationManager.shared.resetPassword(with: email)
    }
    
    func signInWithGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else { throw URLError(.cannotFindHost) }
        let gidResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidResult.user.idToken?.tokenString else { throw URLError(.badServerResponse) }
        let accessToken = gidResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInModel(idToken: idToken, accessToken: accessToken)
        try await AuthenticationManager.shared.signInWithGoogle(with: tokens)
    }
    
    @discardableResult
    func isEmailVerified() throws -> Bool {
        try AuthenticationManager.shared.isEmailVerified()
    }
}
