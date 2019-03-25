//
//  TermsAndServicesTermsAndServicesInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol TermsAndServicesInteractorInput {
    
    var signUpSuccessResponse: SignUpSuccessResponse { get }
    var userInfo: RegistrationUserInfoModel { get }
    var cameFromLogin: Bool { get }
    
    func loadTermsAndUses()
    func signUpUser()
    func applyEula()
    func trackScreen()
    func checkEtk(for phoneNumber: String)
}
