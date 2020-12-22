//
//  ForgotPasswordForgotPasswordInteractorInput.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol ForgotPasswordInteractorInput {
    func sendForgotPasswordRequest(with mail: String, enteredCaptcha: String, captchaUDID: String)
    func trackScreen()
}
