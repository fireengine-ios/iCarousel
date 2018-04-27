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
    
    func viewIsReady() {
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
        asyncOperationSucces()
        view.setupButtonsInitialState()
        view.setupTimer(withRemainingTime: interactor.remainingTimeInMinutes * 60 )
    }
    
    func succesLogin() {
        completeAsyncOperationEnableScreen()
        view.dropTimer()
        
//        CoreDataStack.default.appendLocalMediaItems(completion: nil)
        router.goAutoSync()
    }
    
    func failLogin(message: String) {
        asyncOperationSucces()
        completeAsyncOperationEnableScreen(errorMessage: message)
    }
    
    func didRedirectToSplash() {
        router.showRedirectToSplash()
    }
    
    func reachedMaxAttempts() {
        view.resendButtonShow(show: true)
        view.dropTimer()
    }
    
    // MARK: - Basic Presenter override
    override func outputView() -> Waiting? {
        return view
    }
    
}
