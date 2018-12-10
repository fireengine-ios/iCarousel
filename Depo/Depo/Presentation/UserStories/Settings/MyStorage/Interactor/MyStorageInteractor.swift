//
//  MyStorageInteractor.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class MyStorageInteractor {
    weak var output: MyStorageInteractorOutput!
    
    private let iapManager = IAPManager.shared
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    private let subscriptionsService: SubscriptionsService = SubscriptionsServiceIml()
    private let accountService: AccountServicePrl = AccountService()
    private let offersService: OffersService = OffersServiceIml()
    private let packageService = PackageService()
}

//MARK: - MyStorageInteractorInput
extension MyStorageInteractor: MyStorageInteractorInput {
    
    func getUsage() {
        accountService.usage(
            success: { [weak self] response in
                guard let usage = response as? UsageResponse else {
                    let error = CustomErrors.serverError("An error occured while getting storage usage")
                    DispatchQueue.toMain {
                        self?.output.failed(with: error.localizedDescription)
                    }
                    return
                }
                DispatchQueue.toMain {
                    self?.output.successed(usage: usage)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failed(with: errorResponse)
                }
        })
    }
    
    func getAccountType() {
        accountService.info(success: {  [weak self] (response) in
            guard let response = response as? AccountInfoResponse else {
                let error = CustomErrors.serverError("An error occured while getting account info")
                DispatchQueue.toMain {
                    self?.output.failed(with: error.localizedDescription)
                }
                return
            }
            DispatchQueue.toMain {
                self?.output.successed(accountInfo: response)
            }
        }) { [weak self] (error) in
            DispatchQueue.toMain {
                self?.output.failed(with: error)
            }
        }
    }
    
    func getAllOffers() {
        subscriptionsService.activeSubscriptions(
            success: { [weak self] response in
                guard let subscriptionsResponce = response as? ActiveSubscriptionResponse else {
                    let error = CustomErrors.serverError("An error occured while getting active subscription")
                    DispatchQueue.toMain {
                        self?.output.failed(with: error.localizedDescription)
                    }
                    return
                }
                SingletonStorage.shared.activeUserSubscription = subscriptionsResponce
                self?.getInfoForAppleProducts(offers: subscriptionsResponce.list)
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failed(with: errorResponse)
                }
        })
    }
    
    private func getInfoForAppleProducts(offers: [SubscriptionPlanBaseResponse]) {
        packageService.getInfoForAppleProducts(offers: offers, success: { [weak self] in
            DispatchQueue.toMain {
                self?.output.successed(allOffers: offers)
            }
        }, fail: { [weak self] error in
            DispatchQueue.toMain {
                self?.output.failed(with: error.localizedDescription)
            }
        })
    }
    
    func trackPackageClick(plan packages: SubscriptionPlan, planIndex: Int) {
        analyticsService.trackPackageClick(package: packages, packageIndex: planIndex)
    }
    
    //MARK: Converter
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse], accountType: AccountType) -> [SubscriptionPlan] {
        return packageService.convertToSubscriptionPlan(offers:activeSubscriptionList, accountType:accountType)
    }
}
