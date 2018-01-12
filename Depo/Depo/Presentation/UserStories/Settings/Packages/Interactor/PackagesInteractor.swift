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
    
    init(offersService: OffersService = OffersServiceIml(),
         subscriptionsService: SubscriptionsService = SubscriptionsServiceIml(),
         accountService: AccountServicePrl = AccountService()
    ) {
        self.offersService = offersService
        self.subscriptionsService = subscriptionsService
        self.accountService = accountService
    }
    
    private func subscriptionPlanWith(name: String, priceString: String, type: SubscriptionPlanType, model: Any) -> SubscriptionPlan {
        if name.contains("50") {
            return SubscriptionPlan(name: name,
                                    photosCount: 50_000,
                                    videosCount: 5_000,
                                    songsCount: 25_000,
                                    docsCount: 500_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if name.contains("500") {
            return SubscriptionPlan(name: name,
                                    photosCount: 500_000,
                                    videosCount: 50_000,
                                    songsCount: 250_000,
                                    docsCount: 5_000_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if name.contains("2.5") {
            return SubscriptionPlan(name: name,
                                    photosCount: 2_560_000,
                                    videosCount: 256_000,
                                    songsCount: 1_280_000,
                                    docsCount: 25_600_000,
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
    
    func verifyOffer(token: String, otp: String) {
        offersService.verifyOffer(otp: otp, referenceToken: token,
            success: { [weak self] response in
                /// maybe will be need
                //guard let offerResponse = response as? VerifyOfferResponse else { return }
                DispatchQueue.main.async {
                    self?.output.successedVerifyOffer()
                }
            }, fail: { [weak self] errorResponse in
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
    
    func activate(offerApple: OfferApple) {
        iapManager.purchase(offerApple: offerApple) { [weak self] result in
            switch result {
            case .success:
                if let receipt = self?.iapManager.receipt, let productId = offerApple.storeProductIdentifier {
                    self?.offersService.validateApplePurchase(with: receipt, productId: productId, success: nil) { _ in }
                }
                DispatchQueue.main.async {
                    self?.output.successed(offerApple: offerApple)
                }
            case .canceled: break
            case .error(let error):
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: ErrorResponse.error(error))
                }
            }
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
                        self?.output.failedPromocode(with: errorResponse.localizedDescription)
                    }
                }
        })
    }
    
    func getOfferApples() {
        offersService.offersAllApple(
            success: { [weak self] response in
                guard let offerResponse = response as? OfferAllAppleServiceResponse else { return }
                self?.iapManager.loadProducts(productIds: offerResponse.list) { [weak self] offerAppleArray in
                    DispatchQueue.main.async {
                        self?.output.successed(offerApples: offerAppleArray)
                    }
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
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
            
            let currency = getCurrency(for: accountType)
            let priceString = String(format: TextConstants.offersPrice, price, currency)
            
            if price == 0 {
                return SubscriptionPlan(name: name,
                                        photosCount: 5_000,
                                        videosCount: 500,
                                        songsCount: 2_500,
                                        docsCount: 50_000,
                                        priceString: priceString,
                                        type: .free,
                                        model: subscription)
            }
            return subscriptionPlanWith(name: name, priceString: priceString, type: .current, model: subscription)
        }
    }
    
    func convertToSubscriptionPlans(offerApples: [OfferApple]) -> [SubscriptionPlan] {
        return offerApples.flatMap { offer in
            guard let name = offer.name else {
                return nil
            }
            
            let currency = getCurrency(for: AccountType.all)
            let priceString = String(format: TextConstants.offersPrice, currency, offer.rawPrice)
            
            return subscriptionPlanWith(name: name, priceString: priceString, type: .default, model: offer)
        }
    }
    
    func sendReciept() {
        guard let receipt = iapManager.receipt else { return }
        offersService.validateApplePurchase(with: receipt, productId: nil, success: nil) { _ in }
    }
    
    private func getCurrency(for accountType: AccountType) -> String {
        switch accountType {
        case .turkcell:
            return "TL"
        case .ukranian:
            return "UAH"
        case .cyprus:
            return "CYP"
        case .moldovian:
            return "MDL"
        case .all:
            return "$" /// temp
        }
    }
}
