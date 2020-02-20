import Foundation

enum UpdatePasswordErrors {
    case special(String)
    case unknown
    
    case invalidCaptcha
    case invalidNewPassword
    case invalidOldPassword
    case notMatchNewAndRepeatPassword
    
    case newPasswordIsEmpty
    case oldPasswordIsEmpty
    case repeatPasswordIsEmpty
    case captchaAnswerIsEmpty
    
    case uppercaseMissingInPassword
    case lowercaseMissingInPassword
    case numberMissingInPassword
    case passwordIsEmpty
    
    case passwordInResentHistory(limit: Int)
    case passwordLengthIsBelowLimit(limit: Int)
    case passwordLengthExceeded(limit: Int)
    case passwordSequentialCaharacters(limit: Int)
    case passwordSameCaharacters(limit: Int)

}
extension UpdatePasswordErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return TextConstants.temporaryErrorOccurredTryAgainLater
        case .special(let text):
            return text
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
            
        case .uppercaseMissingInPassword:
            return TextConstants.uppercaseMissInPassword
        case .lowercaseMissingInPassword:
            return TextConstants.lowercaseMissInPassword
        case .numberMissingInPassword:
            return TextConstants.numberMissInPassword
        case .passwordIsEmpty:
            return TextConstants.passwordFieldIsEmpty
            
        case .passwordInResentHistory(let recentHistoryLimit):
            return String(format: TextConstants.passwordInResentHistory, recentHistoryLimit)
        case .passwordLengthIsBelowLimit(let minimumCharacterLimit):
            return String(format: TextConstants.passwordLengthIsBelowLimit, minimumCharacterLimit)
        case .passwordLengthExceeded(let maximumCharacterLimit):
            return String(format: TextConstants.passwordLengthExceeded, maximumCharacterLimit)
        case .passwordSequentialCaharacters(let sequentialCharacterLimit):
            return String(format: TextConstants.passwordSequentialCaharacters, sequentialCharacterLimit)
        case .passwordSameCaharacters(let sameCharacterLimit):
            return String(format: TextConstants.passwordSameCaharacters, sameCharacterLimit)
        }
    }
}
