//
//  AutoSyncAutoSyncRouter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncRouter: AutoSyncRouterInput {
    
    private let router = RouterVC()
    var fromRegister = false
    
    func routNextVC() {
        DispatchQueue.toMain { [weak self] in
            self?.router.setNavigationController(controller: self?.router.tabBarScreen)
            
//            if self?.fromRegister == true {
//                return
//            }
            
//            self?.verifyEmailIfNeeded()
        }
    }
    
    

    private func verifyEmailIfNeeded() {
        SingletonStorage.shared.emailVerifyIfNeeded { [weak self] result in
            if !result, let popUp = self?.router.verifyEmailPopUp {
                self?.router.presentViewController(controller: popUp)
            } else {
                self?.isRecoveryNeedToOpen()
            }
        }
    }
    
    private func isRecoveryNeedToOpen() {
        if SingletonStorage.shared.isJustRegistered == nil || SingletonStorage.shared.isJustRegistered == false {
            SingletonStorage.shared.securityInfoIfNeeded { isNeed in
                if isNeed {
                    RouterVC().securityInfoViewController(fromSettings: false)
                }
            }
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
