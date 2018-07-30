//
//  TermsAndServicesTermsAndServicesInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol TermsAndServicesInteractorInput {
    func loadTermsAndUses()
    
    func signUpUser()

    
    var signUpSuccessResponse: SignUpSuccessResponse { get }
    var userInfo: RegistrationUserInfoModel { get }
    
    var cameFromLogin: Bool { get }
    
    func applyEula()
    
    func trackScreen()
}
