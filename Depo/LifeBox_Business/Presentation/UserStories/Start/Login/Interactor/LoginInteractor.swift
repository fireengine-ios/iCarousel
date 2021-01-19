//
//  LoginLoginInteractor.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import WidgetKit

enum LoginFieldError {
    case loginIsNotValid
    case loginIsEmpty
    
    case passwordIsEmpty
    
    case captchaIsEmpty
}

class LoginInteractor: LoginInteractorInput {
    
    weak var output: LoginInteractorOutput?
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    private lazy var authenticationService = AuthenticationService()
    private lazy var authService = AuthenticationService()
    private lazy var contactsService = ContactService()
    private lazy var accountService = AccountService()
    private lazy var eulaService = EulaService()
    
    private let storageVars: StorageVars
    
    private var accountWarningService: AccountWarningService?

    private var rememberMe: Bool = true
    
    private var attempts: Int = 0
    
    private var loginRetries = 0 {
        didSet {
            showRelatedHelperView()
        }
    }
    
    private var login: String?
    private var password: String?
    
    private lazy var captchaService = CaptchaService()
    
    private var blockedUsers: [String : Date] {
        willSet {
            storageVars.blockedUsers = newValue
        }
    }
    
    var isShowEmptyEmail = false
    
    /// from 0 to 11 = 12 attempts
    private let maxAttemps: Int = 11
    
    init() {
        let storageVars: StorageVars = factory.resolve()
        blockedUsers = storageVars.blockedUsers
        self.storageVars = storageVars
    }
    
    //MARK: Utility Methods(private)
    
    private func showRelatedHelperView() {
        if loginRetries == NumericConstants.showFAQViewAttempts {
            output?.showFAQView()
        } else {
            #if LIFEBOX
            FirebaseRemoteConfig.shared.fetchAttemptsBeforeSupportOnLogin { [weak self] attempts in
                guard let self = self else {
                    return
                }
                
                if self.loginRetries >= attempts {
                    DispatchQueue.main.async {
                        self.output?.showSupportView()
                    }
                }
            }
            #else
            if loginRetries >= NumericConstants.showSupportViewAttempts {
                output?.showSupportView()
            }
            #endif
        }
    }
    
    private func hasEmptyPhone(accountWarning: String) -> Bool {
        return accountWarning == HeaderConstant.emptyMSISDN
    }
    
    private func hasAccountDeletedStatus(headers: [String: Any]) -> Bool {
        guard let accountStatus = headers[HeaderConstant.accountStatus] as? String else {
            return false
        }
        
        return accountStatus.uppercased() == ErrorResponseText.accountDeleted
    }
    
