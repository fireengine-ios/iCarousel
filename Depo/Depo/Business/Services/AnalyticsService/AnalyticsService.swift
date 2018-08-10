//
//  AnalyticsService.swift
//  Depo
//
//  Created by Andrei Novikau on 28.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Adjust
import FBSDKCoreKit
import StoreKit
import Firebase

final class AnalyticsService {
    
    private var innerTimer: Timer?
    
    func start() {
        setupAdjust()
        configureFireBase()
    }
    
    // MARK: - Setup
    
    private func setupAdjust() {
        #if DEBUG
        let environment = ADJEnvironmentSandbox
        #else
        let environment = ADJEnvironmentProduction
        #endif
        
        let adjustConfig = ADJConfig(appToken: "hlqdgtbmrdb9", environment: environment)
        Adjust.appDidLaunch(adjustConfig)
    }
    
    private func configureFireBase() {
        var filePath: String?
        
        #if ENTERPRISE
            filePath = Bundle.main.path(forResource: "GoogleService-Info-ent", ofType: "plist")
        #elseif APPSTORE
            filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        #elseif DEBUG
            filePath = Bundle.main.path(forResource: "GoogleService-Info-debug", ofType: "plist")
        #endif
        
        guard let filePathUnwraped = filePath,
            let options = FirebaseOptions(contentsOfFile: filePathUnwraped) else {
                FirebaseApp.configure()
                return
        }
        FirebaseApp.configure(options: options)
    }
    
    // MARK: - Events
    
    func track(event: AnalyticsEvent) {
        logAdjustEvent(name: event.token)
        logFacebookEvent(name: FBSDKAppEventNameViewedContent, parameters: [FBSDKAppEventParameterNameContent: event.facebookEventName])
    }
    
    func trackInAppPurchase(product: SKProduct) {
        let name = product.localizedTitle
        let price = product.localizedPrice
        let currency = product.priceLocale.currencyCode ?? "USD"
        
        if name.contains("500") {
            logPurchase(event: .purchaseNonTurkcell500, price: price, currency: currency)
        } else if name.contains("50") {
            logPurchase(event: .purchaseNonTurkcell50, price: price, currency: currency)
        } else if name.contains("2.5") || name.contains("2,5") {
            logPurchase(event: .purchaseNonTurkcell2500, price: price, currency: currency)
        }
    }
    
    func trackInnerPurchase(_ offer: OfferServiceResponse) {
        guard let name = offer.name, let price = offer.price else {
            return
        }
        
        if name.contains("500") {
            logPurchase(event: .purchaseTurkcell500, price: String(price))
        } else if name.contains("50") {
            logPurchase(event: .purchaseTurkcell50, price: String(price))
        } else if name.contains("2.5") || name.contains("2,5") {
            logPurchase(event: .purchaseTurkcell2500, price: String(price))
        }
    }

    private func logPurchase(event: AnalyticsEvent, price: String, currency: String = "TL") {
        logAdjustEvent(name: event.token, price: Double(price), currency: currency)
        //Facebook has automatic tracking in-app purchases. If this function is enabled in the web settings, then there will be duplicates
        if let price = Double(price) {
            FBSDKAppEvents.logPurchase(price, currency: currency, parameters: [FBSDKAppEventParameterNameContent: event.facebookEventName])
        }
    }
    
    private func logAdjustEvent(name: String, price: Double? = nil, currency: String? = nil) {
        let event = ADJEvent(eventToken: name)
        if let price = price, let currency = currency
        {
            event?.setRevenue(price, currency: currency)
        }
        Adjust.trackEvent(event)
    }
    
    private func logFacebookEvent(name: String, parameters: [AnyHashable: Any]? = nil) {
        if let parameters = parameters {
            FBSDKAppEvents.logEvent(name, parameters: parameters)
        }
    }    
}

protocol AnalyticsGA {///GA = GoogleAnalytics
    func logScreen(screen: AnalyticsAppScreens)
    func trackProductPurchasedInnerGA(offer: OfferServiceResponse, packageIndex: Int)
    func trackProductInAppPurchaseGA(product: SKProduct, packageIndex: Int)
    func trackCustomGAEvent(eventCategory: GAEventCantegory, eventActions: GAEventAction, eventLabel: GAEventLabel, eventValue: String?)
    func trackPackageClick(package: SubscriptionPlan, packageIndex: Int)
    func trackEventTimely(eventCategory: GAEventCantegory, eventActions: GAEventAction, eventLabel: GAEventLabel, timeInterval: Float)
    func stopTimelyTracking()
    func trackDimentionsEveryClickGA(screen: AnalyticsAppScreens, downloadsMetrics: Int?,
    uploadsMetrics: Int?, isPaymentMethodNative: Bool?)
    func trackDimentionsPaymentGA(screen: AnalyticsAppScreens, isPaymentMethodNative: Bool)//native = inApp apple
}

extension AnalyticsService: AnalyticsGA {
    
    
    func logScreen(screen: AnalyticsAppScreens) {
        Analytics.logEvent("screenView", parameters: [
            "screenName": screen.name,
            "userId": SingletonStorage.shared.accountInfo?.gapId ?? NSNull()
            ])
    }
    
