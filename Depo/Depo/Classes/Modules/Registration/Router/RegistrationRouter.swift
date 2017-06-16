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
//        let configurator = TermsAndServicesModuleInitializer()
//        let nextVC = TermsAndServicesViewController(nibName: "TermsAndServicesScreen", bundle: nil)
//        configurator.termsandservicesViewController = nextVC
//        
//        guard let window1 = UIApplication.shared.delegate?.window else {
//            return
//        }
//        guard let navBar = window1?.rootViewController?.navigationController else {
//            return
//        }
//        navBar.pushViewController(configurator.termsandservicesViewController, animated: true)
        
        let inicializer = TermsAndServicesModuleInitializer()
        let termsController = TermsAndServicesViewController(nibName: "TermsAndServicesScreen", bundle: nil)
        inicializer.termsandservicesViewController = termsController
        inicializer.setupConfig()
        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        nController.pushViewController(termsController, animated: true)
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
