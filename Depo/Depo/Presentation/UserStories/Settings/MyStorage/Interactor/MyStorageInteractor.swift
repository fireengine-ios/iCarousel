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
    
    private func getInfoForAppleProducts(offers: [SubscriptionPlanBaseResponse]) {
        packageService.getInfoForAppleProducts(offers: offers, success: { [weak self] in
            DispatchQueue.toMain {
                self?.output.successed(allOffers: offers)
            }
            }, fail: { [weak self] error in
                DispatchQueue.toMain {
                    self?.output.successed(allOffers: offers)
                    self?.output.failed(with: error.localizedDescription)
                }
        })
    }
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
    
    func getAccountType(with accountType: String, offers: [Any]) -> AccountType {
        return packageService.getAccountType(for: accountType, offers: offers)
    }
    
    func getAllOffers(with accountType: AccountType) {
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
                
                let offersList = subscriptionsResponce.list
                if accountType != .turkcell {
                    self?.getInfoForAppleProducts(offers: offersList)
                } else {
                    self?.output.successed(allOffers: offersList)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failed(with: errorResponse)
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
