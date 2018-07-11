//
//  RegistrationRegistrationRouter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationRouter: RegistrationRouterInput {
    let router = RouterVC()
    
    func phoneVerification(sigUpResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) {
        
        let phoneVerification = router.phoneVereficationScreen(withSignUpSuccessResponse: sigUpResponse, userInfo: userInfo)
        router.pushViewController(viewController: phoneVerification)
    }
    
    func termsAndServices(with delegate: RegistrationViewDelegate?, email: String) {
        
        let okHandler: VoidHandler = { [weak self] in
            guard let termsAndServices = self?.router.termsAndServicesScreen(login: false, delegate: delegate) else {
                return
            }
            self?.router.pushViewController(viewController: termsAndServices)
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
    
    func getCapcha() -> CaptchaViewController {
        let capcha = router.capcha
        return capcha as! CaptchaViewController
    }
}
