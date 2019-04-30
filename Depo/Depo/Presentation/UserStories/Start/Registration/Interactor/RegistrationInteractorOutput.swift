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
    
    func captchaRequred(requred: Bool)
    func captchaRequredFailed()
    func captchaRequredFailed(with message: String)
    
    func signUpFailed(errorResponce: ErrorResponse)
    func signUpSuccessed(signUpUserInfo: RegistrationUserInfoModel?, signUpResponse: SignUpSuccessResponse?)
    
    func showSupportView()
}
