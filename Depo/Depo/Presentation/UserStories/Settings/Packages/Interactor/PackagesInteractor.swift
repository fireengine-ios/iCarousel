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
    private let packageService =  PackageService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    init(offersService: OffersService = OffersServiceIml(),
         subscriptionsService: SubscriptionsService = SubscriptionsServiceIml(),
         accountService: AccountServicePrl = AccountService()
    ) {
        self.offersService = offersService
        self.subscriptionsService = subscriptionsService
        self.accountService = accountService
    }
}

// MARK: PackagesInteractorInput
extension PackagesInteractor: PackagesInteractorInput {

    func getAvailableOffers() {
        accountService.availableOffers { [weak self] (result) in
            switch result {
            case .success(let response):
                DispatchQueue.toMain {
                    self?.getInfoForAppleProducts(offers: response)
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.output.failed(with: error.localizedDescription)
                }
            }
        }
    }
    
    func trackScreen() {
        analyticsService.logScreen(screen: .packages)
        analyticsService.trackDimentionsEveryClickGA(screen: .packages)
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

    func getStorageCapacity() {
        accountService.usage(success: { [weak self]  (response) in
            if let response = response as? UsageResponse {
                DispatchQueue.main.async {
                    self?.output.successed(usage: response)
                }
            } else {
                DispatchQueue.main.async {
                    let error = CustomErrors.serverError("An error occurred while getting storage info.")
                    self?.output.failed(with: error.description)
                }
            }
        }) { [weak self] errorResponse in
            DispatchQueue.main.async {
                self?.output.failedUsage(with: errorResponse)
            }
        }
    }

    func getUserAuthority() {
        accountService.permissions { [weak self] (result) in
            switch result {
            case .success(let response):
                AuthoritySingleton.shared.refreshStatus(with: response)
                DispatchQueue.main.async {
                    self?.output.successedGotUserAuthority()
                }
            case .failed(let error):
                DispatchQueue.main.async {
                    self?.output.failed(with: error.localizedDescription)
                }
            }
        }
    }
    
    func getToken(for offer: PackageModelResponse) {
        offersService.initOffer(offer: offer,
            success: { [weak self] response in
                guard let offerResponse = response as? InitOfferResponse,
                    let token = offerResponse.referenceToken
                else {
                    DispatchQueue.toMain {
                        self?.output.failedUsage(with: ErrorResponse.string("token nil"))
                    }
                    return
                }            
                DispatchQueue.toMain {
                    self?.output.successed(tokenForOffer: token)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failedUsage(with: errorResponse)
                }
        })
    }
    
    func verifyOffer(_ offer: PackageModelResponse?, planIndex: Int, token: String, otp: String) {
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
                    self?.analyticsService.trackDimentionsEveryClickGA(screen: .packages, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: false)
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
    
    func getResendToken(for offer: PackageModelResponse) {
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
    
    private func getInfoForAppleProducts(offers: [PackageModelResponse]) {
        packageService.getInfoForAppleProducts(offers: offers, success: {
            DispatchQueue.toMain {
                self.output.successed(allOffers: offers)
            }
        }, fail: { error in
            DispatchQueue.toMain {
                self.output.failed(with: error.localizedDescription)
            }
        })
    }
    
    func activate(offer: PackageModelResponse, planIndex: Int) {
        guard let product = iapManager.product(for: offer.inAppPurchaseId ?? "") else {
            let error = CustomErrors.serverError("An error occured while getting product with id - \(offer.inAppPurchaseId ?? "") from App Store")
            DispatchQueue.toMain {
                self.output.failed(with: error.localizedDescription)
            }
            return
        }

        iapManager.purchase(product: product) { [weak self] result in
            switch result {
            case .success(let identifier):
                self?.analyticsService.trackInAppPurchase(product: product)
                self?.analyticsService.trackProductInAppPurchaseGA(product: product, packageIndex: planIndex)
                self?.analyticsService.trackDimentionsEveryClickGA(screen: .packages, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: true)
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseSuccess)
                self?.validatePurchase(productId: identifier)
            case .canceled:
                self?.analyticsService.trackCustomGAEvent(eventCategory: .errors, eventActions: .paymentErrors, eventLabel: .paymentError("transaction canceled"))
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseFailure)
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: ErrorResponse.string(TextConstants.cancelPurchase))
                }
            case .error(let error):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .errors, eventActions: .paymentErrors, eventLabel: .paymentError("\(error.description)"))
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
            output.refreshPackages()
            return
        }
        
        offersService.validateApplePurchase(with: receipt, productId: productId, success: { [weak self] response in
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                self?.output.refreshPackages()
                return
            }
            
            if status == .success {
                DispatchQueue.toMain {
                    self?.output.refreshPackages()
                }
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
            DispatchQueue.toMain {
                self?.output.refreshPackages()
            }
        }
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
    
    func convertToSubscriptionPlan(offers: [PackageModelResponse], accountType: AccountType) -> [SubscriptionPlan]  {
        return packageService.convertToSubscriptionPlan(offers: offers, accountType: accountType)
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
                DispatchQueue.toMain {
                    self?.output.refreshPackages()
                }
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
}
