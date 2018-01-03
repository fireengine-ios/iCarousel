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
    
    func termsAndServices(with delegate: RegistrationViewDelegate?, email: String) {
        
        let okHandler: () -> Void = {
            let router = RouterVC()
            let termsAndServices = router.termsAndServicesScreen(login: false, delegate: delegate)
            router.pushViewController(viewController: termsAndServices)
        }
        
        let message = String(format: TextConstants.registrationEmailPopupMessage, email)
        
        let controller = PopUpController.with(title: TextConstants.registrationEmailPopupTitle,
                                              message: message,
                                              image: .error,
                                              buttonTitle: TextConstants.ok,
                                              action: { vc in
                                                vc.close(completion: okHandler)
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
}
