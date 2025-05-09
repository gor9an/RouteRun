//
//  AuthError.swift
//  RouteRun
//
//  Created by Andrei Gordienko on 09.05.2025.
//

import Foundation

enum AuthError: Error {
    case emailNotVerified
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emailNotVerified:
            return NSLocalizedString("Подтвердите Email.", comment: "Email не подтвержден")
        }
    }
}
