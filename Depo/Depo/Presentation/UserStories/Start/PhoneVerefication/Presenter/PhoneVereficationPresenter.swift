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
        sendVereficationCode(code: code)
    }
    
    func vereficationCodeNotReady() {
    }
    
    private func sendVereficationCode(code: String) {
        startAsyncOperationDisableScreen()
        interactor.verifyCode(code: code)
    }
    
    func nextButtonPressed(withVereficationCode vereficationCode: String) {
        sendVereficationCode(code: vereficationCode)
    }
    
    func verificationSucces() {
        interactor.authificate(atachedCaptcha: nil)
    }
    
    func vereficationFailed(with error: String) {
        view.heighlightInfoTitle()
        compliteAsyncOperationEnableScreen()
        router.presentErrorPopUp(with: error)
    }
    
    func resendCodeRequestFailed(with error: ErrorResponse) {
        compliteAsyncOperationEnableScreen()
        view.resendButtonShow(show: true)
        if error.description == TextConstants.TOO_MANY_REQUESTS {
            router.presentErrorPopUp(with: error.description)
        } else {
            router.presentErrorPopUp(with: TextConstants.phoneVereficationResendRequestFailedErrorText)
        }
        
    }
    
    func resendCodeRequestSuccesed() {
        compliteAsyncOperationEnableScreen()
        asyncOperationSucces()
        view.setupButtonsInitialState()
        view.setupTimer(withRemainingTime: interactor.remainingTimeInMinutes * 60 )
    }
    
    func succesLogin() {
        compliteAsyncOperationEnableScreen()
        view.dropTimer()
        
        CoreDataStack.default.appendLocalMediaItems(progress: { [weak self] progressPercent in
            DispatchQueue.main.async {
                self?.customProgressHUD.showProgressSpinner(progress: progressPercent)
            }
        }) { [weak self] in
            DispatchQueue.main.async {
                self?.customProgressHUD.hideProgressSpinner()
                self?.router.goAutoSync()
            }
        }
    }
    
    func failLogin(message: String) {
        asyncOperationSucces()
        compliteAsyncOperationEnableScreen(errorMessage: message)
    }
    
    func reachedMaxAttempts() {
        view.resendButtonShow(show: true)
        view.dropTimer()
    }
    
    //MARK: - Basic Presenter override
    override func outputView() -> Waiting? {
        return view
    }
    
}
