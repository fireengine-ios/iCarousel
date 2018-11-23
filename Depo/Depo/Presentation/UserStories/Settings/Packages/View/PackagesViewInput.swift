//
//  PackagesPackagesViewInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PackagesViewInput: class, ActivityIndicator {
    func display(subscriptionPlans array: [SubscriptionPlan], append: Bool)
    func display(error: ErrorResponse)
    func showActivateOfferAlert(for offer: OfferServiceResponse, planIndex: Int)
    func showCancelOfferAlert(with text: String)
    func showCancelOfferApple()
    func show(promocodeError: String)
    func successedPromocode()
    func showSubTurkcellOpenAlert(with text: String)
    
    func showRestoreButton()
    func showInAppPolicy()
    func reloadPackages()

    func setupStackView(with storageCapacity: Int64)
}
