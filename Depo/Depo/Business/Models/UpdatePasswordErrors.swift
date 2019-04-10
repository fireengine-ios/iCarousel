import Foundation

enum UpdatePasswordErrors {
    case unknown
    case invalidCaptcha
    case invalidNewPassword
    case invalidOldPassword
    case notMatchNewAndRepeatPassword
    
    case newPasswordIsEmpty
    case oldPasswordIsEmpty
    case repeatPasswordIsEmpty
    case captchaAnswerIsEmpty
}
extension UpdatePasswordErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return TextConstants.temporaryErrorOccurredTryAgainLater
        case .invalidCaptcha:
            return TextConstants.invalidCaptcha
        case .invalidNewPassword:
            return TextConstants.errorInvalidPassword
        case .invalidOldPassword:
            return TextConstants.oldPasswordDoesNotMatch
        case .notMatchNewAndRepeatPassword:
            return TextConstants.newPasswordAndRepeatedPasswordDoesNotMatch
            
        case .newPasswordIsEmpty:
            return TextConstants.newPasswordIsEmpty
        case .oldPasswordIsEmpty:
            return TextConstants.oldPasswordIsEmpty
        case .repeatPasswordIsEmpty:
            return TextConstants.repeatPasswordIsEmpty
        case .captchaAnswerIsEmpty:
            return TextConstants.thisTextIsEmpty
        }
    }
}
