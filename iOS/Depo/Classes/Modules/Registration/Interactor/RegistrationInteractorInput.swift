//
//  RegistrationRegistrationInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol RegistrationInteractorInput {
    
    func requestTitle()
    func prepareModels()
    func requestGSMCountryCodes()
    func signUPUser(email: String, phone: String, passport: String, repassword: String)
}
