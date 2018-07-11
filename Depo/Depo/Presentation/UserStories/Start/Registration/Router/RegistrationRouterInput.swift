//
//  RegistrationRegistrationRouterInput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol RegistrationRouterInput {
    func phoneVerification(sigUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel)
    func termsAndServices(with delegate: RegistrationViewDelegate?, email: String)
    
    func getCapcha() -> CaptchaViewController
}
