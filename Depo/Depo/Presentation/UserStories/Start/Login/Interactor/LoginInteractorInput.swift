//
//  LoginLoginInteractorInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LoginInteractorInput {
        
    func rememberMe(state: Bool)
    
    func authificate(login: String, password: String, atachedCaptcha: CaptchaParametrAnswer?)
    
    func findCoutryPhoneCode(plus: Bool)
    
    func checkEULA()
    
    func prepareTimePassed(forUserName name: String)
    func eraseBlockTime(forUserName name: String)
    
    func blockUser(user: String)
    
    func getTokenToUpdatePhone(for phoneNumber: String)
    func getResendTokenToUpdatePhone(for phoneNumber: String)
    func verifyPhoneNumber(token: String, code: String)
    
    var isShowEmptyEmail: Bool { get }
    
    func updateUserLanguage()
    
    func checkCaptchaRequerement()
    
    func trackScreen()
}
