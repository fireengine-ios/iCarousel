//
//  PremiumInteractor.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import WidgetKit

final class PremiumInteractor {
    
    weak var output: PremiumInteractorOutput!
    
    private let iapManager = IAPManager.shared
    private let accountService: AccountServicePrl = AccountService()
    private let offersService: OffersService = OffersServiceIml()
    private let packageService: PackageService = PackageService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
}

// MARK: PremiumInteractorInput
extension PremiumInteractor: PremiumInteractorInput {
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.BecomePremiumScreen())
    }
    
    func trackPackageClick(plan packages: SubscriptionPlan) {
        ///there is may be only one package for becoming premium so packageIndex == 1
        analyticsService.trackPackageClick(package: packages, packageIndex: 1)
    }
    
    func getAccountType() {
        accountService.info(
            success: { [weak self] response in
                DispatchQueue.toMain {
                    guard let response = response as? AccountInfoResponse, let accountType = response.accountType else {
                        self?.output.stopLoading()
                        assertionFailure("An error occurred while getting account info.")
                        return
                    }
                    self?.output.successed(accountType: accountType)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failed(with: errorResponse)
                }
        })
    }
    
    func getFeaturePacks() {
        accountService.newFeaturePacks { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.toMain {
                    self?.output.successed(allFeatures: response)
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    if error.isServerUnderMaintenance {
                        self?.output.failed(with: .error(error))
                    } else {
                        self?.output.switchToTextWithoutPrice(isError: true)
                    }
                }
            }
        }
    }
    
    func getInfoForAppleProducts(offers: [PackageModelResponse]) {
        packageService.getInfoForAppleProducts(offers: offers, success: { [weak self] in
            DispatchQueue.toMain {
                self?.output.successedGotAppleInfo(offers: offers)
            }
        }, fail: { [weak self] error in
            DispatchQueue.toMain {
                if error.isServerUnderMaintenance {
                    self?.output.failed(with: .error(error))
                } else {
                    self?.output.switchToTextWithoutPrice(isError: true)
                }
            }
        })
    }
    
    func getPriceInfo(for offer: PackageModelResponse, accountType: AccountType) -> String {
        return packageService.getOfferPrice(for: offer, accountType: accountType)
    }
    
    func convertToSubscriptionPlan(offers: [PackageModelResponse], accountType: AccountType) -> [SubscriptionPlan]  {
        return packageService.convertToSubscriptionPlan(offers: offers, accountType: accountType)
    }
    
    //MARK: apple purchase
    func activate(offer: PackageModelResponse) {
        guard let product = iapManager.product(for: offer.inAppPurchaseId ?? "") else {
            DispatchQueue.toMain {
                self.output.stopLoading()
            }
            assertionFailure(
                "An error occured while getting product with id - \(offer.inAppPurchaseId ?? "") from App Store"
            )
            return
        }
        
        iapManager.purchase(product: product) { [weak self] result in
            switch result {
            case .success(let identifier):
                self?.analyticsService.trackPurchase(offer: product)
                self?.analyticsService.trackProductInAppPurchaseGA(product: product, packageIndex: 0)
                self?.analyticsService.trackDimentionsEveryClickGA(screen: .packages, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: true)
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .success)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackagePurchase(status: .success, channelType: .appStore, packageName: offer.displayName ?? ""))
                self?.validatePurchase(productId: identifier)
            case .canceled:
                self?.analyticsService.trackCustomGAEvent(eventCategory: .errors, eventActions: .paymentErrors, eventLabel: .paymentError("transaction canceled"))
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .failure)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackagePurchase(status: .failure, channelType: .appStore, packageName: offer.displayName ?? ""))
                DispatchQueue.main.async {
                    self?.output.purchaseCancelled()
                }
            case .error(let error):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .errors, eventActions: .paymentErrors, eventLabel: .paymentError("\(error.description)"))
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .failure)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackagePurchase(status: .failure, channelType: .appStore, packageName: offer.displayName ?? ""))
                DispatchQueue.main.async {
                    self?.output.failed(with: .error(error))
                }
            case .inProgress:
                DispatchQueue.main.async {
                    self?.output.failed(with: ErrorResponse.string(TextConstants.inProgressPurchase))
                }
            }
        }
    }
    
    private func validatePurchase(productId: String) {
        guard let receipt = iapManager.receipt else {
            DispatchQueue.toMain {
                self.output.stopLoading()
            }
            assertionFailure("An error occured while getting receipt from Apple Store.")
            return
        }
        
        offersService.validateApplePurchase(with: receipt, productId: productId, success: { [weak self] response in
            guard
                let response = response as? ValidateApplePurchaseResponse,
                let status = response.status
            else {
                DispatchQueue.main.async {
                    self?.output.stopLoading()
                }
                assertionFailure("Something went wrong on validation apple purchase.")
                return
            }
            
            if status == .success {
                
                if let product = self?.iapManager.product(for: productId) {
                    self?.analyticsService.trackPurchase(offer: product)
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                
                DispatchQueue.toMain {
                    self?.output.purchaseFinished()
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
    }
    
    private func validateRestorePurchase(offersApple: [OfferApple]) {
        guard let receipt = iapManager.receipt else {
            DispatchQueue.main.async {
                self.output.stopLoading()
            }
            assertionFailure("An error occured while getting receipt from Apple Store.")
            return
        }
        
        let group = DispatchGroup()
        
        //just sending reciept
        group.enter()
        offersService.validateApplePurchase(with: receipt, productId: nil, success: { [weak self] response in
            group.leave()
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                DispatchQueue.main.async {
                    self?.output.stopLoading()
                }
                assertionFailure("An error occurred while getting response for purchase validation")
                return
            }
            if !(status == .restored || status == .success) {
                debugLog("validateRestorePurchaseFailed: \(status.description)")
                DispatchQueue.toMain {
                    self?.output.failed(with: .string(status.description))
                }
            }
        }, fail: { [weak self] errorResponse in
            debugLog("validateRestorePurchaseFailed: \(errorResponse.description)")
            DispatchQueue.toMain {
                self?.output.failed(with: errorResponse)
            }
            group.leave()
        })
        
        group.notify(queue: .main) { [weak self] in
            DispatchQueue.toMain {
                self?.output.purchaseFinished()
            }
        }
    }
    
    //MARK: turkcell purchase
    func getToken(for offer: PackageModelResponse) {
        offersService.initOffer(offer: offer, success: { [weak self] response in
            guard let offerResponse = response as? InitOfferResponse, let token = offerResponse.referenceToken else {
                DispatchQueue.main.async {
                    self?.output.stopLoading()
                }
                assertionFailure("An error occurred while getting token.")
                return
            }
            
            DispatchQueue.toMain {
                self?.output.successed(tokenForOffer: token)
            }
        }, fail: { [weak self] errorResponse in
            DispatchQueue.toMain {
                self?.output.failed(with: errorResponse)
            }
        })
    }
    
    func getResendToken(for offer: PackageModelResponse) {
        offersService.initOffer(offer: offer,
                                success: { [weak self] response in
                                    guard
                                        let offerResponse = response as? InitOfferResponse,
                                        let token = offerResponse.referenceToken
                                        else {
                                            DispatchQueue.main.async {
                                                self?.output.stopLoading()
                                            }
                                            assertionFailure("An error occurred while getting token.")
                                            return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self?.output.successed(tokenForResend: token)
                                    }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedResendToken(with: errorResponse.description)
                }
        })
    }
    
    func verifyOffer(_ offer: PackageModelResponse, token: String, otp: String) {
        offersService.verifyOffer(otp: otp, referenceToken: token,
                                  success: { [weak self] response in
                                    
                                    self?.analyticsService.trackPurchase(offer: offer)
                                    if #available(iOS 14.0, *) {
                                        WidgetCenter.shared.reloadAllTimelines()
                                    }
                                    ///there is may be only one package for becoming premium so packageIndex == 1
                                    self?.analyticsService.trackProductPurchasedInnerGA(offer: offer, packageIndex: 1)

                                    /// delay stay for server perform request (android logic)»
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                        self?.output.successedVerifyOffer()
                                    }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedVerifyOffer()
                }
        })
    }
}
