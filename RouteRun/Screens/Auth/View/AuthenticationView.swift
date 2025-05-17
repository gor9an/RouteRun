import SwiftUI
import GoogleSignInSwift

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    @StateObject var viewModel: AuthenticationViewModel = AuthenticationViewModel()
    @State var showAlert = false
    @State var errorMessage = ""
    
    @State var showResetAlert = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(spacing: 16) {
                Header()
                LogIn()
                Spacer()
            }
        }
        .padding(20)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color(.systemBackground).opacity(0.9))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("RouteRun")
    }
    
    private func Header() -> some View {
        HStack {
            Text("Войдите в аккаунт")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
        .padding(16)
    }
    
    private func LogIn() -> some View {
        VStack(spacing: 20) {
            LogInWithEmail()
            
            ZStack {
                Divider()
                    .overlay(Color(.systemBackground).opacity(0.9))
                Text("Или")
                    .bold()
                    .font(.headline)
                    .foregroundStyle(Color(.systemBackground).opacity(0.9))
                    .padding(5)
                    .background(Color(.label))
            }
            
            GoogleButton()
        }
        .padding(25)
        .background(Color(.label))
        .cornerRadius(30)
    }
    
    private func LogInWithEmail() -> some View {
        VStack {
            EmailField()
            PasswordField()
            
            Divider()
                .overlay(Color(.systemBackground).opacity(0.9))
            
            LoginButton()
            SignUpButton()
            ForgotPasswordButton()
        }
    }
    
    private func EmailField() -> some View {
        TextField("Email", text: $viewModel.email)
            .padding()
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(10)
            .autocapitalization(.none)
    }
    
    private func PasswordField() -> some View {
        SecureField("Пароль", text: $viewModel.password)
            .padding()
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(10)
    }
    
    private func LoginButton() -> some View {
        Button {
            Task {
                do {
                    try await viewModel.signIn()
                    
                    showSignInView = false
                    errorMessage = ""
                } catch {
                    showAlert = true
                    errorMessage = error.localizedDescription
                }
                
            }
            
        } label: {
            Text("Войти с Email")
                .padding()
                .font(.headline)
                .foregroundStyle(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(10)
        }
        .alert(
            isPresented: $showAlert
        ) {
            BadEmailAlert()
        }
    }
    
    private func SignUpButton() -> some View {
        Button {
            Task {
                do {
                    try await viewModel.signUp()
                    showSignInView = false
                    errorMessage = ""
                } catch {
                    showAlert = true
                    errorMessage = error.localizedDescription
                }
                
            }
        } label: {
            Text("Зарегистрироваться с Email")
                .padding()
                .font(.headline)
                .foregroundStyle(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6).opacity(0.4))
                .cornerRadius(10)
        }
        .alert(
            isPresented: $showAlert
        ) {
            Alert(
                title: Text(
                    "Ошибка"
                ),
                message: Text(
                    errorMessage
                ),
                dismissButton: .cancel(
                    Text(
                        "Ок"
                    ),
                    action: {
                        showAlert = false
                        errorMessage = ""
                    }
                )
            )
        }
    }
    
    private func ForgotPasswordButton() -> some View {
        Button(
            action: {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        showResetAlert = true
                        errorMessage = ""
                    } catch {
                        showAlert = true
                        errorMessage = error.localizedDescription
                    }
                }
            },
            label: {
                Text("Забыли пароль?")
                    .padding()
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6).opacity(0.4))
                    .cornerRadius(10)
            }
        )
        .alert(isPresented: $showResetAlert) {
            ResetAlert()
        }
    }
    
    private func GoogleButton() -> some View {
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
    }
    
    private func BadEmailAlert() -> Alert {
        Alert(
            title: Text(
                "Внимание"
            ),
            message: Text(
                errorMessage
            ),
            dismissButton: .cancel(
                Text(
                    "Ок"
                ),
                action: {
                    showAlert = false
                    errorMessage = ""
                }
            )
        )
    }
    
    private func ResetAlert() -> Alert {
        Alert(
            title: Text(
                "Проверьте почту"
            ),
            message: Text(
                "На вашу почту отправлено письмо со сбросом пароля"
            ),
            dismissButton: .cancel(
                Text(
                    "Ок"
                ),
                action: {
                    showAlert = false
                }
            )
        )
    }
}
