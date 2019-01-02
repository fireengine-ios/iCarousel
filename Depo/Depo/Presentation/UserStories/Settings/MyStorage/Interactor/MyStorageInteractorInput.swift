//
//  MyStorageInteractorInput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageInteractorInput {
    func getUsage()
    func getAccountType()
    func getAccountType(with accountType: String, offers: [Any]) -> AccountType
    func getAllOffers(with accountType: AccountType)
    
    func trackPackageClick(plan packages: SubscriptionPlan, planIndex: Int)
    
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse],
                                    accountType: AccountType) -> [SubscriptionPlan]
}
