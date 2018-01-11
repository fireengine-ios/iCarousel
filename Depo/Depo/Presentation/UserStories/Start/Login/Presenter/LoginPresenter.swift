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
    
    var optInVC: OptInController?
    var textEnterVC: TextEnterController?
    var newPhone: String?
    var referenceToken: String?
    
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
        compliteAsyncOperationEnableScreen()
        view.showInfoButton(in: .login)
    }
    
    func passwordFieldIsEmpty() {
        compliteAsyncOperationEnableScreen()
        view.showInfoButton(in: .password)
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
    
    func failedBlockError() {
        compliteAsyncOperationEnableScreen()
        view.failedBlockError()
    }
    
    func succesLogin() {
        compliteAsyncOperationEnableScreen()
        interactor.getAccountInfo()
        

//        router.goToHomePage()
    }
    
    private func showMessageHideSpinner(text: String) {
        view.showErrorMessage(with: text)
        compliteAsyncOperationEnableScreen()
    }
    
    func failLogin(message:String) {
        compliteAsyncOperationEnableScreen()
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
        if code.count == 0 {
            countryCode = "+"
        }
        plus ? view.enterPhoneCountryCode(countryCode: countryCode) : view.incertPhoneCountryCode(countryCode: code)
    }
    
    
    //MARK: - EULA
    
    func onSuccessEULA() {
        compliteAsyncOperationEnableScreen()
        router.goToSyncSettingsView()
    }
    
    func onFailEULA() {
        compliteAsyncOperationEnableScreen()
        router.goToTermsAndServices()
    }
    
    func allAttemtsExhausted(user: String) {
        compliteAsyncOperationEnableScreen()
        showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
        interactor.blockUser(user: user)
    }
    
    func userStillBlocked(user: String) {
        compliteAsyncOperationEnableScreen()
        showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
    }
    
    func preparedTimePassed(date: Date, forUserName name: String) {
        let currentTime = Date()
        let timeIntervalFromBlockDate =  currentTime.timeIntervalSince(date)
        debugPrint("time passed since block in minutes", timeIntervalFromBlockDate/60)
        if timeIntervalFromBlockDate/60 >= 60 {
            interactor.eraseBlockTime(forUserName: name)
        }  else {
            showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
        }
        
    }
    
    //MARK : BasePresenter    
    
    override func outputView() -> Waiting? {
        return view
    }
    
    private func isPhoneNumberEmpty(for accountInfo: AccountInfoResponse) -> Bool {
        return accountInfo.phoneNumber == nil || accountInfo.phoneNumber?.isEmpty == true
    }
    
    func successed(accountInfo: AccountInfoResponse) {
        compliteAsyncOperationEnableScreen()
        
        if isPhoneNumberEmpty(for: accountInfo) {
            
            let textEnterVC = TextEnterController.with(
                title: TextConstants.loginEnterGSM,
                textPlaceholder: TextConstants.loginGSMNumber,
                buttonTitle: TextConstants.save) { [weak self] enterText, vc in
                    self?.newPhone = enterText
                    self?.interactor.getTokenToUpdatePhone(for: enterText)
                    vc.startLoading()
            }
            self.textEnterVC = textEnterVC
            RouterVC().presentViewController(controller: textEnterVC)
            
        } else {
            ApplicationSession.sharedSession.saveData()
            interactor.checkEULA()
        }
    }
    
    func failedAccountInfo(errorResponse: ErrorResponse) {
        compliteAsyncOperationEnableScreen()
    }
    
    func successed(tokenUpdatePhone: SignUpSuccessResponse) {
        referenceToken = tokenUpdatePhone.referenceToken
        textEnterVC?.stopLoading()
        textEnterVC?.close { [weak self] in
            guard let newPhone = self?.newPhone else {
                return
            }
            let optInVC = OptInController.with(phone: newPhone)
            self?.optInVC = optInVC
            optInVC.delegate = self
            RouterVC().pushViewController(viewController: optInVC)
        }
    }
    
    func failedUpdatePhone(errorResponse: ErrorResponse) {
        textEnterVC?.stopLoading()
        textEnterVC?.showAlertMessage(with: errorResponse.description)
    }
    
    func successed(resendUpdatePhone: SignUpSuccessResponse) {
        referenceToken = resendUpdatePhone.referenceToken
        optInVC?.stopActivityIndicator()
        optInVC?.setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        optInVC?.startEnterCode()
        optInVC?.hideResendButton()
    }
    
    func failedResendUpdatePhone(errorResponse: ErrorResponse) {
        optInVC?.stopActivityIndicator()
        textEnterVC?.showAlertMessage(with: errorResponse.description)
    }
    
    func successedVerifyPhone() {
        optInVC?.stopActivityIndicator()
        optInVC?.resignFirstResponder()
        
        ApplicationSession.sharedSession.saveData()
        
        startAsyncOperationDisableScreen()
        interactor.checkEULA()
    }
    
    func failedVerifyPhone(errorString: String) {
        optInVC?.stopActivityIndicator()
        optInVC?.clearCode()
        optInVC?.view.endEditing(true)
    
        if optInVC?.increaseNumberOfAttemps() == false {
            let vc = PopUpController.with(title: TextConstants.checkPhoneAlertTitle, message: TextConstants.promocodeInvalid, image: .error, buttonTitle: TextConstants.ok)
            optInVC?.present(vc, animated: false, completion: nil)
        }
    }
}





// MARK: - OptInControllerDelegate
extension LoginPresenter: OptInControllerDelegate {
    func optInResendPressed(_ optInVC: OptInController) {
        optInVC.startActivityIndicator()
        self.optInVC = optInVC
        if let newPhone = newPhone {
            interactor.getResendTokenToUpdatePhone(for: newPhone)
        }
    }

    func optInReachedMaxAttempts(_ optInVC: OptInController) {
        optInVC.showResendButton()
        optInVC.dropTimer()
        UIApplication.showErrorAlert(message: TextConstants.promocodeBlocked)
    }

    func optInNavigationTitle() -> String {
        return TextConstants.confirmPhoneOptInNavigarionTitle
    }

    func optIn(_ optInVC: OptInController, didEnterCode code: String) {
        optInVC.startActivityIndicator()
        self.optInVC = optInVC
        interactor.verifyPhoneNumber(token: referenceToken ?? "", code: code)
    }
}
