//
//  PhoneVereficationPhoneVereficationRouter.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVereficationRouter: PhoneVereficationRouterInput {
    
    func goToTermAndUses(){
        let inicializer = TermsAndServicesModuleInitializer()
        let termsController = TermsAndServicesViewController(nibName: "TermsAndServicesScreen", bundle: nil)
        inicializer.termsandservicesViewController = termsController
        inicializer.setupConfig()
        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        nController.pushViewController(termsController, animated: true)
        nController.navigationBar.isHidden = false
    }
    
}
