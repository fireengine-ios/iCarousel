//
//  LoginLoginViewOutput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LoginViewOutput {
    
    var isPresenting: Bool { get set }

    func viewIsReady()
    
    func rememberMe(remember: Bool)

    func sendLoginAndPassword(login: String, password: String)
    func sendLoginAndPasswordWithCaptcha(login: String, password: String, captchaID: String, captchaAnswer: String)
    
    func onForgotPasswordTap()
    
    func startedEnteringPhoneNumber(withPlus: Bool)
    
    func openSupport()
}
