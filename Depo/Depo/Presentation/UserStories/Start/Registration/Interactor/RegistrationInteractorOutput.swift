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
    
    func captchaRequred(requred: Bool)
    func captchaRequredFailed()
    func captchaRequredFailed(with message: String)
}
