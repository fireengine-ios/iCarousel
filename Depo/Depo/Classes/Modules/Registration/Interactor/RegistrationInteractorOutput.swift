//
//  RegistrationRegistrationInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol RegistrationInteractorOutput: class {
    func pass(title: String, forRowIndex: Int)
    
    func prepearedModels(models:[BaseCellModel])
    func composedGSMCCodes(models:[GSMCodeModel])
    
    func validatedUserInfo(withResult result: String)//email: String, phone: String, passport: String, withResult result: Bool)
}
