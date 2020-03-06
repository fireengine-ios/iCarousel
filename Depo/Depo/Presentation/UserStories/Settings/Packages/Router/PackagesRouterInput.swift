//
//  PackagesPackagesRouterInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PackagesRouterInput {
    func openTermsOfUse()
    func openLeavePremium(type: LeavePremiumType)
    func openUsage()
    func openUserProfile(userInfo: AccountInfoResponse, isTurkcellUser: Bool)
    
    func showSuccessPurchasedPopUp(with delegate: PackagesPresenter)
    func closePaymentPopUpController(closeAction: @escaping VoidHandler)
    func showPaycellProcess(with cpcmOfferId: Int)
}
