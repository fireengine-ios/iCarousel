//
//  ForgotPasswordForgotPasswordInteractorInput.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol ForgotPasswordInteractorInput {
    func trackScreen()

    func findCoutryPhoneCode(plus: Bool)

    func sendForgotPasswordRequest(withLogin login: String, enteredCaptcha: String, captchaUDID: String)
}
