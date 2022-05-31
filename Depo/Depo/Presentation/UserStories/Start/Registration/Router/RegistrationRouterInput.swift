//
//  RegistrationRegistrationRouterInput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol RegistrationRouterInput {
    func presentEmailUsagePopUp(email: String, onClosed: @escaping () -> Void)

    func phoneVerification(signUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel)

    func emailVerification(signUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel)

    func openSupport()
    
    func goToFaqSupportPage()
    
    func goToSubjectDetailsPage(type: SupportFormSubjectTypeProtocol)

    func goToPrivacyPolicyDescriptionController()
    
    func goBack()
}
