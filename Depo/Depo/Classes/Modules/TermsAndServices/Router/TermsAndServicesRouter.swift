//
//  TermsAndServicesTermsAndServicesRouter.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesRouter: TermsAndServicesRouterInput {
    func goToRegister(){
        let inicializer = RegistrationModuleInitializer()
        let registerController = RegistrationViewController(nibName: "RegistrationScreen", bundle:nil)
        inicializer.registrationViewController = registerController
        inicializer.setupVC()
        
        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        nController.pushViewController(registerController, animated: true)
        nController.navigationBar.isHidden = false
    }
}
