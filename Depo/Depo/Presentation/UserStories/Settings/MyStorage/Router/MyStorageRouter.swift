//
//  MyStorageRouter.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class MyStorageRouter {
    private let router = RouterVC()
}

//MARK: - MyStorageRouterInput
extension MyStorageRouter: MyStorageRouterInput {
    func showCancelOfferAlert(with text: String) {
        let vc = DarkPopUpController.with(title: TextConstants.offersInfo, message: text, buttonTitle: TextConstants.offersOk)
        router.presentViewController(controller: vc)
    }
    
    func showCancelOfferApple() {
        let alertVC = UIAlertController(title: TextConstants.offersInfo, message: TextConstants.offersAllCancel, preferredStyle: .alert)
        alertVC.view.tintColor = UIColor.lrTealish
        
        let okAction = UIAlertAction(title: TextConstants.offersOk, style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: TextConstants.offersSettings, style: .default) { _ in
            UIApplication.shared.openSettings()
        }
        
        alertVC.addAction(settingsAction)
        alertVC.addAction(okAction)
        router.presentViewController(controller: alertVC)
    }
    
    func showSubTurkcellOpenAlert(with text: String) {
        let vc = DarkPopUpController.with(title: TextConstants.offersInfo, message: text, buttonTitle: TextConstants.offersOk)
        router.presentViewController(controller: vc)
    }
    
    func openLeavePremium(type: LeavePremiumType) {
        let vc = router.leavePremium(type: type)
        router.pushViewController(viewController: vc)
    }
    
    func display(error: String) {
        UIApplication.showErrorAlert(message: error)
    }
}
