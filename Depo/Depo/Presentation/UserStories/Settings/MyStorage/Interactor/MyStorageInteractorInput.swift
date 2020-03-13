//
//  MyStorageInteractorInput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageInteractorInput {
    func getAccountType()
    func getAccountType(with accountType: String, offers: [Any]) -> AccountType?
    func getAllOffers()
    
    func restorePurchases()
    func trackPackageClick(plan packages: SubscriptionPlan, planIndex: Int)
    func trackScreen()
    
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse],
                                    accountType: AccountType) -> [SubscriptionPlan]
}
