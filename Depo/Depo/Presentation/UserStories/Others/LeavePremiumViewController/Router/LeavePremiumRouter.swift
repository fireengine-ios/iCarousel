//
//  LeavePremiumRouter.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class LeavePremiumRouter {
    
    weak var view: LeavePremiumViewController!
    
}

// MARK: - PremiumRouterInput
extension LeavePremiumRouter: LeavePremiumRouterInput {
    func goToBack() {
        RouterVC().popViewController()
    }
    
    func showAlert(with text: String) {
        let router = RouterVC()
        
        let popUpController = PopUpController.with(title: TextConstants.offersInfo, message: text, image: .none, buttonTitle: TextConstants.offersOk) { vc in
            vc.close()
        }
        popUpController.open()
    }
    
    func showError(with text: String) {
        UIApplication.showErrorAlert(message: text)
    }
}
