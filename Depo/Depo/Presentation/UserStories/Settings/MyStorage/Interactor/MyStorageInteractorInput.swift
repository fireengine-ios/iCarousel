//
//  MyStorageInteractorInput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageInteractorInput {
    
    func getAvailableOffers(with accountType: AccountType)
    func convertToSubscriptionPlan(offers: [PackageModelResponse], accountType: AccountType) -> [SubscriptionPlan]
    
    func getAccountTypePackages(with accountType: String, offers: [Any]) -> AccountType?
    func getAccountTypePackages()
    func getToken(for offer: PackageModelResponse)
    func getResendToken(for offer: PackageModelResponse)
    func verifyOffer(_ offer: PackageModelResponse?, planIndex: Int, token: String, otp: String)
    
    func getAccountType()
    func getAccountType(with accountType: String, offers: [Any]) -> AccountType?
    func getAllOffers()
    
    func restorePurchases()
    func trackPackageClick(plan packages: SubscriptionPlan, planIndex: Int)
    func trackNetmeraPackageCancelClick(type: String, packageName: String)
    func trackScreen()
    
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse],
                                    accountType: AccountType) -> [SubscriptionPlan]
    func activate(offer: PackageModelResponse, planIndex: Int)
    func getUserAuthority()
    func refreshActivePurchasesState(_ isActivePurchases: Bool)
}
