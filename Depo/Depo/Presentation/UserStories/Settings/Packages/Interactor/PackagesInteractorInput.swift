//
//  PackagesPackagesInteractorInput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PackagesInteractorInput {
    func getToken(for offer: PackageModelResponse)
    func getResendToken(for offer: PackageModelResponse)
    func activate(offer: PackageModelResponse, planIndex: Int)
    func verifyOffer(_ offer: PackageModelResponse?, planIndex: Int, token: String, otp: String)
    func submit(promocode: String)
    func getAvailableOffers()
    func getAccountType()
    func convertToSubscriptionPlan(offers: [PackageModelResponse], accountType: AccountType) -> [SubscriptionPlan]
    
    func restorePurchases()
    func trackScreen()
    func trackPackageClick(plan: SubscriptionPlan, planIndex: Int)
    /// MAYBE WILL BE NEED
    //func getCurrentSubscription()

    func getStorageCapacity()
    func getUserAuthority()
}
