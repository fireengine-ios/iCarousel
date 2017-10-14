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
    
    private let eps: Float = 0.00001
    
    private func subscriptionPlanWith(name: String, price: Float, type: SubscriptionPlanType, model: Any) -> SubscriptionPlan {
        let priceString = String(format: TextConstants.offersPrice, price)
        if abs(price - 4.99) < eps {
            return SubscriptionPlan(name: name,
                                    photosCount: 50_000,
                                    videosCount: 5_000,
                                    songsCount: 25_000,
                                    docsCount: 500_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if abs(price - 12.99) < eps {
            return SubscriptionPlan(name: name,
                                    photosCount: 500_000,
                                    videosCount: 50_000,
                                    songsCount: 250_000,
                                    docsCount: 5_000_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if abs(price - 29.99) < eps {
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

    /// MAYBE WILL BE NEED
//    func getCurrentSubscription() {
//        subscriptionsService.currentSubscription(
//            success: { response in
//                guard let subscriptionsResponce = response as? CurrentSubscriptionResponse,
//                    let subscription = subscriptionsResponce.subscription else { return }
//                print(subscription)
//            }, fail: { [weak self] errorResponse in
//                DispatchQueue.main.async {
//                    self?.output.failedUsage(with: errorResponse)
//                }
//        })
//    }
    
    func activate(offer: OfferServiceResponse) {
        offersService.activate(offer: offer,
            success: { [weak self] response in
                /// MAYBE WILL BE NEED
                //guard let offerResponse = response as? OfferActivateServiceResponse else { return }
                DispatchQueue.main.async {
                    self?.output.successed(activateOffer: offer)
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
    
    func convertToSubscriptionPlans(offers: [OfferServiceResponse]) -> [SubscriptionPlan] {
        return offers.flatMap { offer in
            guard let price = offer.price, let name = offer.name else {
                return nil
            }
            return subscriptionPlanWith(name: name, price: price, type: .default, model: offer)
        }
    }
    
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse]) -> [SubscriptionPlan] {
        return activeSubscriptionList.flatMap { subscription in
            guard let price = subscription.subscriptionPlanPrice, let name = subscription.subscriptionPlanDisplayName else {
                return nil
            }
            if price == 0 {
                return SubscriptionPlan(name: name,
                                        photosCount: 5_000,
                                        videosCount: 500,
                                        songsCount: 2_500,
                                        docsCount: 50_000,
                                        priceString: String(format: TextConstants.offersPrice, price),
                                        type: .free,
                                        model: subscription)
            }
            return subscriptionPlanWith(name: name, price: price, type: .current, model: subscription)
        }
    }
    
    func convertToSubscriptionPlans(offerApples: [OfferApple]) -> [SubscriptionPlan] {
        return offerApples.flatMap { offer in
            guard let name = offer.name else {
                return nil
            }
            return subscriptionPlanWith(name: name, price: offer.rawPrice, type: .default, model: offer)
        }
    }
    
    func sendReciept() {
        guard let receipt = iapManager.receipt else { return }
        offersService.validateApplePurchase(with: receipt, productId: nil, success: nil) { _ in }
    }
}
