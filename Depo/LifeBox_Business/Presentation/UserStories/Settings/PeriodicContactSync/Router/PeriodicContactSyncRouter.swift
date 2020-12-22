//
//  PeriodicContactSyncRouter.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PeriodicContactSyncRouter {
    
}

// MARK: - PeriodicContactSyncRouter

extension PeriodicContactSyncRouter: PeriodicContactSyncRouterInput {
    
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
        
        RouterVC().presentViewController(controller: controller)
    }
    
}


