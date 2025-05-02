//
//  LoginView.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 17.11.2024.
//

import SwiftUI
import GoogleSignInSwift

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    @StateObject var viewModel: AuthenticationViewModel = AuthenticationViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            GoogleSignInButton(
                viewModel: GoogleSignInButtonViewModel(
                    scheme: .dark,
                    style: .wide,
                    state: .normal
                )) {
                    Task {
                        do {
                            try await viewModel.signInWithGoogle()
                            showSignInView = false
                        } catch {
                            showSignInView = true
                        }
                    }
            }
            Text("""
            
            """)
            .bold()
            Spacer()
        }
        .padding(16)
        .navigationTitle("Вход")
    }
}

#Preview {
    AuthenticationView(showSignInView: .constant(false))
}
