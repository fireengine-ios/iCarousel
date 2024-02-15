//
//  ForgotPasswordForgotPasswordInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol ForgotPasswordInteractorOutput: AnyObject {
    func foundCoutryPhoneCode(code: String, plus: Bool)

    func linkSentToEmailSuccessfully()

    func receivedVerificationMethods(_ methods: [IdentityVerificationMethod])
    func requestFailed(withError error: String)
    
    func successForgotMyPassWordWithMail()
    func receivedOTPVerification(_ methods: [IdentityVerificationMethod])
}
