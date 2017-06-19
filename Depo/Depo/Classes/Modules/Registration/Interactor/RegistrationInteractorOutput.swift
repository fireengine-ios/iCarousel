//
//  RegistrationRegistrationInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol RegistrationInteractorOutput: class {
    
    func prepearedModels(models:[BaseCellModel])
    func composedGSMCCodes(models:[GSMCodeModel])
    
    func userValid(email: String, phone: String, passpword: String)
    func userInvalid(withResult result: UserValidationResults)
    //email: String, phone: String, passport: String, withResult result: Bool)
    
    func signUpBeingProcessed()
    func signUpResult(withResult result: String)
}
