//
//  PackagesPackagesViewOutput.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PackagesViewOutput {
    func viewIsReady()
    func viewWillAppear()
    func didPressOn(plan: SubscriptionPlan, planIndex: Int)
    func buy(offer: PackageModelResponse, planIndex: Int)
    func submit(promocode: String)
    func restorePurchasesPressed()
    
    func getAccountType() -> AccountType

    func openTermsOfUseScreen()

    func configureCard(_ card: PackageInfoView)

    var availableOffers: [PackageOffer] { get }
}
