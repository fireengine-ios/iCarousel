//
//  PremiumService.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 12/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumService {
    
    static let shared: PremiumService = PremiumService()
    
    private let router = RouterVC()

    func addObserverForSyncStatusDidChange() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(onAutoSyncStatusDidChange),
                                       name: .autoSyncStatusDidChange,
                                       object: nil)
    }
    
    func showPopupForNewUserIfNeeded() {
        DispatchQueue.toMain {
            if AuthoritySingleton.shared.isShowPopupAboutPremiumAfterSync,
                self.router.getViewControllerForPresent()?.presentedViewController == nil {
                AuthoritySingleton.shared.setShowPopupAboutPremiumAfterSync(isShow: false)
                
                let controller = PopUpController.with(title: nil,
                                                      message: TextConstants.syncPopup,
                                                      image: .none,
                                                      firstButtonTitle: TextConstants.noForUpgrade,
                                                      secondButtonTitle: TextConstants.yesForUpgrade,
                                                      secondAction: { [weak self] vc in
                                                        vc.dismiss(animated: true, completion: {
                                                            self?.moveToPremium()
                                                        })
                })
                
                UIApplication.topController()?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Utility methods
    @objc private func onAutoSyncStatusDidChange(notification: NSNotification) {
        if let vc = notification.object as? ItemSyncService,
            vc.status == .executing {
            showPopupForNewUserIfNeeded()
        }
    }
    
    private func moveToPremium() {
        let controller = router.premium(title: TextConstants.lifeboxPremium,
                                        headerTitle: TextConstants.becomePremiumMember)
        router.pushViewController(viewController: controller)
    }
    
}



