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
        view.showErrorMessage(with: text)
        completeAsyncOperationEnableScreen()
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
                self?.isPresenting = true
                self?.router.goToSyncSettingsView()
            }
        }) { [weak self] error in
            self?.view.hideSpinner()
        }
    }
    
    private func stopOptInVC() {
        let optInController = router.optInController
        
        optInController?.stopActivityIndicator()
        optInController?.resignFirstResponder()
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
        completeAsyncOperationEnableScreen()
        tokenStorage.isClearTokens = true
        
        let action: TextEnterHandler = { [weak self] enterText, vc in
            self?.newPhone = enterText
            self?.interactor.getTokenToUpdatePhone(for: enterText)
            vc.startLoading()
        }
        
        router.openTextEnter(buttonAction: action)
    }

}

//MARK: - LoginViewOutput
extension LoginPresenter: LoginViewOutput {
    func viewIsReady() {
        startAsyncOperation()

        interactor.trackScreen()
        interactor.checkCaptchaRequerement()
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
    
    func startedEnteringPhoneNumberPlus() {
        interactor.findCoutryPhoneCode(plus: true)
    }
    
    func startedEnteringPhoneNumber() {
        interactor.findCoutryPhoneCode(plus: false)
    }
    
    func openSupport() {
        isPresenting = true
        router.openSupport()
    }
}

//MARK: - LoginInteractorOutput
extension LoginPresenter: LoginInteractorOutput {
    
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
            
        case .authenticationDisabledForAccount:
            failLogin(message: TextConstants.loginScreenAuthWithTurkcellError)
            
        case .needSignUp:
            needSignUp(message: TextConstants.loginScreenNeedSignUpError)
            
        case .incorrectUsernamePassword:
            failLogin(message: TextConstants.loginScreenCredentialsError)
            
        case .incorrectCaptcha:
            fieldError(type: .captchaIsIncorrect)
            
        case .networkError, .serverError:
            failLogin(message: errorText)
            
        case .unauthorized:
            failLogin(message: TextConstants.loginScreenCredentialsError)
            
        case .noInternetConnection:
            failLogin(message: TextConstants.errorConnectedToNetwork)
            
        case .emptyPhone:
            openEmptyPhone()
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
        let countryCode = code.isEmpty ? "+" : code
        
        if plus {
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
            view.loginFieldError(TextConstants.loginScreenInvalidLoginError)
            
        case .passwordIsEmpty:
            view.passwordFieldError(TextConstants.loginPasswordError)
            
        case .captchaIsEmpty:
            view.captchaFieldError(TextConstants.loginScreenInvalidCaptchaError)
            
        case .captchaIsIncorrect:
            view.captchaFieldError(TextConstants.invalidCaptcha)
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
    
    func successed(tokenUpdatePhone: SignUpSuccessResponse) {
        referenceToken = tokenUpdatePhone.referenceToken
        let textEnterVC = router.emptyPhoneController

        textEnterVC?.stopLoading()
        textEnterVC?.close { [weak self] in
            guard let `self` = self, let newPhone = self.newPhone else {
                return
            }
            
            self.isPresenting = true
            
            self.router.openOptIn(phone: newPhone)
            self.router.optInController?.delegate = self
        }
    }
    
    func failedUpdatePhone(errorResponse: ErrorResponse) {
        let textEnterVC = router.emptyPhoneController
        textEnterVC?.stopLoading()
        textEnterVC?.showErrorAlert(message: errorResponse.description)
    }
    
    func successed(resendUpdatePhone: SignUpSuccessResponse) {
        referenceToken = resendUpdatePhone.referenceToken
        let optInController = router.optInController

        optInController?.stopActivityIndicator()
        optInController?.setupTimer(withRemainingTime: NumericConstants.vereficationTimerLimit)
        optInController?.startEnterCode()
        optInController?.hideResendButton()
    }
    
    func failedResendUpdatePhone(errorResponse: ErrorResponse) {
        router.optInController?.stopActivityIndicator()
        router.emptyPhoneController?.showErrorAlert(message: errorResponse.description)
    }
    
    func successedVerifyPhone() {
        stopOptInVC()
        
        let popupVC = PopUpController.with(title: nil,
                                           message: TextConstants.phoneUpdatedNeedsLogin,
                                           image: .none,
                                           buttonTitle: TextConstants.ok) { vc in
                                            vc.close {
                                                AppConfigurator.logout()
                                            }
        }
        UIApplication.topController()?.present(popupVC, animated: false, completion: nil)
    }
    
    func failedVerifyPhone(errorString: String) {
        let optInController = router.optInController
        optInController?.stopActivityIndicator()
        optInController?.clearCode()
        optInController?.view.endEditing(true)
        
        if optInController?.increaseNumberOfAttemps() == false {
            let popUp = PopUpController.with(title: TextConstants.checkPhoneAlertTitle,
                                          message: TextConstants.promocodeInvalid,
                                          image: .error,
                                          buttonTitle: TextConstants.ok)
            
            optInController?.present(popUp, animated: false, completion: nil)
        }
    }
    
    func updateUserLanguageSuccess() {
        openApp()
        completeAsyncOperationEnableScreen()
    }
    
    func updateUserLanguageFailed(error: Error) {
        showMessageHideSpinner(text: error.description)
    }
    
    func captchaRequred(requred: Bool) {
        asyncOperationSuccess()
        if requred {
            captchaShowed = true
            view.showCaptcha()
        }
    }
    
    func captchaRequredFailed() {
        asyncOperationSuccess()
    }
    
    func captchaRequredFailed(with message: String) {
        asyncOperationSuccess()
        view.showErrorMessage(with: message)
    }
    
    func successedSilentLogin() {
        stopOptInVC()
    }
    
    func showSupportView() {
        view.showSupportView()
    }
}

// MARK: - OptInControllerDelegate
extension LoginPresenter: OptInControllerDelegate {
    func optInResendPressed(_ optInVC: OptInController) {
        optInVC.startActivityIndicator()
        self.router.renewOptIn(with: optInVC)
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
        self.router.renewOptIn(with: optInVC)
        interactor.verifyPhoneNumber(token: referenceToken ?? "", code: code)
    }
}
