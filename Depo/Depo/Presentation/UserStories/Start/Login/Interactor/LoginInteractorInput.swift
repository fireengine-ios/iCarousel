//
//  LoginLoginInteractorInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LoginInteractorInput {
        
    func rememberMe(state: Bool)
    
    func authificate(login: String, password: String, atachedCaptcha: CaptchaParametrAnswer?, googleToken: String?)
    
    func findCoutryPhoneCode(plus: Bool)
    
    func checkEULA()
    
    func prepareTimePassed(forUserName name: String)
    func eraseBlockTime(forUserName name: String)
    
    func blockUser(user: String)
    
    var isShowEmptyEmail: Bool { get }
    
    func updateUserLanguage()
    
    func checkCaptchaRequerement()
    
    func trackScreen()
    func trackSupportSubjectEvent(type: SupportFormSubjectTypeProtocol)
    
    func updateEmptyPhone(delegate: AccountWarningServiceDelegate)
    
    func tryToRelogin()
    
    func stopUpdatePhone()
    
    func continueWithGoogleLogin()
}
