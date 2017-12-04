//
//  PackagesPackagesViewInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PackagesViewInput: class, ActivityIndicator {
    func display(subscriptionPlans array: [SubscriptionPlan])
    func display(error: ErrorResponse)
    func showActivateOfferAlert(for offer: OfferServiceResponse)
    func showCancelOfferAlert(for accountType: AccountType)
    func showCancelOfferApple()
    func show(promocodeError: String)
    func successedPromocode()
}
