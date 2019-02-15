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
    func getAccountType() {
        accountService.info(
            success: { [weak self] response in
                guard let response = response as? AccountInfoResponse,
                    let accountType = response.accountType else { return }
                DispatchQueue.main.async {
                    self?.output.didLoadAccountType(accountTypeString: accountType)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.didErrorMessage(with: errorResponse.description)
                }
        })
    }
    
    func getActiveSubscription() {
        subscriptionsService.activeSubscriptions(success: { [weak self] response in
            guard let subscriptionsResponce = response as? ActiveSubscriptionResponse else {
                let error = CustomErrors.serverError("An error occured while getting active subscription")
                DispatchQueue.toMain {
                    self?.output.didErrorMessage(with: error.localizedDescription)
                }
                return
            }
            SingletonStorage.shared.activeUserSubscription = subscriptionsResponce
            DispatchQueue.toMain {
                self?.output.didLoadActiveSubscriptions(subscriptionsResponce.list)
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
        packageService.getInfoForAppleProducts(offers: [offer], success: { [weak self] in
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
}
