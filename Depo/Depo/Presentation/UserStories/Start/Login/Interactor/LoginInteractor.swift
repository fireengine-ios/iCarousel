//
//  LoginLoginInteractor.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginInteractor: LoginInteractorInput {
    
    weak var output: LoginInteractorOutput?
    
    private var dataStorage = LoginDataStorage()
    private let authService = AuthenticationService()
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var authenticationService = AuthenticationService()
    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var eulaService = EulaService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var periodicContactSyncDataStorage = PeriodicContactSyncDataStorage()
    private let contactsService = ContactService()
    
    private var rememberMe: Bool = true
    private var attempts: Int = 0
    
    private var login: String?
    private var password: String?
    private var atachedCaptcha: CaptchaParametrAnswer?
    private lazy var captchaService = CaptchaService()
    private let cacheManager = CacheManager.shared
    
    var isShowEmptyEmail = false
    
    /// from 0 to 11 = 12 attempts
    private let maxAttemps: Int = 11
    
    func prepareModels() {
        output?.models(models: dataStorage.getModels())
    }
    
    func rememberMe(state: Bool) {
        rememberMe = state
    }
    
    func authificate(login: String, password: String, atachedCaptcha: CaptchaParametrAnswer?) {
        
        if login.isEmpty {
            output?.loginFieldIsEmpty()
        }
        if password.isEmpty {
            output?.passwordFieldIsEmpty()
        }
        if login.isEmpty || password.isEmpty {
            return
        }
        
        if isBlocked(userName: login) {
            output?.userStillBlocked(user: login)
            return
        } else if (maxAttemps <= attempts) {
            output?.allAttemtsExhausted(user: login)//block here
            return
        }
        if !Validator.isValid(email: login) && !Validator.isValid(phone: login) {
            output?.failLogin(message: TextConstants.loginScreenInvalidLoginError)
            return
        }
        
        let user = AuthenticationUser(login: login,
                                      password: password,
                                      rememberMe: true, //rememberMe,
                                      attachedCaptcha: atachedCaptcha)
        
        authenticationService.login(user: user, sucess: { [weak self] headers in
            guard let `self` = self else {
                return
            }
            
            self.setContactSettingsForUser()
            
            self.emptyEmailCheck(for: headers)
            
            debugLog("login isRememberMe \(self.rememberMe)")
            self.tokenStorage.isRememberMe = self.rememberMe
            self.analyticsService.track(event: .login)
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .trueLogin)
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .clickOtherTurkcellServices, eventLabel: .clickOtherTurkcellServices)
            self.cacheManager.actualizeCache(completion: nil)
            DispatchQueue.main.async {
                self.output?.succesLogin()
            }
        }, fail: { [weak self] errorResponse  in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .login, eventLabel: .falseLogin)
                
                if self.isBlockError(forResponse: errorResponse) {
                    self.output?.failedBlockError()
                    return
                }
                if self.inNeedOfCaptcha(forResponse: errorResponse) {
                    self.output?.needShowCaptcha()
                } else if (!self.checkInternetConnection()) {
                    self.output?.failLogin(message: TextConstants.errorConnectedToNetwork)
                } else if self.isAuthenticationDisabledForAccount(forResponse: errorResponse) {
                    self.output?.failLogin(message: TextConstants.loginScreenAuthWithTurkcellError)
                } else if self.isNeedSignUp(forResponse: errorResponse) {
                    self.output?.needSignUp(message: TextConstants.loginScreenNeedSignUpError)
                } else if self.isAuthenticationError(forResponse: errorResponse) || self.inNeedOfCaptcha(forResponse: errorResponse) {
                    self.attempts += 1
                    self.output?.failLogin(message: TextConstants.loginScreenCredentialsError)
                } else if self.isInvalidCaptchaError(forResponse: errorResponse) {
                    self.output?.failLogin(message: TextConstants.loginScreenInvalidCaptchaError)
                } else if self.isInternetError(forResponse: errorResponse) {
                    self.output?.failLogin(message: errorResponse.description)
                } else if self.isEmptyPhoneError(for: errorResponse) {
                    self.login = login
                    self.password = password
                    self.atachedCaptcha = atachedCaptcha
                    self.output?.openEmptyPhone()
                } else {
                    self.output?.failLogin(message: TextConstants.loginScreenCredentialsError)
                }
            }
        })
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .loginScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .loginScreen)
    }
    
    private func setContactSettingsForUser() {
        guard let contactSettings = storageVars.usersWhoUsedApp[SingletonStorage.shared.uniqueUserID] as? [String: Bool] else {
            return
        }
        
        let contactSyncSettings = PeriodicContactsSyncSettings(with: contactSettings)
        periodicContactSyncDataStorage.save(periodicContactSyncSettings: contactSyncSettings)
        contactsService.setPeriodicForContactsSync(periodic: contactSyncSettings.syncPeriodic)
    }
    
    func relogin() {
        if let login = login, let password = password {
            authificate(login: login, password: password, atachedCaptcha: atachedCaptcha)
        }
    }
    
    func blockUser(user: String) {
        attempts = 0
        if let blockedUsers = dataStorage.blockedUsers {
            let blockedUsersDic = NSMutableDictionary(dictionary: blockedUsers)
            blockedUsersDic[user] = Date()
            dataStorage.blockedUsers = blockedUsersDic
        } else {
            dataStorage.blockedUsers = [user: Date()]
        }
    }
    
    private func isBlocked(userName: String) -> Bool {
        guard let blockedUsers = dataStorage.blockedUsers, let blokedDate = blockedUsers[userName] as? Date else {
            return false
        }
        
        let currentTime = Date()
        let timeIntervalFromBlockDate = currentTime.timeIntervalSince(blokedDate)
        if timeIntervalFromBlockDate / 60 >= 60 {
            let blockedUsersDic = NSMutableDictionary(dictionary: blockedUsers)
            blockedUsersDic.removeObject(forKey: userName)
            dataStorage.blockedUsers = blockedUsersDic
            return false
        }
        return true
    }
    
    private func inNeedOfCaptcha(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Captcha required")
    }
    
    private func isAuthenticationDisabledForAccount(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Authentication with Turkcell Password is disabled for the account")
    }
    
    private func isNeedSignUp(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Sign up required")
    }
    
    private func isAuthenticationError(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Authentication failure")
    }
    
    private func isInvalidCaptchaError(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Invalid captcha")
    }
    
    private func isInternetError(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Internet")
    }
    
    private func isBlockError(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("LDAP account is locked")
    }
    
    private func isEmptyPhoneError(for errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains(HeaderConstant.emptyMSISDN)
    }
    
    private func checkInternetConnection() -> Bool {
        return ReachabilityService().isReachable
    }
    
    private func emptyEmailCheck(for headers: [String: Any]) {
        if let warning = headers[HeaderConstant.accountWarning] as? String, warning == HeaderConstant.emptyEmail {
            self.isShowEmptyEmail = true
        }
    }
    
    func findCoutryPhoneCode(plus: Bool) {
        let telephonyService = CoreTelephonyService()
        var phoneCode = telephonyService.callingCountryCode()
        
        if phoneCode == "" || UIDevice.current.modelName == "iPad Pro 12.9 Inch 2. Generation" || UIDevice.current.modelName == "iPad Pro 10.5 Inch" || UIDevice.current.modelName == "iPad Pro 9.7 Inch"{
            phoneCode = telephonyService.countryCodeByLang()
        }
        
        phoneCode.insert("(", at: phoneCode.index(after: phoneCode.startIndex))
        phoneCode.insert(")", at: phoneCode.endIndex)
        output?.foundCoutryPhoneCode(code: phoneCode, plus: plus)
    }
    
    func checkEULA() {
        eulaService.eulaCheck(success: { [weak self] succesResponce in
            DispatchQueue.main.async {
                self?.output?.onSuccessEULA()
            }
        }) { [weak self] failResponce in
            DispatchQueue.main.async {
                //TODO: what do we do on other errors?
                ///https://wiki.life.com.by/pages/viewpage.action?pageId=62456128
                if failResponce.description == "EULA_APPROVE_REQUIRED" {
                    self?.output?.onFailEULA()
                } else {
                    UIApplication.showErrorAlert(message: failResponce.description)
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
    
    let accountService = AccountService()
    
    func getTokenToUpdatePhone(for phoneNumber: String) {
        let parameters = UserPhoneNumberParameters(phoneNumber: phoneNumber)
        accountService.updateUserPhone(parameters: parameters, success: { [weak self] responce in
            guard let signUpResponce = responce as? SignUpSuccessResponse else {
                return
            }
            DispatchQueue.main.async {
                self?.output?.successed(tokenUpdatePhone: signUpResponce)
            }
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.failedUpdatePhone(errorResponse: error)
            }
        })
    }
    
    func getResendTokenToUpdatePhone(for phoneNumber: String) {
        let parameters = UserPhoneNumberParameters(phoneNumber: phoneNumber)
        accountService.updateUserPhone(parameters: parameters, success: { [weak self] responce in
            guard let signUpResponce = responce as? SignUpSuccessResponse else {
                return
            }
            DispatchQueue.main.async {
                self?.output?.successed(resendUpdatePhone: signUpResponce)
            }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.output?.failedResendUpdatePhone(errorResponse: error)
                }
        })
    }
    
    func verifyPhoneNumber(token: String, code: String) {
        let parameters = VerifyPhoneNumberParameter(otp: code, referenceToken: token)
        accountService.verifyPhoneNumber(parameters: parameters, success: { [weak self] responce in
            DispatchQueue.main.async {
                self?.output?.successedVerifyPhone()
            }
        }) { [weak self] errorRespose in
            DispatchQueue.main.async {
                self?.output?.failedVerifyPhone(errorString: TextConstants.phoneVereficationNonValidCodeErrorText)
            }
        }
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
                self?.output?.captchaRequred(requred: boolResult)
            case .failed(_):
                self?.output?.captchaRequredFailed()
            }
        }
        ///Implementation with old request bellow
//        captchaService.getSignUpCaptchaRequrement(sucess: { [weak self] succesResponse in
//            guard let succesResponse = succesResponse as? CaptchaSignUpRequrementResponse else {
//                self?.output?.captchaRequredFailed()
//                return
//            }
//            self?.output?.captchaRequred(requred: succesResponse.captchaRequred)
//        }) { [weak self] errorResponse in
//            self?.output?.captchaRequredFailed()
//        }
    }
}
