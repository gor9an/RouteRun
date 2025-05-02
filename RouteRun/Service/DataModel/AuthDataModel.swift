//
//  AuthDataModel.swift
//  RouteRun
//
//  Created by Andrei Gordienko on 02.05.2025.
//

import FirebaseAuth

struct AuthDataModel {
    let uid: String
    let email: String?
    let phtoroURL: String?

    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.phtoroURL = user.photoURL?.absoluteString
    }
}
