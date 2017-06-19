//
//  TermsAndServicesTermsAndServicesRouter.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesRouter: TermsAndServicesRouterInput {
    func goToAutoSync(){
        let inicializer = AutoSyncModuleInitializer()
        let controller = AutoSyncViewController(nibName: "AutoSyncViewController", bundle: nil)
        inicializer.autosyncViewController = controller
        inicializer.setupVC()
        let nController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        nController.pushViewController(controller, animated: true)
        nController.navigationBar.isHidden = false
    }
}
