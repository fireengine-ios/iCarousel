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
                DispatchQueue.main.async {
                    self?.output.failed(with: errorResponse)
                }
        })
    }
    
    private func getInfoForAppleProducts(offers: [SubscriptionPlanBaseResponse]) {
        let appleOffers = offers.flatMap({ return $0.subscriptionPlanInAppPurchaseId })
        iapManager.loadProducts(productIds: appleOffers) { [weak self] response in
            switch response {
            case .success(_):
                DispatchQueue.toMain {
                    self?.output.successed(allOffers: offers)
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.output.failed(with: error.localizedDescription)
                }
            }
        }
    }
    
    func trackPackageClick(plan packages: SubscriptionPlan, planIndex: Int) {
        analyticsService.trackPackageClick(package: packages, packageIndex: planIndex)
    }
    
    //MARK: converter
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse], accountType: AccountType) -> [SubscriptionPlan] {
        return activeSubscriptionList.flatMap { subscription in
            guard let price = subscription.subscriptionPlanPrice, let name = subscription.subscriptionPlanQuota?.bytesString else {
                return nil
            }
            
            if subscription.subscriptionPlanFeatureType != nil {
                return nil
            }
            
            let priceString: String
            
            if subscription.subscriptionPlanType == .apple, let product = iapManager.product(for: subscription.subscriptionPlanInAppPurchaseId ?? "") {
                let price = product.localizedPrice
                let period: String
                if #available(iOS 11.2, *) {
                    switch product.subscriptionPeriod?.unit.rawValue {
                    case 0:
                        period = TextConstants.packagePeriodDay
                    case 1:
                        period = TextConstants.packagePeriodWeek
                    case 2:
                        period = TextConstants.packagePeriodMonth
                    case 3:
                        period = TextConstants.packagePeriodYear
                    default:
                        period = TextConstants.packagePeriodMonth
                    }
                } else {
                    period = (subscription.subscriptionPlanPeriod ?? "").lowercased()
                }
                priceString = String(format: TextConstants.packageApplePrice, price, period)
            } else {
                let currency = (subscription.subscriptionPlanCurrency ?? getCurrency(for: subscription))
                priceString = String(format: TextConstants.offersPrice, price, currency)
            }
            
            let type: SubscriptionPlanType = price == 0 ? .free : .current
            
            return subscriptionPlanWith(name: name, priceString: priceString, type: type, model: subscription)
        }
    }
    
    //MARK: UtilityMethods
    private func getCurrency(for accountType: AccountType) -> String {
        switch accountType {
        ///https://en.wikipedia.org/wiki/Northern_Cyprus
        case .turkcell, .cyprus:
            return "TL"
        case .ukranian:
            return "UAH"
        case .moldovian:
            return "MDL"
        case .life:
            return "BYN"
        case .all:
            return "$" /// temp
        }
    }
    
    private func getCurrency(for subscription: SubscriptionPlanBaseResponse) -> String {
        var type: AccountType = .turkcell
        
        if let role = subscription.subscriptionPlanRole {
            if role.hasPrefix("lifebox") {
                type = .ukranian
            } else if role.hasPrefix("kktcell") {
                type = .cyprus
            } else if role.hasPrefix("moldcell") {
                type = .moldovian
            } else if role.hasPrefix("life") {
                type = .life
            }
        }
        return getCurrency(for: type)
    }
    
    private func subscriptionPlanWith(name: String, priceString: String, type: SubscriptionPlanType, model: Any) -> SubscriptionPlan {
        if name.contains("500") {
            return SubscriptionPlan(name: name,
                                    photosCount: 500_000,
                                    videosCount: 50_000,
                                    songsCount: 250_000,
                                    docsCount: 5_000_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if name.contains("50") {
            return SubscriptionPlan(name: name,
                                    photosCount: 50_000,
                                    videosCount: 5_000,
                                    songsCount: 25_000,
                                    docsCount: 500_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if name.contains("100") {
            return SubscriptionPlan(name: name,
                                    photosCount: 100_000,
                                    videosCount: 10_000,
                                    songsCount: 50_000,
                                    docsCount: 1_000_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if name.contains("2.5") || name.contains("2,5") {
            return SubscriptionPlan(name: name,
                                    photosCount: 2_560_000,
                                    videosCount: 256_000,
                                    songsCount: 1_280_000,
                                    docsCount: 25_600_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if name.contains("5") {
            return SubscriptionPlan(name: name,
                                    photosCount: 5_000,
                                    videosCount: 500,
                                    songsCount: 2_500,
                                    docsCount: 50_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else {
            return SubscriptionPlan(name: name,
                                    photosCount: 0,
                                    videosCount: 0,
                                    songsCount: 0,
                                    docsCount: 0,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        }
    }
}
