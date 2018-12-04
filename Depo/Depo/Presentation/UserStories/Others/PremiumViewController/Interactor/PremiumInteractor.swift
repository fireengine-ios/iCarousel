//
//  PremiumInteractor.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PremiumInteractor {
    
    weak var output: PremiumInteractorOutput!
    
    private let iapManager = IAPManager.shared
    private let accountService: AccountServicePrl = AccountService()
    private let offersService: OffersService = OffersServiceIml()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    //MARK: - Utility Methids(public)
    func getPriceInfo(for offer: PackageModelResponse, accountType: AccountType) -> String {
        if let iapProductId = offer.inAppPurchaseId, let product = iapManager.product(for: iapProductId) {
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
                period = (offer.period ?? "").lowercased()
            }
            return String(format: TextConstants.packageApplePrice, price, period)
        } else {
            if let price = offer.price {
                let currency = offer.currency ?? getCurrency(for: accountType)
                if let period = offer.period?.lowercased() {
                    return String(format: TextConstants.packageApplePrice, (String(price) + " " + currency), period)
                } else {
                    return String(price) + " " + currency
                }
            } else {
                return TextConstants.free
            }
        }
    }
    
    //MARK: - Utility Methids(private)
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
    
    private func getInfoForAppleProducts(offers: [PackageModelResponse]) {
        let appleOffers = offers.flatMap({ return $0.inAppPurchaseId })
        iapManager.loadProducts(productIds: appleOffers) { [weak self] response in
            switch response {
            case .success(_):
                DispatchQueue.toMain {
                    self?.output.successed(allFeatures: offers)
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.output.failed(with: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: PremiumInteractorInput
extension PremiumInteractor: PremiumInteractorInput {
    func getAccountType() {
        accountService.info(
            success: { [weak self] response in
                guard let response = response as? AccountInfoResponse, let accountType = response.accountType else {
                    let error = CustomErrors.serverError("An error occurred while getting account info.")
                    DispatchQueue.toMain {
                        self?.output.failed(with: error.localizedDescription)
                    }
                    return
                }
                DispatchQueue.toMain {
                    self?.output.successed(accountType: accountType)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failed(with: errorResponse.description)
                }
        })
    }
    
    func getFeaturePacks(isAppleProduct: Bool) {
        accountService.featurePacks { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.toMain {
                    if isAppleProduct {
                        self?.getInfoForAppleProducts(offers: response)
                    } else {
                        self?.output.successed(allFeatures: response)
                    }
                }
            case .failed(let error):
                DispatchQueue.toMain {
                    self?.output.failed(with: error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: apple purchase
    func activate(offer: PackageModelResponse) {
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
                self?.analyticsService.trackProductInAppPurchaseGA(product: product, packageIndex: 0)
                self?.analyticsService.trackDimentionsEveryClickGA(screen: .packages, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: true)
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseSuccess)
                self?.validatePurchase(productId: identifier)
            case .canceled:
                self?.analyticsService.trackCustomGAEvent(eventCategory: .errors, eventActions: .paymentErrors, eventLabel: .paymentError("transaction canceled"))
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseFailure)
                DispatchQueue.main.async {
                    self?.output.failed(with: ErrorResponse.string(TextConstants.cancelPurchase).description)
                }
            case .error(let error):
                self?.analyticsService.trackCustomGAEvent(eventCategory: .errors, eventActions: .paymentErrors, eventLabel: .paymentError("\(error.description)"))
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .purchaseFailure)
                DispatchQueue.main.async {
                    self?.output.failed(with: error.localizedDescription)
                }
            case .inProgress:
                DispatchQueue.main.async {
                    self?.output.failed(with: ErrorResponse.string(TextConstants.inProgressPurchase).description)
                }
            }
        }
    }
    
    private func validatePurchase(productId: String) {
        guard let receipt = iapManager.receipt else {
            let error = CustomErrors.serverError("An error occured while getting receipt from Apple Store.")
            DispatchQueue.toMain {
                self.output.failed(with: error.localizedDescription)
            }
            return
        }
        
        offersService.validateApplePurchase(with: receipt, productId: productId, success: { [weak self] response in
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                let error = CustomErrors.text("Something went wrong on validation apple purchase.")
                DispatchQueue.toMain {
                    self?.output.failed(with: error.localizedDescription)
                }
                return
            }
            
            if status == .success {
                DispatchQueue.toMain {
                    self?.output.purchaseFinished()
                }
            } else {
                DispatchQueue.main.async {
                    self?.output.failed(with: ErrorResponse.string(status.description).description)
                }
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failed(with: errorResponse.description)
                }
        })
    }
    
    private func validateRestorePurchase(offersApple: [OfferApple]) {
        guard let receipt = iapManager.receipt else {
            let error = CustomErrors.serverError("An error occured while getting receipt from Apple Store.")
            DispatchQueue.toMain {
                self.output.failed(with: error.localizedDescription)
            }
            return
        }
        
        let group = DispatchGroup()
        
        //just sending reciept
        group.enter()
        offersService.validateApplePurchase(with: receipt, productId: nil, success: { [weak self] response in
            group.leave()
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                let error = CustomErrors.serverError("An error occurred while getting response for purchase validation")
                DispatchQueue.toMain {
                    self?.output.failed(with: error.localizedDescription)
                }
                return
            }
            if !(status == .restored || status == .success) {
                debugLog("validateRestorePurchaseFailed: \(status.description)")
                let error = CustomErrors.serverError(status.description)
                DispatchQueue.toMain {
                    self?.output.failed(with: error.localizedDescription)
                }
            }
        }, fail: { [weak self] errorResponse in
            debugLog("validateRestorePurchaseFailed: \(errorResponse.description)")
            DispatchQueue.toMain {
                self?.output.failed(with: errorResponse.description)
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
        offersService.initOffer(offer: offer,
                                success: { [weak self] response in
                                    guard let offerResponse = response as? InitOfferResponse,
                                        let token = offerResponse.referenceToken
                                        else {
                                            let error = CustomErrors.serverError("An error occurred while getting token.")
                                            DispatchQueue.toMain {
                                                self?.output.failed(with: error.localizedDescription)
                                            }
                                            return
                                    }
                                    DispatchQueue.toMain {
                                        self?.output.successed(tokenForOffer: token)
                                    }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failed(with: errorResponse.description)
                }
        })
    }
    
    func getResendToken(for offer: PackageModelResponse) {
        offersService.initOffer(offer: offer,
                                success: { [weak self] response in
                                    guard let offerResponse = response as? InitOfferResponse,
                                        let token = offerResponse.referenceToken
                                        else {
                                            let error = CustomErrors.serverError("An error occurred while getting token.")
                                            DispatchQueue.main.async {
                                                self?.output.failed(with: error.localizedDescription)
                                            }
                                            return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self?.output.successed(tokenForResend: token)
                                    }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failed(with: errorResponse.description)
                }
        })
    }
    
    func verifyOffer(_ offer: PackageModelResponse, token: String, otp: String) {
        offersService.verifyOffer(otp: otp, referenceToken: token,
                                  success: { [weak self] response in
                                    /// delay stay for server perform request (android logic)
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
