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

final class AnalyticsService {
    
    func start() {
        //TODO: In production need ADJEnvironmentProduction
        let adjustConfig = ADJConfig(appToken: "", environment: ADJEnvironmentSandbox)
        Adjust.appDidLaunch(adjustConfig)
    }
    
    // MARK: - Events
    func track(event: AnalyticsEvent) {
        logAdjustEvent(name: event.token)
        logFacebookEvent(name: event.facebookEventName)
    }
    
    func trackPurchase(event: AnalyticsEvent, product: SKProduct) {
        logAdjustEvent(name: event.token, product: product)
        
        //Facebook has automatic tracking purchases. If this function is enabled in the web settings, then there will be duplicates
        logFacebookEvent(name: event.facebookEventName, parameters: ["price": product.price, "currency": product.localizedPrice])
    }
    
    private func logAdjustEvent(name: String, product: SKProduct? = nil) {
        let event = ADJEvent(eventToken: name)
        if let product = product {
            event?.setRevenue(product.price.doubleValue, currency: product.localizedPrice)
        }
        Adjust.trackEvent(event)
    }
    
    private func logFacebookEvent(name: String, parameters: [AnyHashable: Any]? = nil) {
        if let parameters = parameters {
            FBSDKAppEvents.logEvent(name, parameters: parameters)
        } else {
            FBSDKAppEvents.logEvent(name)
        }
    }    
}
