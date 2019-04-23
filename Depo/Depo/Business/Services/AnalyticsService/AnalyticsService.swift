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

protocol AnalyticsScreen {
    var analyticsScreen: AnalyticsAppScreens { get }
}

final class AnalyticsService {
    
    private var innerTimer: Timer?
    
    private let privateQueue = DispatchQueue(label: DispatchQueueLabels.analyticsPrivateQueue)
    
    func start() {
        setupAdjust()
        configureFireBase()
    }
    
    func trackScreen(_ screen: AnalyticsScreen) {
        logScreen(screen: screen.analyticsScreen)
        trackDimentionsEveryClickGA(screen: screen.analyticsScreen)
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
    
    func trackInnerPurchase(_ offer: PackageModelResponse) {
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
    func trackProductInAppPurchaseGA(product: SKProduct, packageIndex: Int)
    func trackProductPurchasedInnerGA(offer: PackageModelResponse, packageIndex: Int)
    func trackCustomGAEvent(eventCategory: GAEventCantegory, eventActions: GAEventAction, eventLabel: GAEventLabel, eventValue: String?)
    func trackPackageClick(package: SubscriptionPlan, packageIndex: Int)
    func trackEventTimely(eventCategory: GAEventCantegory, eventActions: GAEventAction, eventLabel: GAEventLabel, timeInterval: Double)
    func stopTimelyTracking()
    func trackDimentionsEveryClickGA(screen: AnalyticsAppScreens, downloadsMetrics: Int?,
    uploadsMetrics: Int?, isPaymentMethodNative: Bool?)
    func trackLoginEvent(loginType: GADementionValues.login?, error: LoginResponseError?)
    func trackSignupEvent(error: SignupResponseError?)
//    func trackDimentionsPaymentGA(screen: AnalyticsAppScreens, isPaymentMethodNative: Bool)//native = inApp apple
}

extension AnalyticsService: AnalyticsGA {
    
    func logScreen(screen: AnalyticsAppScreens) {
        prepareDimentionsParametrs(screen: screen, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: nil) { dimentionParametrs in
            Analytics.logEvent("screenView", parameters: dimentionParametrs)
        }
    }
    
    func trackDimentionsEveryClickGA(screen: AnalyticsAppScreens, downloadsMetrics: Int? = nil,
                                     uploadsMetrics: Int? = nil, isPaymentMethodNative: Bool? = nil) {
        prepareDimentionsParametrs(screen: screen, downloadsMetrics: downloadsMetrics, uploadsMetrics: uploadsMetrics, isPaymentMethodNative: isPaymentMethodNative) { parametrs in
            Analytics.logEvent("screenView", parameters: parametrs)
        }
    }
    
    private func prepareDimentionsParametrs(screen: AnalyticsAppScreens?,
                                            downloadsMetrics: Int? = nil,
                                            uploadsMetrics: Int? = nil,
                                            isPaymentMethodNative: Bool? = nil,
                                            loginType: GADementionValues.login? = nil,
                                            errorType: String? = nil,
                                            parametrsCallback: @escaping (_ parametrs: [String: Any])->Void) {
        
        let tokenStorage: TokenStorage = factory.resolve()
        let loginStatus = tokenStorage.accessToken != nil
        let version =  (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        var payment: String?
        if let unwrapedisNativePayment = isPaymentMethodNative {
            payment = unwrapedisNativePayment ? "inApp" : "Turkcell"
        }

        let group = DispatchGroup()

        group.enter()
        var facialRecognitionStatus: Any = NSNull()
        SingletonStorage.shared.getFaceImageSettingsStatus(success: { isFIROn in
            facialRecognitionStatus = isFIROn
            group.leave()
        }, fail: { error in
            group.leave()
        })
        
        group.enter()
        var activeSubscriptionNames = [String]()
        SingletonStorage.shared.getActiveSubscriptionsList(success: { response in
            activeSubscriptionNames = SingletonStorage.shared.activeUserSubscriptionList.map {
                return ($0.subscriptionPlanName ?? "") + "|"
            }
            group.leave()
        }, fail: { errorResponse in
            group.leave()
        })
        
///        For all of the events (not only newly added autosync events but also all GA events that we send in current client), we will also send below dimensions each time. For the events that we send before login, there is no need to send.
///        AutoSync --> True/False
///        SyncStatus --> Photos - Never / Photos - Wifi / Photos - Wifi&LTE / Videos - Never / Videos - Wifi / Videos - Wifi&LTE
        var autoSyncState: String?
        var autoSyncStatus: String?
    
        if loginStatus {
            let autoSyncStorageSettings = AutoSyncDataStorage().settings
            
            let confirmedAutoSyncSettingsState = autoSyncStorageSettings.isAutoSyncEnabled && autoSyncStorageSettings.isAutosyncSettingsApplied
            
            autoSyncState = confirmedAutoSyncSettingsState ? "True" : "False"
            debugPrint("!!!! autosync \(autoSyncStorageSettings.isAutoSyncEnabled) also a is firstAutosync set \(autoSyncStorageSettings.isAutosyncSettingsApplied)")
            
            let photoSetting = confirmedAutoSyncSettingsState ?
                GAEventLabel.getAutoSyncSettingEvent(autoSyncSettings: autoSyncStorageSettings.photoSetting).text : GAEventLabel.photosNever.text
            let videoSetting = confirmedAutoSyncSettingsState ?
                GAEventLabel.getAutoSyncSettingEvent(autoSyncSettings: autoSyncStorageSettings.videoSetting).text : GAEventLabel.videosNever.text
            autoSyncStatus = "\(photoSetting) | \(videoSetting)"
            debugPrint("!!!! autoSyncStatus is \(autoSyncStatus)")

        }
        
        
        let screenName: Any = screen?.name ?? NSNull()
        
        group.notify(queue: privateQueue) { 
            parametrsCallback(AnalyticsDimension(screenName: screenName, pageType: screenName, sourceType: screenName, loginStatus: "\(loginStatus)",
                platform: "iOS", isWifi: ReachabilityService().isReachableViaWiFi,
                service: "Lifebox", developmentVersion: version,
                paymentMethod: payment, userId: SingletonStorage.shared.accountInfo?.gapId ?? NSNull(),
                operatorSystem: CoreTelephonyService().carrierName ?? NSNull(),
                facialRecognition: facialRecognitionStatus,
                userPackagesNames: activeSubscriptionNames,
                countOfUploadMetric: uploadsMetrics,
                countOfDownloadMetric: downloadsMetrics,
                gsmOperatorType: SingletonStorage.shared.accountInfo?.accountType ?? "",
                loginType: loginType,
                errorType: errorType,
                autoSyncState: autoSyncState,
                autoSyncStatus: autoSyncStatus).productParametrs)
        }
    }
    
    func trackProductPurchasedInnerGA(offer: PackageModelResponse, packageIndex: Int) {
        let analyticasItemList = "Turkcell Package"
        var itemID = ""
        var price = ""
        if let offerIDUnwraped = offer.slcmOfferId, let unwrapedPrice = offer.price {
            itemID = "\(offerIDUnwraped)"
            price = "\(unwrapedPrice)"
        }
        
        let product =  AnalyticsPackageProductObject(itemName: offer.name ?? "", itemID: itemID, price: price, itemBrand: "Lifebox", itemCategory: "Storage", itemVariant: "", index: "\(packageIndex)", quantity: "1")
        let ecommerce = AnalyticsEcommerce(items: [product], itemList: analyticasItemList,
                                           transactionID: "", tax: "0",
                                           priceValue: price, shipping: "0")
        
        prepareDimentionsParametrs(screen: nil, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: false) { dimentionParametrs in
            Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: ecommerce.ecommerceParametrs + dimentionParametrs)
        }
    }
    
    func trackProductInAppPurchaseGA(product: SKProduct, packageIndex: Int) {
        let analyticasItemList = "In App Package"
        let itemID = product.productIdentifier
        let price = product.localizedPrice
        let product =  AnalyticsPackageProductObject(itemName: product.localizedTitle, itemID: itemID, price: price, itemBrand: "Lifebox", itemCategory: "Storage", itemVariant: "", index: "\(packageIndex)", quantity: "1")
        let ecommerce = AnalyticsEcommerce(items: [product], itemList: analyticasItemList,
                                           transactionID: "", tax: "0",
                                           priceValue: price, shipping: "0")
        
        prepareDimentionsParametrs(screen: nil, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: true) { dimentionParametrs in
            Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: ecommerce.ecommerceParametrs + dimentionParametrs)
        }
    }
    
    func trackCustomGAEvent(eventCategory: GAEventCantegory, eventActions: GAEventAction, eventLabel: GAEventLabel = .empty, eventValue: String? = nil ) {
        let eventTempoValue = eventValue ?? ""
///       might be needed in the future
//        if let unwrapedEventValue = eventValue {
//            eventTempoValue = "\(unwrapedEventValue)"
//        }
        prepareDimentionsParametrs(screen: nil, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: nil) { dimentionParametrs in
            let parametrs: [String: Any] = [
                "eventCategory" : eventCategory.text,
                "eventAction" : eventActions.text,
                "eventLabel" : eventLabel.text,
                "eventValue" : eventTempoValue
            ]
            Analytics.logEvent("GAEvent", parameters: parametrs + dimentionParametrs)
        }
    }
    
    func trackLoginEvent(loginType: GADementionValues.login? = nil, error: LoginResponseError? = nil) {
        prepareDimentionsParametrs(screen: nil, loginType: loginType, errorType: error?.dimensionValue) { dimentionParametrs in
            let parametrs: [String: Any] = [
                "eventCategory" : GAEventCantegory.functions.text,
                "eventAction" : GAEventAction.login.text,
                "eventLabel" : loginType != nil ? GAEventLabel.success.text : GAEventLabel.failure.text
            ]
            Analytics.logEvent("GAEvent", parameters: parametrs + dimentionParametrs)
        }
    }
    
    func trackSignupEvent(error: SignupResponseError? = nil) {
        prepareDimentionsParametrs(screen: nil, errorType: error?.dimensionValue) { dimentionParametrs in
            let parametrs: [String: Any] = [
                "eventCategory" : GAEventCantegory.functions.text,
                "eventAction" : GAEventAction.register.text,
                "eventLabel" : error == nil ? GAEventLabel.success.text : GAEventLabel.failure.text
            ]
            Analytics.logEvent("GAEvent", parameters: parametrs + dimentionParametrs)
        }
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
        
        prepareDimentionsParametrs(screen: nil, downloadsMetrics: nil, uploadsMetrics: nil, isPaymentMethodNative: nil) { dimentionParametrs in
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: ecommerce + dimentionParametrs)
        } 
    }
    