    func trackDimentionsEveryClickGA(screen: AnalyticsAppScreens, downloadsMetrics: Int? = nil,
                                     uploadsMetrics: Int? = nil, isPaymentMethodNative: Bool? = nil) {
        let loginStatus = SingletonStorage.shared.referenceToken != nil
        let version =  (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        var payment: String?
        
        if let unwrapedisNativePayment = isPaymentMethodNative {
            payment = "\(unwrapedisNativePayment)"
        }
        
        let activeSubscriptionNames = SingletonStorage.shared.activeUserSubscriptionList.map {
            return ($0.subscriptionPlanName ?? "") + "|"
        }
        let parametrs = AnalyticsDementsonObject(screenName: screen.name, pageType: screen, sourceType: screen.name, loginStatus: "\(loginStatus)",
            platform: "iOS", isWifi: ReachabilityService().isReachableViaWiFi,
            service: "lifebox", developmentVersion: version,
            paymentMethod: payment, userId: SingletonStorage.shared.accountInfo?.gapId ?? NSNull(),
            operatorSystem: Device.deviceType, facialRecognition: SingletonStorage.shared.isFaceImageRecognitionON,
            userPackagesNames: activeSubscriptionNames, countOfUploadMetric: uploadsMetrics,
            countOfDownloadMetric: downloadsMetrics).productParametrs
        
        Analytics.logEvent("screenView", parameters: parametrs)
    }
    
    func trackDimentionsPaymentGA(screen: AnalyticsAppScreens, isPaymentMethodNative: Bool) {
        
    }
    
    func trackProductPurchasedInnerGA(offer: OfferServiceResponse, packageIndex: Int) {
        let analyticasItemList = "Turkcell Package"
        var itemID = ""
        var price = ""
        if let offerIDUnwraped = offer.offerId, let unwrapedPrice = offer.price {
            itemID = "\(offerIDUnwraped)"
            price = "\(unwrapedPrice)"
        }
        
        let product =  AnalyticsPackageProductObject(itemName: offer.name ?? "", itemID: itemID, price: price, itemBrand: "Lifebox", itemCategory: "Storage", itemVariant: "", index: "\(packageIndex)", quantity: "1")
        let ecommerce = AnalyticsEcommerce(items: [product], itemList: analyticasItemList,
                                           transactionID: "", tax: "0",
                                           priceValue: price, shipping: "0")
        Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: ecommerce.ecommerceParametrs)
    }
    
    func trackProductInAppPurchaseGA(product: SKProduct, packageIndex: Int) {
        let analyticasItemList = "In App Package"
        let itemID = product.productIdentifier
        let price = product.localizedPrice
        let product =  AnalyticsPackageProductObject(itemName: product.localizedTitle, itemID: itemID, price: price, itemBrand: "Lifebox", itemCategory: "Storage", itemVariant: "", index: "\(packageIndex)", quantity: "1")
        let ecommerce = AnalyticsEcommerce(items: [product], itemList: analyticasItemList,
                                           transactionID: "", tax: "0",
                                           priceValue: price, shipping: "0")
        Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: ecommerce.ecommerceParametrs)
    }
    
    func trackCustomGAEvent(eventCategory: GAEventCantegory, eventActions: GAEventAction, eventLabel: GAEventLabel = .empty, eventValue: String? = nil ) {
        let eventTempoValue = eventValue ?? ""
        ///migt be needed in the future
//        if let unwrapedEventValue = eventValue {
//            eventTempoValue = "\(unwrapedEventValue)"
//        }
        Analytics.logEvent("GAEvent", parameters: [
            "eventCategory" : eventCategory.text,
            "eventAction" : eventActions.text,
            "eventLabel" : eventLabel.text,
            "eventValue" : eventTempoValue
            ])
    }
    
    func trackPackageClick(package: SubscriptionPlan, packageIndex: Int) {
        
        var analyticasItemList = "İndirimdeki Paketler"
        var itemID = ""
        if let offer = package.model as? OfferServiceResponse, let offerID = offer.offerId {
            itemID = "\(offerID)"
            analyticasItemList = "Turkcell Package"
        } else if let offer = package.model as? OfferApple, let offerID = offer.storeProductIdentifier {
            itemID = offerID
            analyticasItemList = "In App Package"
        }
        let product =  AnalyticsPackageProductObject(itemName: package.name, itemID: itemID, price: package.priceString, itemBrand: "Lifebox", itemCategory: "Storage", itemVariant: "", index: "\(packageIndex)", quantity: "1")
        let ecommerce: [String : Any] = ["items" : [product.productParametrs],
                                         AnalyticsParameterItemList : analyticasItemList]
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: ecommerce)
    }
    
    func trackEventTimely(eventCategory: GAEventCantegory, eventActions: GAEventAction, eventLabel: GAEventLabel = .empty, timeInterval: Float = 1.0) {
        if innerTimer != nil {
            stopTimelyTracking()
        }
        innerTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(timerStep(sender:)), userInfo:
            [
                GACustomEventKeys.category.key: eventCategory,
             GACustomEventKeys.action.key: eventActions,
             GACustomEventKeys.label.key: eventLabel
            ],
                                          repeats: true)
    }
    
    @objc func timerStep(sender: Timer) {
        guard let unwrapedUserInfo = sender.userInfo as? [String: Any],
            let eventCategory = unwrapedUserInfo[GACustomEventKeys.category.key] as? GAEventCantegory,
        let eventActions = unwrapedUserInfo[GACustomEventKeys.action.key] as? GAEventAction,
            let eventLabel = unwrapedUserInfo[GACustomEventKeys.label.key] as? GAEventLabel else {
            return
        }
        trackCustomGAEvent(eventCategory: eventCategory, eventActions: eventActions, eventLabel: eventLabel)
    }
    
    func stopTimelyTracking() {
        guard let curTimer = innerTimer else {
            return
        }
        if curTimer.isValid {
            curTimer.invalidate()
            innerTimer = nil
        }
    }
//in future we migt need more then 1 timer, in case this calss become songleton
//    func stopAllTimelyTracking() {
//
//    }
}
