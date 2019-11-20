//
//  RegistrationRegistrationInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol RegistrationInteractorOutput: class {
    
    func userValid(_ userInfo: RegistrationUserInfoModel)
    func userInvalid(withResult result: [UserValidationResults])
    
    func captchaRequired(required: Bool)
    func captchaRequiredFailed()
    func captchaRequiredFailed(with message: String)
    
    func signUpFailed(errorResponse: SignupResponseError)
    func signUpSuccessed(signUpUserInfo: RegistrationUserInfoModel?, signUpResponse: SignUpSuccessResponse?)
    
    func showFAQView()
    func showSupportView()
}
