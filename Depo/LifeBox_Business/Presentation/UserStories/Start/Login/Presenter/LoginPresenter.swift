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
        startAsyncOperationDisableScreen()
    }
    
    private func showMessageHideSpinner(text: String) {
        completeAsyncOperationEnableScreen()
        view.showErrorMessage(with: text)
    }

    private func showErrorAlertHideSpinner(with title: String?, and subtitle: String?) {
        completeAsyncOperationEnableScreen()
        view.showErrorAlert(with: title, and: subtitle)
    }
    
    private func openEmptyEmailIfNeedOrOpenSyncSettings() {
            interactor.updateUserLanguage()
    }
    
    private func openApp() {
        AuthoritySingleton.shared.setLoginAlready(isLoginAlready: true)
        AuthoritySingleton.shared.checkNewVersionApp()
        router.goToHomePage()
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
    
    func rememberMe(remember: Bool) {
        interactor.rememberMe(state: remember)
    }

    func authenticateWith(flToken: String) {
        onLogin()
        interactor.authenticate(with: flToken)
    }
    
    func sendLoginAndPassword(login: String, password: String, rememberMe: Bool) {
        onLogin()
        interactor.authificate(login: removeBrackets(text: login),
                               password: password,
                               rememberMe: rememberMe,
                               atachedCaptcha: nil)
    }
    
    func sendLoginAndPasswordWithCaptcha(login: String, password: String, rememberMe: Bool, captchaID: String, captchaAnswer: String) {
        onLogin()
        
        let atachedCaptcha = CaptchaParametrAnswer(uuid: captchaID, answer: captchaAnswer)
        interactor.authificate(login: removeBrackets(text: login),
                               password: password,
                               rememberMe: rememberMe,
                               atachedCaptcha: atachedCaptcha)
    }
    
    func openSupport() {
        isPresenting = true
        router.openSupport()
    }
    
    func openFaqSupport() {
        isPresenting = true
        router.goToFaqSupportPage()
    }
    
    func openSubjectDetails(type: SupportFormSubjectTypeProtocol) {
        interactor.trackSupportSubjectEvent(type: type)
        isPresenting = true
        router.goToSubjectDetailsPage(type: type)
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
        interactor.checkEULA()
    }

    func processLoginError(_ loginError: LoginResponseError, errorText: String) {
        switch loginError {
        case .block, .errorCode10:
            failedBlockError()
            
        case .needCaptcha:
            needShowCaptcha()
            failLogin(message: TextConstants.captchaRequired)
            
        case .authenticationDisabledForAccount:
            failLogin(message: TextConstants.loginScreenAuthWithTurkcellError)
            
        case .needSignUp:
            debugLog("processLoginError:  .needSignUp this error should be impossible")
            failLogin(message: TextConstants.loginScreenServerError)
            
        case .incorrectUsernamePassword:
            failLogin(message: TextConstants.loginPageErrorCode30)
            
        case .incorrectCaptcha:
            completeAsyncOperationEnableScreen()
            view.refreshCaptcha()
            view.captchaFieldError(TextConstants.loginPageInvalidCaptchaFieldError)
            
        case .networkError:
            failLogin(message: errorText)
            
        case .unauthorized, .errorCode401, .errorCode0, .errorCode30:
            failLogin(message: TextConstants.loginPageErrorCode30)
            
        case .errorCode4201:
            failLogin(message: TextConstants.loginPageBlockedIpError)
            
        case .errorCode31:
            failLogin(message: TextConstants.loginPageErrorCode31)
            
        case .errorCode32:
            failLogin(message: TextConstants.loginPageErrorCode32)
            
        case .errorCode33:
            failLogin(message: TextConstants.loginPageErrorCode33)
            
        case .noInternetConnection:
            failLogin(message: TextConstants.errorConnectedToNetwork)
            
        case .emptyPhone:
            completeAsyncOperationEnableScreen()
            debugLog("processLoginError:  .emptyPhone this error should be impossible")
//            openEmptyPhone()
            
        case .emptyCaptcha:
            view.captchaFieldError(TextConstants.loginPageEmptyCaptchaFieldError)
            
        case .serverError:
            failLogin(message: TextConstants.loginScreenServerError)
            
        case .genericError:
            failLogin(message: TextConstants.loginGenericError)
            
        case .emptyEmail:
            debugLog("processLoginError:  .emptyEmail this error should be impossible")
            failLogin(message: TextConstants.loginPageEmptyLoginFieldError)
            completeAsyncOperationEnableScreen()
//            openEmptyEmail()
        case .flAuthFailure:
            showErrorAlertHideSpinner(with: TextConstants.flLoginErrorPopupTitle, and: TextConstants.flLoginAuthFailure)
        case .flNotInPool:
            showErrorAlertHideSpinner(with: TextConstants.flLoginErrorPopupTitle, and: TextConstants.flLoginUserNotInPool)
        }
    }
    
    func needShowCaptcha() {
        completeAsyncOperationEnableScreen()
        captchaShowed = true
        view.showCaptcha()
    }
    
    func fieldError(type: LoginFieldError) {
        completeAsyncOperationEnableScreen()
        
        switch type {
        case .loginIsEmpty:
            view.loginFieldError(TextConstants.loginPageEmptyLoginFieldError)
            
        case .loginIsNotValid:
            view.loginFieldError(TextConstants.loginPageInvalidLoginFieldError)
            
        case .passwordIsEmpty:
            view.passwordFieldError(TextConstants.loginPageEmptyPasswordFieldError)
            
        case .captchaIsEmpty:
            view.captchaFieldError(TextConstants.loginPageEmptyCaptchaFieldError)
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
}

// MARK: - AccountWarningServiceDelegate

extension LoginPresenter: AccountWarningServiceDelegate {
    func successedSilentLogin() {
        succesLogin()
    }
    
    func needToRelogin() {
        debugLog("needToRelogin, no silent login after phone update")
//        interactor.tryToRelogin()
    }
    
}
