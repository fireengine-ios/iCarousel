//
//  TwoFactorChallengePresenter.swift
//  Depo
//
//  Created by Raman Harhun on 7/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class TwoFactorChallengePresenter: PhoneVerificationPresenter {
    
    private var isPhoneJustUpdated = false
    
    override func viewIsReady() {
        view.setupButtonsInitialState()
        view.setupInitialState()
        configure()
        resendCodeRequestSucceeded()
    }
    
    override func resendButtonPressed() {
        view.resendButtonShow(show: false)

        startAsyncOperationDisableScreen()
        
        interactor.resendCode()
    }
    
    override func resendCodeRequestSucceeded() {
        view.setupButtonsInitialState()
        view.setupTimer(withRemainingTime: interactor.remainingTimeInSeconds)
        view.updateEditingState()
        
        completeAsyncOperationEnableScreen()
        asyncOperationSuccess()
    }
    
    override func verificationSucces() {
        guard let interactor = interactor as? TwoFactorChallengeInteractor else {
            assertionFailure()
            return
        }
        interactor.checkEULA()
    }
    
    override func verificationFailed(with error: String) {
        completeAsyncOperationEnableScreen()

        let errorText: String
        
        if isPhoneJustUpdated {
            router.popToLoginWithPopUp(title: nil,
                                       message: TextConstants.phoneUpdatedNeedsLogin,
                                       image: .none) { [weak self] in
                self?.interactor.stopUpdatePhone()
            }
            return
            
        } else if error == "INVALID_SESSION" {
            router.popToLoginWithPopUp(title: TextConstants.errorAlert,
                                       message: TextConstants.twoFAInvalidSessionErrorMessage,
                                       image: .error, onClose: nil)
            return
            
        } else if error == HeaderConstant.emptyMSISDN {
            updateEmptyPhone()
            return
            
        } else if error == HeaderConstant.emptyEmail {
            updateEmptyEmail()
            return
            
        } else if error == "INVALID_CHALLENGE" {
            errorText = TextConstants.twoFAInvalidChallengeErrorMessage
            timerFinishedRunning(with: true)

        } else if error == "TOO_MANY_INVALID_ATTEMPTS" {
            errorText = TextConstants.twoFATooManyAttemptsErrorMessage
            timerFinishedRunning(with: true)
            
        } else if error == "INVALID_OTP_CODE" {
            errorText = TextConstants.twoFAInvalidOtpErrorMessage
            
            /// Fix for backend response
        } else if error.contains(ErrorResponseText.resendCodeExceeded)  {
            errorText = TextConstants.twoFATooManyRequestsErrorMessage
            
        } else {
            assertionFailure("Unrecognized error")
            errorText = "Unrecognized error"
        }
        
        view.updateEditingState()
        view.showError(errorText)
    }

    private func updateEmptyPhone() {
        interactor.updateEmptyPhone(delegate: self)
    }
    
    private func updateEmptyEmail() {
        interactor.updateEmptyEmail()
    }
    
    func onSuccessEULA() {
        completeAsyncOperationEnableScreen()
        router.goAutoSync()
    }
    
    func onFailEULA() {
        completeAsyncOperationEnableScreen()
        
        guard let router = router as? TwoFactorChallengeRouter else {
            assertionFailure()
            return
        }
        
        router.goToTermsAndServices()
    }
}

// MARK: - AccountWarningServiceDelegate

extension TwoFactorChallengePresenter: AccountWarningServiceDelegate {
    func successedSilentLogin() {
        verificationSucces()
    }
    
    func needToRelogin() {
        isPhoneJustUpdated = true
        interactor.verifyCode(code: currentSecurityCode)
    }
    
}