    private func proccessLoginHeaders(headers: [String: Any], login: String, errorHandler: @escaping (LoginResponseError, String) -> Void) {
        self.emptyEmailCheck(for: headers)
        var handler: VoidHandler?
        
        if let accountWarning = headers[HeaderConstant.accountWarning] as? String {
            /// If server returns accountWarning and accountDeletedStatus, popup is need to be shown
            if hasEmptyPhone(accountWarning: accountWarning), hasAccountDeletedStatus(headers: headers) {
                handler = {
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .email))
                    errorHandler(.emptyPhone, HeaderConstant.emptyMSISDN)
                }
            } else if self.hasAccountDeletedStatus(headers: headers) {
                handler = { [weak self] in
                    self?.processLogin(login: login, headers: headers)
                }
            } else if self.hasEmptyPhone(accountWarning: accountWarning) {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .email))
                errorHandler(.emptyPhone, HeaderConstant.emptyMSISDN)
                return
            }
        } else if self.hasAccountDeletedStatus(headers: headers) {
            handler = { [weak self] in
                self?.processLogin(login: login, headers: headers)
            }
        }
        
        if let handler = handler {
            self.output?.loginDeletedAccount(deletedAccountHandler: handler)
            
            self.analyticsService.trackCustomGAEvent(eventCategory: .popUp, eventActions: .deleteAccount, eventLabel: .login)
        } else {
            self.processLogin(login: login, headers: headers)
        }
    }
    
    private func authificate(login: String,
                             password: String,
                             atachedCaptcha: CaptchaParametrAnswer?,
                             errorHandler: @escaping (LoginResponseError, String) -> Void) {
        
        let isCaptchaRequired = atachedCaptcha != nil
        
        if login.isEmpty {
            output?.fieldError(type: .loginIsEmpty)
        }
        
        if password.isEmpty {
            output?.fieldError(type: .passwordIsEmpty)
        }
        
        let loginType: GADementionValues.login = Validator.isValid(phone: login) ? .gsm : .email
        
        if let captchaAnswer = atachedCaptcha?.answer, captchaAnswer.isEmpty {
            self.analyticsService.trackLoginEvent(loginType: loginType, error: LoginResponseError(with: ErrorResponse.string(ErrorResponseText.captchaIsEmpty)))
            output?.fieldError(type: .captchaIsEmpty)
        }
        
        if login.isEmpty || password.isEmpty || (isCaptchaRequired && (atachedCaptcha?.answer ?? "").isEmpty) {
            loginRetries += 1
            return
        }
        
        if isBlocked(userName: login) {
            output?.userStillBlocked(user: login)
            loginRetries += 1
            return
        } else if (maxAttemps <= attempts) {
            output?.allAttemtsExhausted(user: login)
            loginRetries += 1
            return
        }
        
        if !Validator.isValid(email: login) && !Validator.isValid(phone: login) {
            analyticsService.trackLoginEvent(loginType: loginType, error: .incorrectUsernamePassword)
            output?.fieldError(type: .loginIsNotValid)
            loginRetries += 1
            return
        }
        
        self.login = login
        self.password = password
        
        let user = AuthenticationUser(login: login,
                                      password: password,
                                      rememberMe: true,
                                      attachedCaptcha: atachedCaptcha)
        
        authenticationService.login(user: user, sucess: { [weak self] headers in
            guard let self = self else {
                return
            }
            
            self.proccessLoginHeaders(headers: headers, login: login, errorHandler: errorHandler)
            
        }, fail: { [weak self] errorResponse in
            let loginError = LoginResponseError(with: errorResponse)
            self?.analyticsService.trackLoginEvent(loginType: loginType, error: loginError)
            
            if Validator.isValid(email: login) {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .email))
            } else if Validator.isValid(phone: login) {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .failure, loginType: .phone))
            }
            
            
            if !(loginError == .needCaptcha || loginError == .noInternetConnection) {
                self?.loginRetries += 1
            }
            
            if loginError == .incorrectUsernamePassword {
                self?.attempts += 1
                self?.loginRetries += 1
            }
            
            errorHandler(loginError, errorResponse.description)
            
        }, twoFactorAuth: { [weak self] response in
            guard let self = self else {
                return
            }
            
            self.tokenStorage.isRememberMe = self.rememberMe
            self.output?.showTwoFactorAuthViewController(response: response)
        })
    }
    
    private func processLogin(login: String, headers: [String: Any]) {
        debugLog("login isRememberMe \(self.rememberMe)")
        self.tokenStorage.isRememberMe = self.rememberMe
        self.analyticsService.track(event: .login)
        
        if Validator.isValid(email: login) {
            self.analyticsService.trackLoginEvent(loginType: .email)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .success, loginType: .email))
        } else {
            self.analyticsService.trackLoginEvent(loginType: .gsm)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Login(status: .success, loginType: .phone))
        }
        
        self.loginRetries = 0
        
        self.accountService.updateBrandType()
        
        DispatchQueue.main.async {
            self.output?.succesLogin()
        }
    }
    
    private func isBlocked(userName: String) -> Bool {
        guard let blockedDate = blockedUsers[userName] else {
            return false
        }
        
        let currentTime = Date()
        let timeIntervalFromBlockDate = currentTime.timeIntervalSince(blockedDate)
        if timeIntervalFromBlockDate / 60 >= 60 {
            var blockedUsersDic = blockedUsers
            blockedUsersDic.removeValue(forKey: userName)
            blockedUsers = blockedUsersDic
            return false
        }
        return true
    }
    
    private func emptyEmailCheck(for headers: [String: Any]) {
        if let warning = headers[HeaderConstant.accountWarning] as? String, warning == HeaderConstant.emptyEmail {
            self.isShowEmptyEmail = true
        }
    }
    
    //MARK: LoginInteractorInput
    func authificate(login: String, password: String, atachedCaptcha: CaptchaParametrAnswer?) {
        authificate(login: login, password: password, atachedCaptcha: atachedCaptcha) { [weak self] loginError, errorText in
            
            DispatchQueue.main.async { [weak self] in
                self?.output?.processLoginError(loginError, errorText: errorText)
            }
        }
    }
        
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.LoginScreen())
        analyticsService.logScreen(screen: .loginScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .loginScreen)
    }
    
    func trackSupportSubjectEvent(type: SupportFormSubjectTypeProtocol) {
        analyticsService.trackSupportEvent(screenType: .login, subject: type, isSupportForm: false)
    }
    
    func rememberMe(state: Bool) {
        rememberMe = state
    }
    
    func blockUser(user: String) {
        attempts = 0
        if blockedUsers.count == 0 {
            blockedUsers = [user : Date()]
        } else {
            var blockedUsersDic = blockedUsers
            blockedUsersDic[user] = Date()
            blockedUsers = blockedUsersDic
        }
    }
    
    func findCoutryPhoneCode(plus: Bool) {
        let phoneCode = CoreTelephonyService().getColumnedCountryCode()
        output?.foundCoutryPhoneCode(code: phoneCode, plus: plus)
    }
    
    func checkEULA() {
        eulaService.eulaCheck(success: { [weak self] successResponse in
            DispatchQueue.main.async {
                self?.output?.onSuccessEULA()
            }
        }) { [weak self] failResponse in
            DispatchQueue.main.async {
                //TODO: what do we do on other errors?
                ///https://wiki.life.com.by/pages/viewpage.action?pageId=62456128
                if failResponse.description == "EULA_APPROVE_REQUIRED" {
                    self?.output?.onFailEULA()
                } else {
                    UIApplication.showErrorAlert(message: failResponse.description)
                }
            }
        }
        
    }
    
    func prepareTimePassed(forUserName name: String) {
//        if let blockDate = dataStorage.blockDate {
//            output.preparedTimePassed(date: blockDate)
//        }
    }
    
    func eraseBlockTime(forUserName name: String) {
//        attempts = 0
//        dataStorage.blockDate = nil
    }
    
    func updateUserLanguage() {
        authService.updateUserLanguage(Device.supportedLocale) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.output?.updateUserLanguageSuccess()
                case .failed(let error):
                    self?.output?.updateUserLanguageFailed(error: error)
                }
            }
        }
    }
    
    func checkCaptchaRequerement() {
        CaptchaSignUpRequrementService().getCaptchaRequrement { [weak self] response in
            switch response {
            case .success(let boolResult):
                self?.output?.captchaRequired(required: boolResult)
            case .failed(let error):
                if error.isServerUnderMaintenance {
                    self?.output?.captchaRequiredFailed(with: error.description)
                } else {
                    self?.output?.captchaRequiredFailed()
                }
            }
        }
        ///Implementation with old request bellow
//        captchaService.getSignUpCaptchaRequrement(sucess: { [weak self] succesResponse in
//            guard let succesResponse = succesResponse as? CaptchaSignUpRequirementResponse else {
//                self?.output?.captchaRequiredFailed()
//                return
//            }
//            self?.output?.captchaRequired(required: succesResponse.captchaRequired)
//        }) { [weak self] errorResponse in
//            self?.output?.captchaRequiredFailed()
//        }
    }
    
    func updateEmptyPhone(delegate: AccountWarningServiceDelegate) {
        accountWarningService = AccountWarningService(delegate: delegate)
        accountWarningService?.start()
    }
    
    func stopUpdatePhone() {
        accountWarningService?.stop()
    }
    
}
