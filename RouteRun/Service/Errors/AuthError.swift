import Foundation

enum AuthError: Error {
    case emailNotVerified
    case emptyData
    case emptyEmail
    
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emailNotVerified:
            return NSLocalizedString("Подтвердите Email.", comment: "Email не подтвержден")
        case .emptyData:
            return NSLocalizedString("Проверьте данные для входа.", comment: "Проверьте данные для входа")
        case .emptyEmail:
            return NSLocalizedString("Проверьте Email.", comment: "Проверьте Email")
        }
    }
}
