//
//  AutoSyncAutoSyncRouter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncRouter: AutoSyncRouterInput {
 
    func routNextVC() {
        let router = RouterVC()
        router.setNavigationController(controller: router.tabBarScreen)
    }
    
    func showSyncOverPopUp(okHandler: @escaping VoidHandler) {
        let router = RouterVC()
        
        let controller = PopUpController.with(title: TextConstants.autoSyncSyncOverTitle,
                                              message: TextConstants.autoSyncSyncOverMessage,
                                              image: .none,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.autoSyncSyncOverOn,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
                                                
        })
        router.rootViewController?.present(controller, animated: true, completion: nil)
    }
}
