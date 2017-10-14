//
//  RegistrationRegistrationRouter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationRouter: RegistrationRouterInput {
    
    func phoneVerification(sigUpResponse:SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        
        let router = RouterVC()
        let phoneVerification = router.phoneVereficationScreen(withSignUpSuccessResponse: sigUpResponse, userInfo: userInfo)
        router.pushViewController(viewController: phoneVerification)
    }
    
    func termsAndServices(with delegate: RegistrationViewDelegate?) {
        let router = RouterVC()
        let termsAndServices = router.termsAndServicesScreen(login: false, delegate: delegate)
        router.pushViewController(viewController: termsAndServices)
    }
}
