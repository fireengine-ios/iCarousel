//
//  OTPViewOTPViewPresenter.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class OTPViewPresenter: PhoneVerificationPresenter {
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    override func verificationSucces() {
        tokenStorage.isClearTokens = true
        successedVerification()
    }
    
    override func verificationSilentSuccess() {
        successedVerification()
    }
    
    override func resendCodeRequestFailed(with error: ErrorResponse) {
        completeAsyncOperationEnableScreen()
        view.resendButtonShow(show: true)
        view.updateEditingState()
        
        if case ErrorResponse.error(let containedError) = error {
            if let serverError = containedError as? ServerError, serverError.code == 401 {
                router.popToLoginWithPopUp(title: TextConstants.errorAlert, message: TextConstants.twoFAInvalidSessionErrorMessage, image: .error, onClose: nil)
            } else if let serverError = containedError as? ServerStatusError, let description = serverError.errorDescription {
                view.showError(description)
            } else {
                view.showError(TextConstants.phoneVerificationResendRequestFailedErrorText)
            }
        } else {
            view.showError(TextConstants.phoneVerificationResendRequestFailedErrorText)
        }
        
        view.dropTimer()
    }
    
    private func successedVerification() {
        completeAsyncOperationEnableScreen()
        view.getNavigationController()?.popViewController(animated: true)
    }
}
