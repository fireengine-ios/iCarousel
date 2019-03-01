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
            analyticsService.trackLoginEvent(error: .incorrectUsernamePassword)
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
            
            if Validator.isValid(email: login) {
                self.analyticsService.trackLoginEvent(loginType: .email)
            } else {
                self.analyticsService.trackLoginEvent(loginType: .gsm)
            }
//            self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .clickOtherTurkcellServices, eventLabel: .clickOtherTurkcellServices)
//            ItemsRepository.sharedSession.updateCache()
            DispatchQueue.main.async {
                self.output?.succesLogin()
            }
        }, fail: { [weak self] errorResponse  in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                
                let loginError = LoginResponseError(with: errorResponse)
                
                self.analyticsService.trackLoginEvent(error: loginError)
                
                switch loginError {
                case .block:
                    self.output?.failedBlockError()
                case .needCaptcha:
                    self.output?.needShowCaptcha()
                case .authenticationDisabledForAccount:
                    self.output?.failLogin(message: TextConstants.loginScreenAuthWithTurkcellError)
                case .needSignUp:
                    self.output?.needSignUp(message: TextConstants.loginScreenNeedSignUpError)
                case .incorrectUsernamePassword:
                    self.attempts += 1
                    self.output?.failLogin(message: TextConstants.loginScreenCredentialsError)
                case .incorrectCaptcha:
                    self.output?.failLogin(message: TextConstants.loginScreenInvalidCaptchaError)
                case .networkError, .serverError:
                    self.output?.failLogin(message: errorResponse.description)
                case .unauthorized:
                    self.output?.failLogin(message: TextConstants.loginScreenCredentialsError)
                case .noInternetConnection:
                    self.output?.failLogin(message: TextConstants.errorConnectedToNetwork)
                case .emptyPhone:
                    self.login = login
                    self.password = password
                    self.atachedCaptcha = atachedCaptcha
                    self.output?.openEmptyPhone()
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
        accountService.verifyPhoneNumber(parameters: parameters, success: { [weak self] baseResponse in
            
            if let response = baseResponse as? ObjectRequestResponse,
                let silentToken = response.responseHeader?[HeaderConstant.silentToken] as? String {
                
                self?.silentLogin(token: silentToken)
            } else {
                DispatchQueue.main.async {
                    self?.output?.successedVerifyPhone()
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
                if error.isWorkUnderway {
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
    
    private func silentLogin(token: String) {
        authenticationService.silentLogin(token: token, success: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.output?.successedSilentLogin()
                self?.output?.succesLogin()
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async { [weak self] in
                self?.output?.successedVerifyPhone()
            }
        })
    }
}
