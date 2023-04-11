//
//  MyStorageViewOutput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageViewOutput {
    func viewDidLoad()
    
    func didPressOn(plan: SubscriptionPlan, planIndex: Int)
    func didPressOnOffers(plan: SubscriptionPlan, planIndex: Int)
    func restorePurchasesPressed()
    func configureCard(_ card: PackageInfoView)

    var displayableOffers: [SubscriptionPlan] { get }
    var accountType: AccountType { get }
    var title: String { get }
    
    var availableOffers: [SubscriptionPlan] { get }
    func getAccountTypePackages() -> AccountType
    func viewWillAppear()
    func showPremiumProcess()
}
