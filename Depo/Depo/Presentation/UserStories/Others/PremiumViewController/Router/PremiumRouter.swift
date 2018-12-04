//
//  PremiumRouter.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PremiumRouter {
    
    weak var view: PremiumViewController!
    var delegate: PremiumPresenter?
}

// MARK: - PremiumRouterInput
extension PremiumRouter: PremiumRouterInput {

    func goToBack() {
        RouterVC().popViewController()
    }
    
    func displayError(with errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func showActivateOfferAlert(with displayName: String, text: String, delegate: PremiumPresenter) {
        self.delegate = delegate
        let vc = DarkPopUpController.with(title: displayName, message: text, buttonTitle: TextConstants.purchase) { [weak self] vc in
            vc.close(animation: {
                self?.delegate?.buy()
            })
        }
        view.present(vc, animated: false, completion: nil)
    }
    
    func showPromocodInvalideAlert(for vc: UIViewController?) {
        let popUpController = PopUpController.with(title: TextConstants.checkPhoneAlertTitle,
                                                   message: TextConstants.promocodeInvalid,
                                                   image: .error,
                                                   buttonTitle: TextConstants.ok)
        vc?.present(popUpController, animated: false, completion: nil)
    }
}
