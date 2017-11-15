//
//  LoginLoginViewOutput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LoginViewOutput {

    func viewIsReady()
    
    func sendLoginAndPassword(login: String, password: String)
    
    func sendLoginAndPasswordWithCaptcha(login: String, password: String, captchaID: String, captchaAnswer: String)

    func sendTurkcellLogin()
    
    func onCantLoginButton()
    
    func rememberMe(remember: Bool)
    
    func startedEnteringPhoneNumber()
    func startedEnteringPhoneNumberPlus()
    
    func viewAppeared()
    
}
