//
//  ForgotPasswordForgotPasswordViewOutput.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol ForgotPasswordViewOutput {

    func viewIsReady()
    
    func onSendPassword(withEmail email: String, enteredCaptcha: String, captchaUDID: String)
}
