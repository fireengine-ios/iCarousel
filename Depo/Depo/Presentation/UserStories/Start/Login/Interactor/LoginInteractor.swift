//
//  LoginLoginInteractor.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum LoginFieldError {
    case loginIsNotValid
    case loginIsEmpty
    
    case passwordIsEmpty
    
    case captchaIsEmpty
}

class LoginInteractor: LoginInteractorInput {
    
    weak var output: LoginInteractorOutput?
    
    private let authService = AuthenticationService()
    
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var authenticationService = AuthenticationService()
    private lazy var eulaService = EulaService()
    private lazy var accountService = AccountService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var periodicContactSyncDataStorage = PeriodicContactSyncDataStorage()
    private let contactsService = ContactService()
    private let storageVars: StorageVars

    private var rememberMe: Bool = true
    
    private var attempts: Int = 0
    private var loginRetries = 0 {
        didSet {
            if loginRetries > 2 {
                output?.showSupportView()
            }
        }
    }
    
    private var login: String?
    private var password: String?
    
    private lazy var captchaService = CaptchaService()
    private let cacheManager = CacheManager.shared
    
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
        
        if let captchaAnswer = atachedCaptcha?.answer, captchaAnswer.isEmpty {
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
            analyticsService.trackLoginEvent(error: .incorrectUsernamePassword)
            output?.fieldError(type: .loginIsNotValid)
            return
        }
        
        self.login = login
        self.password = password
        
        let user = AuthenticationUser(login: login,
                                      password: password,
                                      rememberMe: true,
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
            
            if Validator.isValid(email: login) {
                self.analyticsService.trackLoginEvent(loginType: .email)
            } else {
                self.analyticsService.trackLoginEvent(loginType: .gsm)
            }
            
            self.loginRetries = 0
            
            DispatchQueue.main.async {
                self.output?.succesLogin()
            }
            
        }, fail: { [weak self] errorResponse in
            let loginError = LoginResponseError(with: errorResponse)
            self?.analyticsService.trackLoginEvent(error: loginError)
            
            if !(loginError == .needCaptcha || loginError == .noInternetConnection) {
                self?.loginRetries += 1
            }
            
            if loginError == .incorrectUsernamePassword {
                self?.attempts += 1
            }
            
            errorHandler(loginError, errorResponse.description)
        })
    }
    
    private func setContactSettingsForUser() {
        guard let contactSettings = storageVars.usersWhoUsedApp[SingletonStorage.shared.uniqueUserID] as? [String: Bool] else {
            return
        }
        
        let contactSyncSettings = PeriodicContactsSyncSettings(with: contactSettings)
        periodicContactSyncDataStorage.save(periodicContactSyncSettings: contactSyncSettings)
        contactsService.setPeriodicForContactsSync(periodic: contactSyncSettings.syncPeriodic)
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
    
    private func silentLogin(token: String) {
        authenticationService.silentLogin(token: token, success: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.tokenStorage.isRememberMe = self.rememberMe
                self.output?.successedSilentLogin()
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async { [weak self] in
                    self?.tryToRelogin()
                }
        })
    }
    
    private func tryToRelogin() {
        guard let login = login, let password = password else {
            assertionFailure()
            return
        }
        
        authificate(login: login, password: password, atachedCaptcha: nil) { _, _ in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.output?.successedVerifyPhone()
            }
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
        analyticsService.logScreen(screen: .loginScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: .loginScreen)
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
        accountService.verifyPhoneNumber(parameters: parameters, success: { [weak self] baseResponse in
            
            if let response = baseResponse as? ObjectRequestResponse,
                let silentToken = response.responseHeader?[HeaderConstant.silentToken] as? String {
                
                self?.silentLogin(token: silentToken)
            } else {
                DispatchQueue.main.async {
                    self?.tryToRelogin()
                }
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
            case .failed(let error):
                if error.isServerUnderMaintenance {
                    self?.output?.captchaRequredFailed(with: error.description)
                } else {
                    self?.output?.captchaRequredFailed()
                }
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
