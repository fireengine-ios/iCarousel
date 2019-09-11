//
//  LoginLoginPresenter.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginPresenter: BasePresenter {
    weak var view: LoginViewInput!
    var interactor: LoginInteractorInput!
    var router: LoginRouterInput!
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    var newPhone: String?
    var referenceToken: String?
    var isPresenting = false
    
    var captchaShowed: Bool = false
    
    private func removeBrackets(text: String) -> String {
        return text.filter { $0 != ")" && $0 != "(" }
    }
    
    override func outputView() -> Waiting? {
        return view
    }
    
    private func onLogin() {
        view.hideErrorMessage()
        view.dehighlightTitles()
        startAsyncOperationDisableScreen()
    }
    
    private func showMessageHideSpinner(text: String) {
        completeAsyncOperationEnableScreen()
        view.showErrorMessage(with: text)
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
        AuthoritySingleton.shared.setLoginAlready(isLoginAlready: true)
        AuthoritySingleton.shared.checkNewVersionApp()
        openAutoSyncIfNeeded()
    }
    
    private func openEmptyEmail() {
        let onSuccess: VoidHandler = { [weak self] in
            self?.interactor.updateUserLanguage()
        }
        
        router.openEmptyEmail(successHandler: onSuccess)
    }
    
    private func openAutoSyncIfNeeded() {
        view.showSpinner()
        autoSyncRoutingService.checkNeededOpenAutoSync(success: { [weak self] needToOpenAutoSync in
            self?.view.hideSpinner()
            
            if needToOpenAutoSync {
                self?.router.goToSyncSettingsView()
            }
        }) { [weak self] error in
            self?.view.hideSpinner()
        }
    }
    
    private func failLogin(message: String) {
        showMessageHideSpinner(text: message)
        
        if captchaShowed {
            view.refreshCaptcha()
        }
    }
    
    private func failedBlockError() {
        completeAsyncOperationEnableScreen()
        view.failedBlockError()
    }
    
    private func openEmptyPhone() {
        interactor.updateEmptyPhone(delegate: self)
    }
    
    func loginDeletedAccount(deletedAccountHandler: @escaping VoidHandler) {
        completeAsyncOperationEnableScreen()

        let image = UIImage(named: "Path")
        let title = TextConstants.accountStatusTitle
        
        let titleFullAttributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.TurkcellSaturaFont(size: 18),
            .foregroundColor : UIColor.black,
            .kern : 0
        ]
        
        let message = TextConstants.accountStatusMessage
        
        let messageParagraphStyle = NSMutableParagraphStyle()
        messageParagraphStyle.paragraphSpacing = 8
        messageParagraphStyle.alignment = .center
        
        let messageFullAttributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.TurkcellSaturaMedFont(size: 16),
            .foregroundColor : ColorConstants.blueGrey,
            .paragraphStyle : messageParagraphStyle,
            .kern : 0
        ]
        
        router.showAccountStatePopUp(image: .custom(image),
                                     title: title,
                                     titleDesign: .partly(parts: [title : titleFullAttributes]),
                                     message: message,
                                     messageDesign: .partly(parts: [message : messageFullAttributes]),
                                     buttonTitle: TextConstants.ok,
                                     buttonAction: deletedAccountHandler)
    }

}

//MARK: - LoginViewOutput
extension LoginPresenter: LoginViewOutput {
    func viewIsReady() {
        startAsyncOperation()

        interactor.trackScreen()
        interactor.checkCaptchaRequerement()
    }
    
    func prepareCaptcha(_ view: CaptchaView) {
        view.delegate = self
    }
    
    func rememberMe(remember: Bool) {
        interactor.rememberMe(state: remember)
    }
    
    func sendLoginAndPassword(login: String, password: String) {
        onLogin()
        interactor.authificate(login: removeBrackets(text: login), password: password, atachedCaptcha: nil)
    }
    
    func sendLoginAndPasswordWithCaptcha(login: String, password: String, captchaID: String, captchaAnswer: String) {
        onLogin()
        
        let atachedCaptcha = CaptchaParametrAnswer(uuid: captchaID, answer: captchaAnswer)
        interactor.authificate(login: removeBrackets(text: login),
                               password: password,
                               atachedCaptcha: atachedCaptcha)
    }
    
    func onForgotPasswordTap() {
        isPresenting = true
        router.goToForgotPassword()
    }
    
    func startedEnteringPhoneNumber(withPlus: Bool) {
        interactor.findCoutryPhoneCode(plus: withPlus)
    }
    
    func openSupport() {
        isPresenting = true
        router.openSupport()
    }
}

//MARK: - LoginInteractorOutput
extension LoginPresenter: LoginInteractorOutput {
    
