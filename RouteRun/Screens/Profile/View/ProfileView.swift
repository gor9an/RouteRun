import SwiftUI
import Kingfisher

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State var showAlert = false
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                if let imageURL = viewModel.getImageURL() {
                    KFImage(imageURL)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(.circle)
                } else {
                    PlaceholderImage()
                }
                
                DisplayName()
                
                Spacer()
                
                ExitButton()
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func PlaceholderImage() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 100, height: 100)
    }
    
    private func DisplayName() -> some View {
        Text(viewModel.getDisplayName())
            .lineLimit(1)
            .font(.headline)
            .bold()
    }
    
    private func ExitButton() -> some View {
        Button(
            action: {
                showAlert = true
            },
            label: {
                Image(systemName: "door.right.hand.open")
                    .resizable()
                    .frame(width: 35, height: 50)
                    .padding()
                    .tint(.red)
                
            }
        )
        .alert(
            isPresented: $showAlert
        ) {
            ExitAlert()
        }
    }
    
    private func ExitAlert() -> Alert {
        Alert(
            title: Text(
                "Выход"
            ),
            message: Text(
                "Вы точно хотите выйти?"
            ),
            primaryButton: .default(
                Text(
                    "Выйти"
                ),
                action: {
                    do {
                        try viewModel.logout()
                        showSignInView = true
                    } catch {}
                    showAlert = false
                }
            ),
            secondaryButton: .cancel(
                Text(
                    "Нет"
                ),
                action: {
                    showAlert = false
                }
            )
        )
    }
}

#Preview {
    @Previewable @State var showSignInView = false
    NavigationStack {
        ProfileView(showSignInView: $showSignInView)
    }
}

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}
