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
    }
    
    func routNextVC(wihtNavigationController navController: UINavigationController) {
        let viewController = PhoneVereficationViewController(nibName: "PhoneVereficationScreen", bundle: nil)//TermsAndServicesViewController(nibName: "TermsAndServicesScreen", bundle: nil)
        let configurator = PhoneVereficationModuleInitializer()//TermsAndServicesModuleInitializer()
        configurator.phonevereficationViewController = viewController
        configurator.setupConfig()
        navController.pushViewController(viewController, animated: true)
        
    }
    
}
