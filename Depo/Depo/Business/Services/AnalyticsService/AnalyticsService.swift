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

protocol AnalyticsGA {
    func logScreen(screen: AnalyticsAppScreens)
    func trackProductPurchasedInnerGA(offer: OfferServiceResponse, packageIndex: Int)
    func trackProductInAppPurchaseGA(product: SKProduct, packageIndex: Int)
    func trackCustomGAEvent()
    func trackPackageClick(package: SubscriptionPlan, packageIndex: Int)
}

extension AnalyticsService: AnalyticsGA {
    
    func logScreen(screen: AnalyticsAppScreens) {
        Analytics.logEvent("screenView", parameters: [
            "screenName": screen.name,
            "userId": SingletonStorage.shared.accountInfo?.gapId ?? NSNull()
            ])
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
    
    func trackCustomGAEvent() {
        //        Analytics.logEvent("GAEvent", parameters: [
        //            "eventCategory": User Actions,
        //            "eventAction": Register,
        //            "eventLabel": ,
        //            "eventValue": ,
        //            ])
        //        Sample Code Block - iOS:
        //        Analytics.logEvent("GAEvent", parameters: [
        //        "eventCategory": Functions,
        //        "eventAction": Login,
        //        "eventLabel": True,
        //        "eventValue": ,
        //        ])
        ///DIMENTION
        //        Analytics.logEvent("screenView", parameters: [
        //            "screenName": “Name of the Screen is put here”
        //            "pageType": “HomePage”
        //            "sourceType": “Music”
        //            ])
        
        
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
}
