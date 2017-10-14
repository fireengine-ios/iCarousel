//
//  PackagesPackagesInteractorInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PackagesInteractorInput {
    func getOffers()
    func getOfferApples()
    func activate(offer: OfferServiceResponse)
    func activate(offerApple: OfferApple)
    func getActiveSubscriptions()
    func getAccountType()
    func convertToSubscriptionPlans(offers: [OfferServiceResponse]) -> [SubscriptionPlan]
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse]) -> [SubscriptionPlan]
    func convertToSubscriptionPlans(offerApples: [OfferApple]) -> [SubscriptionPlan]
    
    /// MAYBE WILL BE NEED
    //func getCurrentSubscription()
}
