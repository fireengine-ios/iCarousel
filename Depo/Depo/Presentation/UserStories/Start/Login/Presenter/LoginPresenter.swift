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
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    var optInVC: OptInController?
    var textEnterVC: TextEnterController?
    var newPhone: String?
    var referenceToken: String?
    
    var captchaShowed: Bool = false

    private lazy var customProgressHUD = CustomProgressHUD()
    
    func viewIsReady() {
        interactor.prepareModels()
    }
    
    func models(models: [BaseCellModel]) {
        view.setupInitialState(array: models)
    }
    
    func sendLoginAndPasswordWithCaptcha(login: String, password: String, captchaID: String, captchaAnswer: String) {
        onLogin()
        
        interactor.authificate(login: removeBrackets(text: login), password: password, atachedCaptcha: CaptchaParametrAnswer(uuid: captchaID, answer: captchaAnswer))
    }
    
    private func removeBrackets(text: String) -> String {
        return text.filter { $0 != ")" && $0 != "(" }
    }
    
    func sendLoginAndPassword(login: String, password: String) {
        onLogin()
        interactor.authificate(login: removeBrackets(text: login), password: password, atachedCaptcha: nil)
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
    
    func onCantLoginButton() {
        router.goToForgotPassword()
    }
    
    func onOpenSignUp() {
        router.goToRegistration()
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
        interactor.checkEULA()
        compliteAsyncOperationEnableScreen()
    }
    
    private func showMessageHideSpinner(text: String) {
        view.showErrorMessage(with: text)
        compliteAsyncOperationEnableScreen()
    }
    
    func failLogin(message: String) {
        compliteAsyncOperationEnableScreen()
        view.highlightLoginTitle()
        view.highlightPasswordTitle()
        showMessageHideSpinner(text: message)
        if captchaShowed {
            view.refreshCaptcha()
        }
    }
    
    func needSignUp(message: String) {
        compliteAsyncOperationEnableScreen()
        view.showNeedSignUp(message: message)
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
    
    
    // MARK: - EULA
    
    func onSuccessEULA() {
        compliteAsyncOperationEnableScreen()
        CoreDataStack.default.appendLocalMediaItems(progress: { [weak self] progressPercent in
            DispatchQueue.main.async {
                self?.customProgressHUD.showProgressSpinner(progress: progressPercent)
            }
            
        }) { [weak self] in
            DispatchQueue.main.async {
                self?.customProgressHUD.hideProgressSpinner()
                self?.router.goToSyncSettingsView()
            }
        }
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
        } else {
            showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
        }
    }
    
    //MARK : BasePresenter    
    
    override func outputView() -> Waiting? {
        return view
    }
    
    func openEmptyPhone() {
        compliteAsyncOperationEnableScreen()
        tokenStorage.isClearTokens = true
        
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
        
        tokenStorage.isClearTokens = false
        
        startAsyncOperationDisableScreen()
        interactor.relogin()
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
