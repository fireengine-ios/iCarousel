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
    func checkJobExists()
    func getOfferApples()
    func getToken(for offer: OfferServiceResponse)
    func getResendToken(for offer: OfferServiceResponse)
    func activate(offerApple: OfferApple)
    func verifyOffer(_ offer: OfferServiceResponse?, token: String, otp: String)
    func submit(promocode: String)
    func getActiveSubscriptions()
    func getAccountType()
    func convertToSubscriptionPlans(offers: [OfferServiceResponse], accountType: AccountType) -> [SubscriptionPlan]
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse], accountType: AccountType) -> [SubscriptionPlan]
    func convertToSubscriptionPlans(offerApples: [OfferApple]) -> [SubscriptionPlan]
    
    func restorePurchases()
    /// MAYBE WILL BE NEED
    //func getCurrentSubscription()
}
