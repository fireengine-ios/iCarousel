//
//  LeavePremiumInteractor.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class LeavePremiumInteractor {
    
    weak var output: LeavePremiumInteractorOutput!
    
    private let accountService: AccountServicePrl
    private let packageService: PackageService
    private let subscriptionsService: SubscriptionsService

    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    init(accountService: AccountServicePrl = AccountService(),
         subscriptionsService: SubscriptionsService = SubscriptionsServiceIml(),
         packageService: PackageService = PackageService()) {
        self.accountService = accountService
        self.subscriptionsService = subscriptionsService
        self.packageService = packageService
    }
    
}

// MARK: LeavePremiumInteractorInput
extension LeavePremiumInteractor: LeavePremiumInteractorInput {
    
    func getAccountType(with accountType: String, offers: [Any]) -> AccountType? {
        return packageService.getAccountType(for: accountType, offers: offers)
    }
    
    func trackScreen(screenType: LeavePremiumType) {
        let screenTypeGA: AnalyticsAppScreens
        switch screenType {
        case .standard:
            screenTypeGA = .standartAccountDetails
        case .middle:
            screenTypeGA = .standartPlusAccountDetails
        case .premium:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PremiumDetailsScreen())
            screenTypeGA = .premiumAccountDetails
        }
        analyticsService.logScreen(screen: screenTypeGA)
    }
}
