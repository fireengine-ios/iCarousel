//
//  PhoneVereficationPhoneVereficationRouter.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVereficationRouter: PhoneVereficationRouterInput {
    
    private func goToSplash() {
        AuthenticationService().logout(success: {
            if let splash = RouterVC().splash {
                RouterVC().pushViewController(viewController: splash)
            }
        })
    }
    
    func goAutoSync() {
        let router = RouterVC()
        router.pushViewController(viewController: router.synchronyseScreen!)
    }
    
    func presentErrorPopUp(with message: String) {
        let controller = PopUpController.with(title: TextConstants.checkPhoneAlertTitle, message: message, image: .error, buttonTitle: TextConstants.ok)
        RouterVC().presentViewController(controller: controller)
    }
    
    func showRedirectToSplash() {
        let popUp = PopUpController.with(title: nil, message: TextConstants.authificateCaptchaRequired, image: .none, buttonTitle: TextConstants.ok, action: { vc in
            vc.close(completion: { [weak self] in
                self?.goToSplash()
            })
        })
   
        RouterVC().presentViewController(controller: popUp)
    }
}
