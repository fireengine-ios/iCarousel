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
    
    func validateUserInfo(email: String,
                          code: String,
                          phone: String,
                          password: String,
                          repassword: String,
                          captchaID: String?,
                          captchaAnswer: String?)
    
    func checkCaptchaRequerement()
    
    func signUpUser(_ userInfo: RegistrationUserInfoModel)
    
    func trackScreen()
}
