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
    var cameFromRegistration: Bool { get }
    var etkAuth: Bool?  { get set }
    var globalPermAuth: Bool?  { get set }
    func loadTermsAndUses()
    func trackScreen()
    func checkEtk()
    func applyEula()
    func checkGlobalPerm()
}
