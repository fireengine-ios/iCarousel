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
    func getActiveSubscription() {
        subscriptionsService.activeSubscriptions(success: { [weak self] response in
            guard let subscriptionsResponse = response as? ActiveSubscriptionResponse else {
                let error = CustomErrors.serverError("An error occured while getting active subscription")
                DispatchQueue.toMain {
                    self?.output.didErrorMessage(with: error.localizedDescription)
                }
                return
            }
            SingletonStorage.shared.activeUserSubscription = subscriptionsResponse
            DispatchQueue.toMain {
                self?.output.didLoadActiveSubscriptions(subscriptionsResponse.list)
            }
        }) { [weak self] error in
            DispatchQueue.toMain {
                self?.output.didErrorMessage(with: error.description)
            }
        }
    }
    
    func getPrice(for offer: SubscriptionPlanBaseResponse, accountType: AccountType) -> String {
        return packageService.getPriceInfo(for: offer, accountType: accountType)
    }
    
    func getAppleInfo(for offer: SubscriptionPlanBaseResponse) {
        packageService.getInfoForAppleProducts(offers: [offer], isActivePurchases: true, success: { [weak self] in
            DispatchQueue.toMain {
                self?.output.didLoadInfoFromApple()
            }
        }, fail: { [weak self] error in
            DispatchQueue.toMain {
                self?.output.didErrorMessage(with: error.description)
            }
        })
    }
    
    func getAccountType(with accountType: String, offers: [Any]) -> AccountType {
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
            screenTypeGA = .premiumAccountDetails
        }
        analyticsService.logScreen(screen: screenTypeGA)
    }
}
