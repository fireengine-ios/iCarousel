//
//  RegistrationRegistrationInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol RegistrationInteractorInput {
    
    var captchaRequired: Bool { get }

    func checkEtkAndGlobalPermissions(code: String, phone: String)

    func validatePassword(_ password: String, repassword: String?)

    func validateUserInfo(email: String,
                          code: String,
                          phone: String,
                          password: String,
                          repassword: String,
                          captchaID: String?,
                          captchaAnswer: String?,
                          appleGoogleUser: AppleGoogleUser?)
    
    func checkCaptchaRequerement()

    func loadTermsOfUse()
    
    func signUpUser(_ userInfo: RegistrationUserInfoModel, etkAuth: Bool?, globalPermAuth: Bool?)
    
    func trackScreen()
    func trackSupportSubjectEvent(type: SupportFormSubjectTypeProtocol)
    func trackEULAConfirmed()
    func trackEmailUsagePopUp()
}
