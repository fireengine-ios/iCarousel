//
//  MyStorageRouterInput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageRouterInput {
    func showPremiumProcess()
    func showCancelOfferAlert(with text: String)
    func showCancelOfferApple()
    func showSubTurkcellOpenAlert(with text: String)
    
    func openLeavePremium(type: LeavePremiumType)
    
    func display(error: String)
    func openTermsOfUse()
    func showSuccessPurchasedPopUp(with delegate: MyStoragePresenter)
    func showPaycellProcess(with cpcmOfferId: Int)
    func closePaymentPopUpController(closeAction: @escaping VoidHandler)
}
