import Foundation

enum MapError: Error {
    case distanceZero
    case unAuthorized
}

extension MapError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .distanceZero:
            return NSLocalizedString("Маршрут слишком короткий", comment: "Маршрут должен быть длиннее")
        case .unAuthorized:
            return NSLocalizedString("Пользователь не авторизирован", comment: "Пользователь не авторизирован")
        }
    }
}
