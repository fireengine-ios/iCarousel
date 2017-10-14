//
//  LoginLoginPresenter.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginPresenter: BasePresenter, LoginModuleInput, LoginViewOutput, LoginInteractorOutput {
    
    weak var view: LoginViewInput!
    
    var interactor: LoginInteractorInput!
    var router: LoginRouterInput!
    
    var captchaShowed: Bool = false

    func viewIsReady() {
        interactor.prepareModels()
    }
    
    func models(models: [BaseCellModel]) {
        view.setupInitialState(array: models)
    }
    
    func sendLoginAndPasswordWithCaptcha(login: String, password: String, captchaID: String, captchaAnswer: String) {
        onLogin()
        interactor.authificate(login: login, password: password, atachedCaptcha: CaptchaParametrAnswer(uuid: captchaID, answer: captchaAnswer))
    }
    
    func sendLoginAndPassword(login: String, password: String) {
        onLogin()
        interactor.authificate(login: login, password: password, atachedCaptcha: nil)
    }
    
    private func onLogin() {
        view.hideErrorMessage()
        view.dehighlightTitles()
        startAsyncOperationDisableScreen()
    }
    
    func loginFieldIsEmpty() {
        showMessageHideSpinner(text: TextConstants.loginScreenNoLoginError)
    }
    
    func passwordFieldIsEmpty() {
        showMessageHideSpinner(text: TextConstants.loginScreenNoPasswordError)
        
    }
    
    func rememberMe(remember: Bool) {
        interactor.rememberMe(state: remember)
    }
    
    func onCantLoginButton(){
        router.goToForgotPassword()
    }
    
    func viewAppeared() {
//        interactor.prepareTimePassed()
    }
    
    func needShowCaptcha() {
        compliteAsyncOperationEnableScreen()
        captchaShowed = true
        view.showCapcha()
    }
    
    func succesLogin() {
//        asyncOperationSucces()
        
        interactor.checkEULA()
//        router.goToHomePage()
    }
    
    private func showMessageHideSpinner(text: String) {
        view.showErrorMessage(with: text)
        compliteAsyncOperationEnableScreen()
    }
    
    func failLogin(message:String) {
        
        view.highlightLoginTitle()
        view.highlightPasswordTitle()
        //FIXME: in te future change it, when we got real error handling
        var messageText = TextConstants.loginScreenCredentialsError
        if message.contains("Internet") {
            messageText = message
        }
        showMessageHideSpinner(text: messageText)
        if captchaShowed {
            view.refreshCaptcha()
        }
        
//        loginScreenNoInternetError
        
    }
    
    func startedEnteringPhoneNumberPlus() {
        interactor.findCoutryPhoneCode(plus: true)
    }
    
    func startedEnteringPhoneNumber() {
        interactor.findCoutryPhoneCode(plus: false)
    }
    
    func foundCoutryPhoneCode(code: String, plus: Bool) {
        var countryCode = code
        if code.characters.count == 0 {
            countryCode = "+"
        }
        plus ? view.enterPhoneCountryCode(countryCode: countryCode) : view.incertPhoneCountryCode(countryCode: code)
    }
    
    
    //MARK: - EULA
    
    func onSuccessEULA() {
        compliteAsyncOperationEnableScreen()
        //router.goToHomePage()
        router.goToSyncSettingsView()
    }
    
    func onFailEULA() {
        compliteAsyncOperationEnableScreen()
        router.goToTermsAndServices()
    }
    
    func allAttemtsExhausted(user: String) {
        
        showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
        interactor.blockUser(user: user)
//        view.blockUI()
    }
    
    func userStillBlocked(user: String) {
        showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
    }
    
    func preparedTimePassed(date: Date, forUserName name: String) {
        let currentTime = Date()
        let timeIntervalFromBlockDate =  currentTime.timeIntervalSince(date)
        debugPrint("time passed since block in minutes", timeIntervalFromBlockDate/60)
        if timeIntervalFromBlockDate/60 >= 60 {
//            view.unblockUI()
            interactor.eraseBlockTime(forUserName: name)
        }  else {
            showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
//            view.blockUI()
        }
        
    }
    
    //MARK : BasePresenter    
    
    override func outputView() -> Waiting? {
        return view
    }
}
