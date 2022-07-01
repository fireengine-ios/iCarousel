//
//  PhoneVerificationRouter.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVerificationRouter: PhoneVerificationRouterInput {
    lazy var router = RouterVC()
    
    private func goToSplash() {
        AuthenticationService().logout(success: { [weak self] in
            if let splash = RouterVC().splash {
                self?.router.pushViewController(viewController: splash)
            }
        })
    }
    
    func goAutoSync() {
        router.pushViewController(viewController: router.synchronyseScreen)
    }
    
    func presentErrorPopUp(with message: String) {
        let controller = PopUpController.with(title: TextConstants.checkPhoneAlertTitle, message: message, image: .error, buttonTitle: TextConstants.ok)
        controller.open()
    }
    
    func showRedirectToSplash() {
        let popUp = PopUpController.with(title: nil,
                                         message: TextConstants.authificateCaptchaRequired,
                                         image: .none,
                                         buttonTitle: TextConstants.ok, action: { vc in
            vc.close(completion: { [weak self] in
                self?.goToSplash()
            })
        })
        popUp.open()

    }
    
    func popToLoginWithPopUp(title: String?, message: String, image: PopUpImage, onClose: VoidHandler?) {
        let popUp = PopUpController.with(title: title,
                                         message: message,
                                         image: image,
                                         buttonTitle: TextConstants.ok) { [weak self] controller in
            controller.close { [weak self] in
                onClose?()
                self?.router.popTwoFactorAuth()
            }
        }
        
        popUp.open()
    }
    
    func showAccountStatePopUp(image: PopUpImage,
                               title: String,
                               titleDesign: DesignText,
                               message: String,
                               messageDesign: DesignText,
                               buttonTitle: String,
                               buttonAction: @escaping VoidHandler) {
        let popUp = CreateStoryPopUp.with(image: image.image,
                                          title: title,
                                          titleDesign: titleDesign,
                                          message: message,
                                          messageDesign: messageDesign,
                                          buttonTitle: buttonTitle,
                                          buttonAction: buttonAction)
        router.presentViewController(controller: popUp, animated: false)
    }
    
}
