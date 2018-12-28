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
    func openLeavePremium()
    func openMyStorage(storageUsage: UsageResponse?)
    
    func showSuccessPurchasedPopUp(with delegate: PackagesPresenter)
}
