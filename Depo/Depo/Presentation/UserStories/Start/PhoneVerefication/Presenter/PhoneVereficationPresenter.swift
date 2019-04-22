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

    private lazy var customProgressHUD = CustomProgressHUD()
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    func viewIsReady() {
        interactor.trackScreen()
        view.setupInitialState()
        configure()
        view.setupButtonsInitialState()
    }
    
    func configure() {
        view.setupTimer(withRemainingTime: interactor.remainingTimeInMinutes * 60 )
        view.setupTextLengh(lenght: interactor.expectedInputLength ?? 6 )
        view.setupPhoneLable(with: interactor.phoneNumber)
    }
    
    func timerFinishedRunning() {
        view.resendButtonShow(show: true)
    }
    
    func resendButtonPressed() {
        view.resendButtonShow(show: false)
        startAsyncOperationDisableScreen()
        interactor.resendCode()
        
    }
    
    func vereficationCodeEntered(code: String) {
        startAsyncOperationDisableScreen()
        interactor.verifyCode(code: code)
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
        view.heighlightInfoTitle()
        completeAsyncOperationEnableScreen()
        router.presentErrorPopUp(with: error)
    }
    
    func resendCodeRequestFailed(with error: ErrorResponse) {
        completeAsyncOperationEnableScreen()
        view.resendButtonShow(show: true)
        if error.description == TextConstants.TOO_MANY_REQUESTS {
            router.presentErrorPopUp(with: error.description)
        } else {
            router.presentErrorPopUp(with: TextConstants.phoneVereficationResendRequestFailedErrorText)
        }
        
    }
    
    func resendCodeRequestSuccesed() {
        completeAsyncOperationEnableScreen()
        asyncOperationSuccess()
        view.setupButtonsInitialState()
        view.setupTimer(withRemainingTime: interactor.remainingTimeInMinutes * 60 )
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
        view.dropTimer()
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
