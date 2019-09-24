//
//  PremiumRouterInput.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol PremiumRouterInput: class {

    func goToBack()
    func displayError(with errorMessage: String)
    func showNoDetailsAlert(with message: String)
    func showActivateOfferAlert(with displayName: String, text: String, delegate: PremiumPresenter)
    func showPromocodInvalideAlert(for vc: UIViewController?)
    func purchaseSuccessed(with delegate: FaceImageItemsModuleOutput?)
    
    func openLink(with url: URL)
    func showTermsOfUse()
    func presentPaymentPopUp(paymentModel: PaymentModel?)
}
