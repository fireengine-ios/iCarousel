//
//  MyStorageRouter.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class MyStorageRouter {
    weak var view: MyStorageViewController?
}

//MARK: - MyStorageRouterInput
extension MyStorageRouter: MyStorageRouterInput {
    func showCancelOfferAlert(with text: String) {
        let vc = DarkPopUpController.with(title: TextConstants.offersInfo, message: text, buttonTitle: TextConstants.offersOk)
        view?.present(vc, animated: false, completion: nil)
    }
    
    func showCancelOfferApple() {
        let alertVC = UIAlertController(title: TextConstants.offersInfo, message: TextConstants.packageAppleCancelText, preferredStyle: .alert)
        alertVC.view.tintColor = UIColor.lrTealish
        
        let okAction = UIAlertAction(title: TextConstants.offersOk, style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: TextConstants.offersSettings, style: .default) { _ in
            UIApplication.shared.openSettings()
        }
        
        alertVC.addAction(settingsAction)
        alertVC.addAction(okAction)
        view?.present(alertVC, animated: true, completion: nil)
    }
    
    func display(error: String) {
        UIApplication.showErrorAlert(message: error)
    }
}
