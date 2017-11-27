//
//  PhoneVereficationPhoneVereficationRouter.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhoneVereficationRouter: PhoneVereficationRouterInput {
    
//    func goToTermAndUses() {
//        
//        let router = RouterVC()
//        let terms = router.termsAndServicesScreen
//        router.pushViewController(viewController: terms)
//    }
    func goAutoSync() {
        let router = RouterVC()
        router.pushViewController(viewController: router.synchronyseScreen!)
//        let inicializer = AutoSyncModuleInitializer()
//        let controller = AutoSyncViewController(nibName: "AutoSyncViewController", bundle: nil)
//        inicializer.autosyncViewController = controller
//        inicializer.setupVC()
//        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
//        nController.pushViewController(controller, animated: true)
//        nController.navigationBar.isHidden = false
    }
}
