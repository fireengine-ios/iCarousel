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
            self.router.setNavigationController(controller: self.router.tabBarScreen)
        }
    }
    
    func showPopupForNewUser(with message: String, title: String, headerTitle: String) {
        let controller = PopUpController.with(title: nil,
                                              message: message,
                                              image: .none,
                                              firstButtonTitle: TextConstants.noForUpgrade,
                                              secondButtonTitle: TextConstants.yesForUpgrade,
                                              secondAction: { [weak self] vc in
                                                vc.dismiss(animated: true, completion: {
                                                    self?.moveToPremium(title: title, headerTitle: headerTitle)
                                                })
        })
        
        router.navigationController?.present(controller, animated: true, completion: {})
    }
    
    // MARK: Utility methods
    private func moveToPremium(title: String, headerTitle: String) {
        let controller = router.premium(title: title, headerTitle: headerTitle)
        router.pushViewController(viewController: controller)
    }

}
