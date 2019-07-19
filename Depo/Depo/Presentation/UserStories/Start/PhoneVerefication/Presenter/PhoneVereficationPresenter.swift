//
//  PhoneVereficationPhoneVereficationPresenter.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVereficationPresenter: BasePresenter, PhoneVereficationModuleInput, PhoneVereficationViewOutput, PhoneVereficationInteractorOutput {

    weak var view: PhoneVereficationViewInput!
    var interactor: PhoneVereficationInteractorInput!
    var router: PhoneVereficationRouterInput!
    
    var currentSecurityCode = ""

    private lazy var customProgressHUD = CustomProgressHUD()
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    func viewIsReady() {
        interactor.trackScreen()
        view.setupInitialState()
        configure()
        view.setupButtonsInitialState()
        interactor.resendCode()
    }
    
    func configure() {
        view.setupTextLengh(lenght: interactor.expectedInputLength ?? 6 )
        view.setupPhoneLable(with: interactor.phoneNumber)
    }
    
    func timerFinishedRunning(with isShowMessageWithDropTimer: Bool) {
        if isShowMessageWithDropTimer {
            view.showError(TextConstants.timeIsUpForCode)
        }
        
        view.resendButtonShow(show: true)
        view.updateEditingState()
    }
    
    func resendButtonPressed() {
        view.resendButtonShow(show: false)
        view.updateEditingState()
        startAsyncOperationDisableScreen()
        interactor.resendCode()
        
    }
    
    func vereficationCodeEntered() {
        startAsyncOperationDisableScreen()
        interactor.verifyCode(code: currentSecurityCode)
    }
    
    func vereficationCodeNotReady() {
    }
    
    func verificationSucces() {
        interactor.authificate(atachedCaptcha: nil)
    }
    
    func verificationSilentSuccess() {
        /// empty bcz PhoneVereficationPresenter reused
    }
    
    func vereficationFailed(with error: String) {
        completeAsyncOperationEnableScreen()
        view.updateEditingState()
        view.showError(error)
    }
    
    func resendCodeRequestFailed(with error: ErrorResponse) {
        completeAsyncOperationEnableScreen()
        view.resendButtonShow(show: true)
        view.updateEditingState()
        
        if error.description == TextConstants.TOO_MANY_REQUESTS {
            view.showError(error.description)
        } else {
            view.showError(TextConstants.phoneVereficationResendRequestFailedErrorText)
        }
        
        view.dropTimer()
    }
    
    func resendCodeRequestSuccesed() {
        completeAsyncOperationEnableScreen()
        asyncOperationSuccess()
        view.setupButtonsInitialState()
        view.setupTimer(withRemainingTime: interactor.remainingTimeInSeconds)
    }
    
    func succesLogin() {
        completeAsyncOperationEnableScreen()
        view.dropTimer()
        
        openAutoSyncIfNeeded()
    }
    
    func failLogin(message: String) {
        asyncOperationSuccess()
        completeAsyncOperationEnableScreen(errorMessage: message)
    }
    
    func didRedirectToSplash() {
        completeAsyncOperationEnableScreen()
        router.showRedirectToSplash()
    }
    
    func reachedMaxAttempts() {
        view.resendButtonShow(show: true)
        view.updateEditingState()
        view.dropTimer()
    }
    
    func currentSecurityCodeChanged(with newNumeric: String) {
        currentSecurityCode.append(contentsOf: newNumeric)
    }
    
    func currentSecurityCodeRemoveCharacter() {
        if !currentSecurityCode.isEmpty {
            currentSecurityCode.removeLast()
        }
    }
    
    func clearCurrentSecurityCode() {
        currentSecurityCode = ""
    }

    
    // MARK: - Utility methods
    private func openAutoSyncIfNeeded() {
        autoSyncRoutingService.checkNeededOpenAutoSync(success: { [weak self] needToOpenAutoSync in
            self?.view.hideSpinner()

            if needToOpenAutoSync {
                self?.router.goAutoSync()
            }
        }) { [weak self] error in
            self?.view.hideSpinner()
        }
    }
    
    // MARK: - Basic Presenter override
    override func outputView() -> Waiting? {
        return view
    }
    
}
