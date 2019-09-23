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
        packageService.getInfoForAppleProducts(offers: offers, isActivePurchases: true, success: { [weak self] in
            DispatchQueue.toMain {
                self?.output.successed(allOffers: offers)
            }
            }, fail: { [weak self] error in
                DispatchQueue.toMain {
                    self?.output.successed(allOffers: offers)
                    self?.output.failed(with: error.description)
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
    
    func getAccountType(with accountType: String, offers: [Any]) -> AccountType? {
        return packageService.getAccountType(for: accountType, offers: offers)
    }
    
    func getAllOffers() {
        subscriptionsService.activeSubscriptions(
            success: { [weak self] response in
                guard let subscriptionsResponse = response as? ActiveSubscriptionResponse else {
                    let error = CustomErrors.serverError("An error occured while getting active subscription")
                    DispatchQueue.toMain {
                        self?.output.failed(with: error.localizedDescription)
                    }
                    return
                }
                SingletonStorage.shared.activeUserSubscription = subscriptionsResponse
                
                let offersList = subscriptionsResponse.list
                
                self?.getInfoForAppleProducts(offers: offersList)

            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failed(with: errorResponse)
                }
        })
    }
    
    func restorePurchases() {
        guard !sendReciept() else {
            return
        }
        
        iapManager.restorePurchases { [weak self] result in
            switch result {
            case .success:
//                let offers = productIds.map { OfferApple(productId: $0) } ///Backend dont need this for now
                self?.validateRestorePurchase(offersApple: [])
                
            case .fail(let error):
                DispatchQueue.main.async {
                    self?.output.failed(with: ErrorResponse.error(error))
                }
            }
        }
    }
    
    private func sendReciept() -> Bool {
        guard let receipt = iapManager.receipt else {
            return false
        }
        
        offersService.validateApplePurchase(with: receipt, productId: nil, success: { [weak self] response in
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                return
            }
            
            if status == .restored || status == .success {
                DispatchQueue.toMain {
                    self?.output.refreshPackages()
                }
            } else {
                DispatchQueue.main.async {
                    self?.output.failed(with: ErrorResponse.string(status.description))
                }
            }
            
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failed(with: errorResponse)
                }
        })
        
        return true
    }
    
    private func validateRestorePurchase(offersApple: [OfferApple]) {
        guard let receipt = iapManager.receipt else {
            return
        }
        
        //just sending reciept
        offersService.validateApplePurchase(with: receipt, productId: nil, success: { [weak self] response in
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                return
            }
            if !(status == .restored || status == .success) {
                debugLog("validateRestorePurchaseFailed: \(status.description)")
                
                DispatchQueue.main.async {
                    self?.output.failed(with: ErrorResponse.string(status.description))
                }
            } else {
                DispatchQueue.toMain {
                    self?.output.refreshPackages()
                }
            }
        }, fail: { [weak self] errorResponse in
            debugLog("validateRestorePurchaseFailed: \(errorResponse.description)")
            
            DispatchQueue.toMain {
                self?.output.failed(with: errorResponse)
            }
        })
    }
    
    func trackPackageClick(plan packages: SubscriptionPlan, planIndex: Int) {
        analyticsService.trackPackageClick(package: packages, packageIndex: planIndex)
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .myStorage)
    }
    
    //MARK: Converter
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse], accountType: AccountType) -> [SubscriptionPlan] {
        return packageService.convertToSubscriptionPlan(offers:activeSubscriptionList, accountType:accountType)
    }
}
