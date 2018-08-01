//
//  PackagesPackagesInteractor.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PackagesInteractor {
    weak var output: PackagesInteractorOutput!
    
    private let iapManager = IAPManager.shared
    
    private let offersService: OffersService
    private let subscriptionsService: SubscriptionsService
    private let accountService: AccountServicePrl
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    init(offersService: OffersService = OffersServiceIml(),
         subscriptionsService: SubscriptionsService = SubscriptionsServiceIml(),
         accountService: AccountServicePrl = AccountService()
    ) {
        self.offersService = offersService
        self.subscriptionsService = subscriptionsService
        self.accountService = accountService
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

// MARK: PackagesInteractorInput
extension PackagesInteractor: PackagesInteractorInput {
    
    func getActiveSubscriptions() {
        subscriptionsService.activeSubscriptions(
            success: { [weak self] response in
                guard let subscriptionsResponce = response as? ActiveSubscriptionResponse else { return }
                DispatchQueue.main.async {
                    self?.output.successed(activeSubscriptions: subscriptionsResponce.list)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .packages)
    }
    
    func getAccountType() {
        accountService.info(
            success: { [weak self] response in
                guard let response = response as? AccountInfoResponse,
                    let accountType = response.accountType else { return }
                DispatchQueue.main.async {
                    self?.output.successed(accountTypeString: accountType)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func getToken(for offer: OfferServiceResponse) {
        offersService.initOffer(offer: offer,
            success: { [weak self] response in
                guard let offerResponse = response as? InitOfferResponse,
                    let token = offerResponse.referenceToken
                else {
                    DispatchQueue.main.async {
                        self?.output.failedUsage(with: ErrorResponse.string("token nil"))
                    }
                    return
                }            
                DispatchQueue.main.async {
                    self?.output.successed(tokenForOffer: token)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func verifyOffer(_ offer: OfferServiceResponse?, planIndex: Int, token: String, otp: String) {
        /// to test success without buying package
///        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
///            self.output.successedVerifyOffer()
///        }
        
        offersService.verifyOffer(otp: otp, referenceToken: token,
            success: { [weak self] response in
                /// maybe will be needed
                //guard let offerResponse = response as? VerifyOfferResponse else { return }
                
                if let offer = offer {
                    self?.analyticsService.trackInnerPurchase(offer)
                    self?.analyticsService.trackProductPurchasedInnerGA(offer: offer, packageIndex: planIndex)
                    self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseSuccess)
                }

                /// delay stay for server perform request (android logic)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.output.successedVerifyOffer()
                }
            }, fail: { [weak self] errorResponse in
            self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseFailure)
                DispatchQueue.main.async {
                    self?.output.failedVerifyOffer()
                }
        })
    }
    
    func getResendToken(for offer: OfferServiceResponse) {
        offersService.initOffer(offer: offer,
            success: { [weak self] response in
                guard let offerResponse = response as? InitOfferResponse,
                    let token = offerResponse.referenceToken
                    else {
                        DispatchQueue.main.async {
                            self?.output.failedUsage(with: ErrorResponse.string("token nil"))
                        }
                        return
                }
                
                DispatchQueue.main.async {
                    self?.output.successed(tokenForResend: token)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func activate(offerApple: OfferApple, planIndex: Int) {
        iapManager.purchase(offerApple: offerApple) { [weak self] result in
            switch result {
            case .success(let identifier):
                self?.analyticsService.trackInAppPurchase(product: offerApple.skProduct)
                self?.analyticsService.trackProductInAppPurchaseGA(product: offerApple.skProduct, packageIndex: planIndex)
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseSuccess)
                self?.validatePurchase(productId: identifier)
            case .canceled:
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseFailure)
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: ErrorResponse.string(TextConstants.cancelPurchase))
                }
            case .error(let error):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseFailure)
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: ErrorResponse.error(error))
                }
            case .inProgress: 
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: ErrorResponse.string(TextConstants.inProgressPurchase))
                }
            }
        }
    }
    
    private func validatePurchase(productId: String) {
        guard let receipt = iapManager.receipt else {
            getActiveSubscriptions()
            return
        }
        
        offersService.validateApplePurchase(with: receipt, productId: productId, success: { [weak self] response in
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                self?.getActiveSubscriptions()
                return
            }
            
            if status == .success {
                self?.getActiveSubscriptions()
            } else {
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: ErrorResponse.string(status.description))
                }
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    private func validateRestorePurchase(offersApple: [OfferApple]) {
        guard let receipt = iapManager.receipt else {
            return
        }
        
        let group = DispatchGroup()
        
        //just sending reciept
        group.enter()
        offersService.validateApplePurchase(with: receipt, productId: nil, success: { response in
            group.leave()
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                return
            }
            if !(status == .restored || status == .success) {
                debugLog("validateRestorePurchaseFailed: \(status.description)")
            }
        }, fail: { errorResponse in
            debugLog("validateRestorePurchaseFailed: \(errorResponse.description)")
            group.leave()
        })
        
        group.notify(queue: .main) { [weak self] in
            self?.getActiveSubscriptions()
        }
    }
    
    func getOffers() {
        offersService.offersAll(
            success: { [weak self] response in
                guard let offerResponse = response as? OfferAllResponse else { return }
                DispatchQueue.main.async {
                    self?.output.successed(offers: offerResponse.list)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func checkJobExists() {
        offersService.getJobExists(
            success: { [weak self] response in
                guard let jobResponse = response as? JobExistsResponse,
                    let isJobExists = jobResponse.isJobExists
                    else { return }
                DispatchQueue.main.async {
                    self?.output.successedJobExists(isJobExists: isJobExists)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func submit(promocode: String) {
        if promocode.isEmpty {
            DispatchQueue.main.async {
                self.output.failedPromocode(with: TextConstants.promocodeEmpty)
            }
            return
        }
        offersService.submit(promocode: promocode,
             success: { [weak self] response in
                /// maybe will be need
                ///guard let response = response as? SubmitPromocodeResponse else { return }
                DispatchQueue.main.async {
                    self?.output.successedPromocode()
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    if case ErrorResponse.httpCode(500) = errorResponse {
                        self?.output.failedPromocode(with: TextConstants.promocodeError)
                    } else {
                        self?.output.failedPromocode(with: errorResponse.description)
                    }
                }
        })
    }
    
    func getOfferApples() {
        offersService.offersAllApple(
            success: { [weak self] response in
                guard let offerResponse = response as? OfferAllAppleServiceResponse else { return }
                self?.iapManager.loadProducts(productIds: offerResponse.list, handler: { [weak self] result in
                    switch result {
                    case .success(let array):
                        DispatchQueue.toMain {
                            self?.output.successed(offerApples: array)
                        }
                    case .failed(let error):
                        DispatchQueue.toMain {
                            self?.output.failedUsage(with: ErrorResponse.error(error))
                        }
                    }
                })
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func convertToSubscriptionPlans(offers: [OfferServiceResponse], accountType: AccountType) -> [SubscriptionPlan] {
        return offers.flatMap { offer in
            guard let price = offer.price, let name = offer.quota?.bytesString else {
                return nil
            }
            
            let currency = getCurrency(for: accountType)
            let priceString = String(format: TextConstants.offersPrice, price, currency)
            
            return subscriptionPlanWith(name: name, priceString: priceString, type: .default, model: offer)
        }
    }
    
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse], accountType: AccountType) -> [SubscriptionPlan] {
        return activeSubscriptionList.flatMap { subscription in
            guard let price = subscription.subscriptionPlanPrice, let name = subscription.subscriptionPlanQuota?.bytesString else {
                return nil
            }
            
            let currency: String
            let priceString: String
            
            if let inAppPurchaseId = subscription.subscriptionPlanInAppPurchaseId,
                let localizedPrice = iapManager.product(for: inAppPurchaseId)?.localizedPrice {
                priceString = String(format: TextConstants.offersLocalizedPrice, localizedPrice)
            } else {
                if let subscriptionType = subscription.type, subscriptionType == .free {
                    ///free subscription should have the same currency as account type has
                    currency = getCurrency(for: accountType)
                } else {
                    currency = getCurrency(for: subscription)
                }
                priceString = String(format: TextConstants.offersPrice, price, currency)
            }
            
            let type: SubscriptionPlanType = price == 0 ? .free : .current
            
            return subscriptionPlanWith(name: name, priceString: priceString, type: type, model: subscription)
        }
    }
    
    func convertToSubscriptionPlans(offerApples: [OfferApple]) -> [SubscriptionPlan] {
        return offerApples.flatMap { offer in
            guard let name = offer.name else {
                return nil
            }
            
            let currency = getCurrency(for: AccountType.all)
            
            let priceString: String
            if let price = offer.price {
                priceString = String(format: TextConstants.offersLocalizedPrice, price)
            } else {
                priceString = String(format: TextConstants.offersPrice, currency, offer.rawPrice)
            }
            
            return subscriptionPlanWith(name: name, priceString: priceString, type: .default, model: offer)
        }
    }

    func restorePurchases() {
        guard !sendReciept() else {
            return
        }
        
        iapManager.restorePurchases { [weak self] result in
            switch result {
            case .success(let _):
//                let offers = productIds.map { OfferApple(productId: $0) } ///Backend dont need this for now
                self?.validateRestorePurchase(offersApple: [])

            case .fail(let error):
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: ErrorResponse.error(error))
                }
            }
        }
    }
    
    func trackPackageClick(plan packages: SubscriptionPlan, planIndex: Int) {
        analyticsService.trackPackageClick(package:
            packages, packageIndex: planIndex)
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
                self?.getActiveSubscriptions()
            } else {
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: ErrorResponse.string(status.description))
                }
            }
            
        }, fail: { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.output.failedUsage(with: errorResponse)
            }
        })
        
        return true
    }
    
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
}
