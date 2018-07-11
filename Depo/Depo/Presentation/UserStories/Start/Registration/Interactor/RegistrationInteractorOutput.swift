//
//  RegistrationRegistrationInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol RegistrationInteractorOutput: class {
    
    func prepearedModels(models: [BaseCellModel])
    func composedGSMCCodes(models: [GSMCodeModel])
    
    func userValid(email: String, phone: String, passpword: String, captchaID: String?, captchaAnswer: String?)
    func userInvalid(withResult result: [UserValidationResults])
    
    func signUpFailed(withResult result: String?)
    func signUpSucces(withResult result: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel)
    
    func captchaRequred(requred: Bool)
    func captchaRequredFailed()
}
