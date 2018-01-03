//
//  LoginLoginInteractor.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginInteractor: LoginInteractorInput {
    
    weak var output: LoginInteractorOutput!
    
    var dataStorage = LoginDataStorage()
    
    private var rememberMe: Bool = true
    
    private var attempts: Int = 0
    
    /// from 0 to 11 = 12 attempts
    private let maxAttemps: Int = 11
    
    func prepareModels(){
        output.models(models: dataStorage.getModels())
    }
    
    func rememberMe(state:Bool){
        rememberMe = state
    }
    
    func authificate(login: String, password: String, atachedCaptcha: CaptchaParametrAnswer?) {
        
        if login.isEmpty {
            output.loginFieldIsEmpty()
            return
        }
        if password.isEmpty {
            output.passwordFieldIsEmpty()
            return
        }
        if isBlocked(userName: login)  {
            output.userStillBlocked(user: login)
            return
        } else if (maxAttemps <= attempts) {
            output.allAttemtsExhausted(user: login)//block here
            return
        }
        
        let authenticationService = AuthenticationService()
        
        let user = AuthenticationUser(login          : login,
                                      password       : password,
                                      rememberMe     : true,//rememberMe,
                                      attachedCaptcha: atachedCaptcha)
        
        authenticationService.login(user: user, sucess: { [weak self] in
            guard let `self` = self else {
                return
            }
//            ApplicationSession.sharedSession.session.rememberMe = self.rememberMe
//            ApplicationSession.sharedSession.saveData()
            DispatchQueue.main.async { [weak self] in
                self?.output.succesLogin()
            }
        }, fail: { [weak self] (errorResponse)  in
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                if self.isBlockError(forResponse: errorResponse) {
                    self.output.failedBlockError()
                    return
                }
                if self.inNeedOfCaptcha(forResponse: errorResponse) {
                    self.output.needShowCaptcha()
                } else if self.isAuthenticationError(forResponse: errorResponse) || self.inNeedOfCaptcha(forResponse: errorResponse) {
                    self.attempts += 1
                }
                self.output.failLogin(message: errorResponse.description)
            }
        })
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
        let timeIntervalFromBlockDate =  currentTime.timeIntervalSince(blokedDate)
        if timeIntervalFromBlockDate/60 >= 60 {
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
    
    private func isAuthenticationError(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("Authentication failure")
    }
    
    private func isBlockError(forResponse errorResponse: ErrorResponse) -> Bool {
        return errorResponse.description.contains("LDAP account is locked")
    }
    
    func findCoutryPhoneCode(plus: Bool) {
        let telephonyService = CoreTelephonyService()
        var phoneCode = telephonyService.callingCountryCode()
        if phoneCode == "" {
            phoneCode = telephonyService.countryCodeByLang()
        }
        output.foundCoutryPhoneCode(code: phoneCode, plus: plus)
    }
    
    func checkEULA() {
        let eulaService = EulaService()
        eulaService.eulaCheck(success: { [weak self] (succesResponce) in
            DispatchQueue.main.async {
                self?.output.onSuccessEULA()
            }
        }) { [weak self] (failResponce) in
            DispatchQueue.main.async {
                //TODO: what do we do on other errors?
                ///https://wiki.life.com.by/pages/viewpage.action?pageId=62456128
                if failResponce.description == "EULA_APPROVE_REQUIRED" {
                    self?.output.onFailEULA()
                } else {
                   self?.output.onFailEULA()
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
}
