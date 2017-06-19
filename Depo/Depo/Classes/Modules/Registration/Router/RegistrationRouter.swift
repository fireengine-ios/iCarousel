//
//  RegistrationRegistrationRouter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationRouter: RegistrationRouterInput {
    func routNextVC() {
        //init new here
        
        let controller = PhoneVereficationViewController(nibName: "PhoneVereficationScreen", bundle: nil)
        let inicializer = PhoneVereficationModuleInitializer()
        inicializer.phonevereficationViewController = controller
        inicializer.setupConfig()
        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        nController.pushViewController(controller, animated: true)
        nController.navigationBar.isHidden = false
        
    }
    
    func routNextVC(wihtNavigationController navController: UINavigationController) {
        let viewController = PhoneVereficationViewController(nibName: "PhoneVereficationScreen", bundle: nil)
        let configurator = PhoneVereficationModuleInitializer()
        configurator.phonevereficationViewController = viewController
        configurator.setupConfig()
        navController.pushViewController(viewController, animated: true)
        
    }
    
}
