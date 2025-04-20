//
//  LoginView.swift
//  RouteRun
//
//  Created by Andrey Gordienko on 17.11.2024.
//

import SwiftUI

struct LoginView: View {
    @State var login = ""
    @State var password = ""
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField(
                "Введите логин",
                text: $login
            )
            .frame(width: 200, height: 60)
            .background(.gray)

            .clipShape(RoundedRectangle(cornerRadius: 15))

            TextField(
                "Введите пароль",
                text: $password
            )
            .frame(width: 200, height: 60)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 15))

            Button(
                action: {
                    //
                },
                label: {
                    Text("Зарегестрироваться")
                }
            )
            Button(
                action: {
                    //
                },
                label: {
                    Text("Уже есть аккаунт?")
                }
            )
        }
    }
}

