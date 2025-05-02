//
//  ProfileView.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 05.11.2024.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State var showAlert = false
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image("profile image")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)

                Spacer()
                Spacer()

                Button(
                    action: {
                        //TODO: - Favorites action
                    },
                    label: {
                        Image(systemName: "bookmark.fill")
                            .resizable()
                            .frame(width: 35, height: 50)
                            .padding()
                            .tint(.orange)
                    })

                Button(
                    action: {
                        do {
                            try viewModel.logout()
                            showSignInView = true
                        } catch {
                            showAlert = true
                        }
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
                    Alert(
                        title: Text(
                            "Ошибка"
                        ),
                        message: Text(
                            "Произошла ошибка при выходе"
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
            .padding()


            Spacer()
        }
        .navigationTitle(Text("Профиль"))
    }
}

#Preview {
    @Previewable @State var showSignInView = false
    NavigationStack {
        ProfileView(showSignInView: $showSignInView)
    }
}
