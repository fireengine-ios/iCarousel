//
//  LoginSettingsRouter.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class LoginSettingsRouter {
    private let router = RouterVC()
}

// MARK: LoginSettingsRouterInput
extension LoginSettingsRouter: LoginSettingsRouterInput {
    func presentErrorPopup(title: String, message: String, buttonTitle: String, buttonAction: VoidHandler?) {        
        let popUp = PopUpController.with(title: title,
                                          message: message,
                                          image: .error,
                                          buttonTitle: buttonTitle) { controller in
                                            buttonAction?()
                                            controller.close()
        }
        
        router.presentViewController(controller: popUp)
    }
}
