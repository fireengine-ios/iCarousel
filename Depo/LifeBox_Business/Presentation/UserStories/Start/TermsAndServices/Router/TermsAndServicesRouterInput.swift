//
//  TermsAndServicesTermsAndServicesRouterInput.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol TermsAndServicesRouterInput {
    func goToHomePage()
    func goToPhoneVerification(withSignUpSuccessResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel)
    func closeModule()
    func goToTurkcellAndGroupCompanies()
    func goToCommercialEmailMessages()
    func goToPrivacyPolicyDescriptionController()
    func goToGlobalDataPermissionDetails()
}