    func trackEventTimely(eventCategory: GAEventCantegory, eventActions: GAEventAction, eventLabel: GAEventLabel = .empty, timeInterval: Double = 60.0) {
        ///every minute by default
        if innerTimer != nil {
            stopTimelyTracking()
        }
        
        let userInfo: [String: Any] = [GACustomEventKeys.category.key: eventCategory,
                                       GACustomEventKeys.action.key: eventActions,
                                       GACustomEventKeys.label.key: eventLabel]
        
        DispatchQueue.main.async {
            self.innerTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.timerStep), userInfo: userInfo, repeats: true)
            ///fire at least once
            self.innerTimer?.fire()
        }
    }
    
    @objc func timerStep(_ timer: Timer) {
        privateQueue.async { [weak self] in
            guard
                let `self` = self,
                timer.isValid,
                let unwrapedUserInfo = timer.userInfo as? [String: Any],
                let eventCategory = unwrapedUserInfo[GACustomEventKeys.category.key] as? GAEventCantegory,
                let eventActions = unwrapedUserInfo[GACustomEventKeys.action.key] as? GAEventAction,
                let eventLabel = unwrapedUserInfo[GACustomEventKeys.label.key] as? GAEventLabel
                else {
                    return
            }
            
            self.trackCustomGAEvent(eventCategory: eventCategory, eventActions: eventActions, eventLabel: eventLabel)
        }
    }
    
    func stopTimelyTracking() {
        DispatchQueue.toMain {
            guard let curTimer = self.innerTimer else {
                return
            }
            if curTimer.isValid {
                curTimer.invalidate()
                self.innerTimer = nil
            }
        }
    }
//in future we migt need more then 1 timer, in case this calss become songleton
//    func stopAllTimelyTracking() {
//
//    }
}
