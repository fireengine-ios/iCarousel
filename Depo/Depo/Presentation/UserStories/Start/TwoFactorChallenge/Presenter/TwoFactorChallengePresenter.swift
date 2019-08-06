//
//  TwoFactorChallengePresenter.swift
//  Depo
//
//  Created by Raman Harhun on 7/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class TwoFactorChallengePresenter: PhoneVereficationPresenter {
    
    private var isPhoneJustUpdated = false
    
    override func viewIsReady() {
        view.setupButtonsInitialState()
        view.setupInitialState()
        configure()
        resendCodeRequestSuccesed()
    }
    
    override func resendButtonPressed() {
        view.resendButtonShow(show: false)

        startAsyncOperationDisableScreen()
        
        interactor.resendCode()
    }
    
    override func resendCodeRequestSuccesed() {
        view.setupButtonsInitialState()
        view.setupTimer(withRemainingTime: interactor.remainingTimeInSeconds)
        view.updateEditingState()
        
        completeAsyncOperationEnableScreen()
        asyncOperationSuccess()
    }
    
    override func verificationSucces() {
        completeAsyncOperationEnableScreen()
        router.goAutoSync()
    }
    
    override func vereficationFailed(with error: String) {
        completeAsyncOperationEnableScreen()

        let errorText: String
        
        if isPhoneJustUpdated {
            router.popToLoginWithPopUp(title: nil,
                                       message: TextConstants.phoneUpdatedNeedsLogin,
                                       image: .none) { [weak self] in
                self?.interactor.stopUpdatePhone()
            }
            return
            
        } else  if error == "INVALID_SESSION" {
            router.popToLoginWithPopUp(title: TextConstants.errorAlert,
                                       message: TextConstants.twoFAInvalidSessionErrorMessage,
                                       image: .error, onClose: nil)
            return
            
        } else if error == HeaderConstant.emptyMSISDN {
            updateEmptyPhone()
            return
            
        } else if error == "INVALID_CHALLENGE" {
            errorText = TextConstants.twoFAInvalidChallengeErrorMessage
            timerFinishedRunning(with: true)

        } else if error == "TOO_MANY_INVALID_ATTEMPTS" {
            errorText = TextConstants.twoFATooManyAttemptsErrorMessage
            timerFinishedRunning(with: true)
            
        } else if error == "INVALID_OTP_CODE" {
            errorText = TextConstants.twoFAInvalidOtpErrorMessage
            
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
}

extension TwoFactorChallengePresenter: UpdatePhoneServiceDelegate {
    func successedSilentLogin() {
        verificationSucces()
    }
    
    func needToRelogin() {
        isPhoneJustUpdated = true
        interactor.verifyCode(code: currentSecurityCode)
    }
    
}
