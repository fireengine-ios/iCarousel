//
//  AutoSyncAutoSyncRouter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncRouter: AutoSyncRouterInput {
    
    private let router = RouterVC()
 
    func routNextVC() {
        DispatchQueue.toMain {
            self.router.popViewController()
            /// it was going to tabbar directly, it may change acording to flow
            //self.router.setNavigationController(controller: self.router.tabBarScreen)
        }
    }
    
    func showContactsSettingsPopUp() {
        let controller = PopUpController.with(title: TextConstants.periodicContactsSyncAccessAlertTitle,
                                              message: TextConstants.periodicContactsSyncAccessAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.periodicContactsSyncAccessAlertNo,
                                              secondButtonTitle: TextConstants.periodicContactsSyncAccessAlertGoToSettings,
                                              secondAction: { vc in
                                                vc.close {
                                                    UIApplication.shared.openSettings()
                                                }
        })
        
        controller.open()
    }
}