    func showTwoFactorAuthViewController(response: TwoFactorAuthErrorResponse) {
        completeAsyncOperationEnableScreen()
        isPresenting = true
        router.goToTwoFactorAuthViewController(response: response)
    }
    
    func succesLogin() {
        tokenStorage.isClearTokens = false
        MenloworksTagsService.shared.onStartWithLogin(true)
        interactor.checkEULA()
    }

    func processLoginError(_ loginError: LoginResponseError, errorText: String) {
        
        switch loginError {
        case .block:
            failedBlockError()
            
        case .needCaptcha:
            needShowCaptcha()
            failLogin(message: TextConstants.captchaRequired)
            
        case .authenticationDisabledForAccount:
            failLogin(message: TextConstants.loginScreenAuthWithTurkcellError)
            
        case .needSignUp:
            needSignUp(message: TextConstants.loginScreenNeedSignUpError)
            
        case .incorrectUsernamePassword:
            failLogin(message: TextConstants.loginScreenCredentialsError)
            
        case .incorrectCaptcha:
            failLogin(message: TextConstants.invalidCaptcha)
            
        case .networkError:
            failLogin(message: errorText)
            
        case .unauthorized:
            failLogin(message: TextConstants.loginScreenCredentialsError)
            
        case .noInternetConnection:
            failLogin(message: TextConstants.errorConnectedToNetwork)
            
        case .emptyPhone:
            completeAsyncOperationEnableScreen()
            openEmptyPhone()
            
        case .serverError:
            failLogin(message: TextConstants.loginScreenServerError)
        }
        
    }
    
    func needSignUp(message: String) {
        completeAsyncOperationEnableScreen()
        let onClose = { [weak self] in
            self?.isPresenting = true
            self?.router.goToRegistration()
        }
        router.showNeedSignUp(message: message, onClose: onClose)
    }
    
    func needShowCaptcha() {
        completeAsyncOperationEnableScreen()
        captchaShowed = true
        view.showCaptcha()
    }
    
    func foundCoutryPhoneCode(code: String, plus: Bool) {
        if plus {
            let countryCode = code.isEmpty ? "+" : code
            view.enterPhoneCountryCode(countryCode: countryCode)
        } else {
            view.insertPhoneCountryCode(countryCode: code)
        }
    }
    
    func fieldError(type: LoginFieldError) {
        completeAsyncOperationEnableScreen()
        
        switch type {
        case .loginIsEmpty:
            view.loginFieldError(TextConstants.loginEmailOrPhoneError)
            
        case .loginIsNotValid:
            view.loginFieldError(TextConstants.loginUsernameNotValid)
            
        case .passwordIsEmpty:
            view.passwordFieldError(TextConstants.loginPasswordError)
            
        case .captchaIsEmpty:
            view.captchaFieldError(TextConstants.captchaIsEmpty)
        }
    }
    
    // MARK: EULA
    func onSuccessEULA() {
        openEmptyEmailIfNeedOrOpenSyncSettings()
    }
    
    func onFailEULA() {
        completeAsyncOperationEnableScreen()
        router.goToTermsAndServices()
    }

    func allAttemtsExhausted(user: String) {
        completeAsyncOperationEnableScreen()
        view.refreshCaptcha()
        interactor.blockUser(user: user)
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
    
    func userStillBlocked(user: String) {
        completeAsyncOperationEnableScreen()
        view.refreshCaptcha()
        showMessageHideSpinner(text: TextConstants.hourBlockLoginError)
    }
    
    func successedVerifyPhone() {        
        router.showPhoneVerifiedPopUp { [weak self] in
            self?.interactor.stopUpdatePhone()
        }
    }
    
    func updateUserLanguageSuccess() {
        openApp()
        completeAsyncOperationEnableScreen()
    }
    
    func updateUserLanguageFailed(error: Error) {
        showMessageHideSpinner(text: error.description)
    }
    
    func captchaRequired(required: Bool) {
        asyncOperationSuccess()

        if required {
            captchaShowed = true
            view.showCaptcha()
        }
    }
    
    func captchaRequiredFailed() {
        asyncOperationSuccess()
    }
    
    func captchaRequiredFailed(with message: String) {
        asyncOperationSuccess()
        view.showErrorMessage(with: message)
    }
    
    func showSupportView() {
        view.showSupportView()
    }
}

// MARK: - CaptchaViewErrorDelegate

extension LoginPresenter: CaptchaViewErrorDelegate {
    
    func showCaptchaError(error: Error) {
        
        view.showErrorMessage(with: error.description)
    }
}

// MARK: - AccountWarningServiceDelegate

extension LoginPresenter: AccountWarningServiceDelegate {
    func successedSilentLogin() {
        succesLogin()
    }
    
    func needToRelogin() {
        interactor.tryToRelogin()
    }
    
}
