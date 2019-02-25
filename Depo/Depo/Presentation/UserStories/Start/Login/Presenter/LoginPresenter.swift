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
    private lazy var storageVars: StorageVars = factory.resolve()
    private let routerVC = RouterVC()
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    var optInVC: OptInController?
    var textEnterVC: TextEnterController?
    var newPhone: String?
    var referenceToken: String?
    
    var captchaShowed: Bool = false

    private lazy var customProgressHUD = CustomProgressHUD()
    
    func viewIsReady() {
        interactor.prepareModels()
        interactor.trackScreen()
        startAsyncOperation()
        interactor.checkCaptchaRequerement()
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
        completeAsyncOperationEnableScreen()
        view.showInfoButton(in: .login)
    }
    
    func passwordFieldIsEmpty() {
        completeAsyncOperationEnableScreen()
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
    
    func viewAppeared() {}
    
    func captchaRequred(requred: Bool) {
        asyncOperationSucces()
        if requred {
            captchaShowed = true
            view.showCapcha()
        }
    }
    
    func captchaRequredFailed() {
        asyncOperationSucces()
    }
    
    func needShowCaptcha() {
        completeAsyncOperationEnableScreen()
        captchaShowed = true
        view.showCapcha()
    }
    
    func failedBlockError() {
        completeAsyncOperationEnableScreen()
        view.failedBlockError()
    }
    
    func succesLogin() {
        MenloworksTagsService.shared.onStartWithLogin(true)
        interactor.checkEULA()
    }
    
    private func showMessageHideSpinner(text: String) {
        view.showErrorMessage(with: text)
        completeAsyncOperationEnableScreen()
    }
    
    func failLogin(message: String) {
        completeAsyncOperationEnableScreen()
        view.highlightLoginTitle()
        view.highlightPasswordTitle()
        showMessageHideSpinner(text: message)
        if captchaShowed {
            view.refreshCaptcha()
        }
    }
    
    func needSignUp(message: String) {
        completeAsyncOperationEnableScreen()
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
        openEmptyEmailIfNeedOrOpenSyncSettings()
    }
    
    func onFailEULA() {
        completeAsyncOperationEnableScreen()
        router.goToTermsAndServices()
    }
    
    private func openEmptyEmailIfNeedOrOpenSyncSettings() {
        if interactor.isShowEmptyEmail {
            completeAsyncOperationEnableScreen()
            openEmptyEmail()
        } else {
            interactor.updateUserLanguage()
        }
    }
    
    private func openApp() {
        storageVars.emptyEmailUp = false
        AuthoritySingleton.shared.setLoginAlready(isLoginAlready: true)
        openAutoSyncIfNeeded()
    }
    
    private func openEmptyEmail() {
        storageVars.emptyEmailUp = true
        let vc = EmailEnterController.initFromNib()
        vc.approveCancelHandler = { [weak self] in
            self?.interactor.updateUserLanguage()
        }
        let navVC = NavigationController(rootViewController: vc)
        routerVC.presentViewController(controller: navVC)
    }
    
    private func openAutoSyncIfNeeded() {
        view.showSpiner()
        autoSyncRoutingService.checkNeededOpenAutoSync(success: { [weak self] needToOpenAutoSync in
            self?.view.hideSpiner()
            
            if needToOpenAutoSync {
                self?.router.goToSyncSettingsView()
            }
        }) { [weak self] error in
            self?.view.hideSpiner()

            self?.view.showErrorMessage(with: error.description)
        }
    }
    
    func allAttemtsExhausted(user: String) {
        completeAsyncOperationEnableScreen()
        showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
        interactor.blockUser(user: user)
    }
    
    func userStillBlocked(user: String) {
        completeAsyncOperationEnableScreen()
        showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
    }
    
    func preparedTimePassed(date: Date, forUserName name: String) {
        let currentTime = Date()
        let timeIntervalFromBlockDate = currentTime.timeIntervalSince(date)
        debugPrint("time passed since block in minutes", timeIntervalFromBlockDate / 60)
        if timeIntervalFromBlockDate / 60 >= 60 {
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
        completeAsyncOperationEnableScreen()
        tokenStorage.isClearTokens = true
        
        let textEnterVC = TextEnterController.with(
            title: TextConstants.loginAddGSM,
            buttonTitle: TextConstants.save) { [weak self] enterText, vc in
                self?.newPhone = enterText
                self?.interactor.getTokenToUpdatePhone(for: enterText)
                vc.startLoading()
        }
        self.textEnterVC = textEnterVC
        let navVC = NavigationController(rootViewController: textEnterVC)
        routerVC.presentViewController(controller: navVC)
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
            self?.routerVC.pushViewController(viewController: optInVC)
        }
    }
    
    func failedUpdatePhone(errorResponse: ErrorResponse) {
        textEnterVC?.stopLoading()
        textEnterVC?.showErrorAlert(message: errorResponse.description)
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
        textEnterVC?.showErrorAlert(message: errorResponse.description)
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
    
    func updateUserLanguageSuccess() {
        openApp()
        completeAsyncOperationEnableScreen()
    }
    
    func updateUserLanguageFailed(error: Error) {
        view.showErrorMessage(with: error.description)
        completeAsyncOperationEnableScreen()
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
