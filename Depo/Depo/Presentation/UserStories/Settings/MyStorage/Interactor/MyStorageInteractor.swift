//
//  MyStorageInteractor.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import WidgetKit

final class MyStorageInteractor {
    weak var output: MyStorageInteractorOutput!
    
    private let iapManager = IAPManager.shared
    var affiliate: String?
    var refererToken: String?
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    private let subscriptionsService: SubscriptionsService = SubscriptionsServiceIml()
    private let accountService: AccountServicePrl = AccountService()
    private let offersService: OffersService = OffersServiceIml()
    private let packageService = PackageService()
    private lazy var storageVars: StorageVars = factory.resolve()
    
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
                    self?.output.failed(with: error.description)
                }
            }
        }
    }
    
    
    func refreshActivePurchasesState(_ isActivePurchases: Bool) {
        iapManager.setActivePurchasesState(isActivePurchases)
    }
    
    func activate(offer: PackageModelResponse, planIndex: Int) {
        guard let product = iapManager.productForPurchase(for: offer.inAppPurchaseId ?? "") else {
            let error = CustomErrors.serverError("An error occured while getting product with id - \(offer.inAppPurchaseId ?? "") from App Store")
            self.output.failed(with: error.localizedDescription)
            return
        }

        iapManager.purchase(product: product) { result in
            switch result {
            case .success(let identifier):
                self.analyticsService.trackPurchase(offer: product)
                self.analyticsService.trackProductInAppPurchaseGA(product: product, packageIndex: planIndex)
                self.analyticsService.trackDimentionsEveryClickGA(screen: .packages, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: true)
                self.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .success)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackagePurchase(status: .success, channelType: .appStore, packageName: offer.displayName ?? ""))
                self.validatePurchase(productId: identifier)
            case .canceled:
                self.output.stopPurchase()
                self.analyticsService.trackCustomGAEvent(eventCategory: .errors, eventActions: .paymentErrors, eventLabel: .paymentError("transaction canceled"))
                self.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .failure)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackagePurchase(status: .failure, channelType: .appStore, packageName: offer.displayName ?? ""))
                DispatchQueue.main.async {
                    self.output?.purchaseCancelled()
                }
            case .error(let error):
                self.output.stopPurchase()
                self.analyticsService.trackCustomGAEvent(eventCategory: .errors, eventActions: .paymentErrors, eventLabel: .paymentError("\(error.description)"))
                self.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .failure)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackagePurchase(status: .failure, channelType: .appStore, packageName: offer.displayName ?? ""))
                DispatchQueue.main.async {
                    self.output?.failedUsage(with: ErrorResponse.error(error))
                }
            case .inProgress:
                DispatchQueue.main.async {
                    self.output?.failedUsage(with: ErrorResponse.string(TextConstants.inProgressPurchase))
                }
            }
        }
    }
    
    private func validatePurchase(productId: String) {
        guard let receipt = iapManager.receipt else {
            output?.refreshPackages()
            return
        }
        
        offersService.validateApplePurchase(with: receipt, productId: productId, referer: refererToken, success: { [weak self] response in
            guard
                let response = response as? ValidateApplePurchaseResponse,
                let status = response.status
            else {
                self?.output.refreshPackages()
                return
            }
            
            if status == .success {
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                DispatchQueue.toMain {
                    let drawCampaignPackage = self?.storageVars.drawCampaignPackage
                    if drawCampaignPackage ?? false {
                        self?.output.navigationToController()
                    } else {
                        self?.getAccountInfo()
                        self?.output.refreshPackages()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if status == .alreadySubscribed {
                        self?.output.failAlreadySubscribed(with: response.alreadySubscriedValue)
                    } else {
                        self?.output.failedUsage(with: ErrorResponse.string(status.description))
                    }
                }
            }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.failedUsage(with: errorResponse)
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
    
    func getAvailableOffers(with accountType: AccountType) {
        accountService.availableOffers(affiliate: self.affiliate) { [weak self] (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.getInfoForAppleProducts(offers: response)
                }
            case .failed(let error):
                DispatchQueue.main.async {
                    self?.output.failed(with: error.description)
                }
            }
        }
    }
    
    func convertToSubscriptionPlan(offers: [PackageModelResponse], accountType: AccountType) -> [SubscriptionPlan]  {
        return packageService.convertToSubscriptionPlan(offers: offers, accountType: accountType)
    }
    
    private func getInfoForAppleProducts(offers: [PackageModelResponse]) {
        packageService.getInfoForAppleProducts(offers: offers, success: { [weak self] in
            DispatchQueue.main.async {
                if self?.affiliate == "highlighted" {
                    self?.output.successedPackagesForHighlighted(allOffers: offers.filter({ $0.highlighted == true }))
                } else {
                    self?.output.successedPackages(allOffers: offers)
                }
            }
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.failed(with: error.description)
            }
        })
    }
    
    func getAccountTypePackages() {
        SingletonStorage.shared.getAccountInfoForUser(
            success: { [weak self] response in
                guard let accountType = response.accountType else {
                    return
                }
                DispatchQueue.main.async {
                    self?.output.successedPackages(accountTypeString: accountType)
                }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    self?.output.failed(with: error.localizedDescription)
                }
        })
    }
    
    func getAccountTypePackages(with accountType: String, offers: [Any]) -> AccountType? {
        return packageService.getAccountType(for: accountType, offers: offers)
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
                    self?.analyticsService.trackPurchase(offer: offer)
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    self?.analyticsService.trackProductPurchasedInnerGA(offer: offer, packageIndex: planIndex)
                    self?.analyticsService.trackDimentionsEveryClickGA(screen: .packages, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: false)
                    self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .success)
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackagePurchase(status: .success, channelType: .slcm, packageName: offer.displayName ?? ""))
                }

                /// delay stay for server perform request (android logic)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.output.successedVerifyOffer()
                }
            }, fail: { [weak self] errorResponse in
                self?.analyticsService.trackCustomGAEvent(eventCategory: .enhancedEcommerce, eventActions: .purchase, eventLabel: .failure)
                if let offer = offer {
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackagePurchase(status: .failure, channelType: .slcm, packageName: offer.displayName ?? ""))
                }
                DispatchQueue.main.async {
                    self?.output.failedVerifyOffer()
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
                
                //self?.output.successed(allOffers: offersList)
                self?.getInfoForAppleProducts(offers: offersList)
            }, fail: { [weak self] errorResponse in
                DispatchQueue.toMain {
                    self?.output.failed(with: errorResponse)
                }
            }, isLogin: false)
    }
    
    func getActiveSubscriptionForBanner() {
        if affiliate == "highlighted" {
            return
        }
        subscriptionsService.activeSubscriptions(
            success: { [weak self] response in
                guard let subscriptionsResponse = response as? ActiveSubscriptionResponse else {
                    return
                }
                let offersList = subscriptionsResponse.list
                DispatchQueue.main.async {
                    self?.output.getActiveSubscriptionForBanner(offers: offersList)
                }
            }, fail: { value in }, isLogin: false)
    }
    
    func getAvailableOffersForBanner() {
        if affiliate == "highlighted" {
            return
        }
        accountService.availableOffersWithLanguage(affiliate: self.affiliate) { [weak self] (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    let convertedResponse = self?.convertToSubscriptionPlan(offers: response, accountType: .turkcell)
                    self?.output.getAvailableOffersForBanner(offers: convertedResponse ?? [])
                }
            case .failed(_):
                break
            }
        }
    }
        
    
    func restorePurchases() {
        guard !sendReciept() else {
            output.stopActivity()
            return
        }
        
        iapManager.restorePurchases { [weak self] result in
            switch result {
            case .success:
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
        
        offersService.validateApplePurchase(with: receipt, productId: nil, referer: nil, success: { [weak self] response in
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                return
            }
            
            if status == .restored || status == .success {
                DispatchQueue.toMain {
                    self?.output.refreshPackages()
                }
            } else {
                DispatchQueue.main.async {
                    if status == .alreadySubscribed {
                        self?.output.failAlreadySubscribed(with: response.alreadySubscriedValue)
                    } else {
                        self?.output.failed(with: ErrorResponse.string(status.description))
                    }
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
            output.stopActivity()
            return
        }
        
        //just sending reciept
        offersService.validateApplePurchase(with: receipt, productId: nil, referer: nil, success: { [weak self] response in
            guard let response = response as? ValidateApplePurchaseResponse, let status = response.status else {
                return
            }
            if !(status == .restored || status == .success) {
                debugLog("validateRestorePurchaseFailed: \(status.description)")
                
                DispatchQueue.main.async {
                    if status == .alreadySubscribed {
                        self?.output.failAlreadySubscribed(with: response.alreadySubscriedValue)
                    } else {
                        self?.output.failed(with: ErrorResponse.string(status.description))

                    }
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
    
    func trackNetmeraPackageCancelClick(type: String, packageName: String) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PackageCancelClick(type: type, packageName: packageName))
    }
    
    //MARK: Converter
    func convertToASubscriptionList(activeSubscriptionList: [SubscriptionPlanBaseResponse], accountType: AccountType) -> [SubscriptionPlan] {
        return packageService.convertToSubscriptionPlan(
            offers: activeSubscriptionList,
            accountType: accountType,
            isPurchasedOffers: true
        )
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
    
    private func getAccountInfo() {
        accountService.info(success: { [weak self] response in
            guard let response = response as? AccountInfoResponse else {
                assertionFailure()
                return
            }
            DispatchQueue.toMain {
                SingletonStorage.shared.accountInfo = response
            }
        }) { error in }
    }
}
