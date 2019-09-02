//
//  PackageService.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 12/6/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import StoreKit

final class PackageService {
    
    private let iapManager = IAPManager.shared
    
    //MARK: Utility Methods(private)
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
        } else if name.contains("10") {
            return SubscriptionPlan(name: name,
                                    photosCount: 10_000,
                                    videosCount: 1_000,
                                    songsCount: 5_000,
                                    docsCount: 100_000,
                                    priceString: priceString,
                                    type: type,
                                    model: model)
        } else if name.contains("20") {
            return SubscriptionPlan(name: name,
                                    photosCount: 20_000,
                                    videosCount: 2_000,
                                    songsCount: 10_000,
                                    docsCount: 200_000,
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
        case .albanian:
            return "ALL"
        case .FWI, .jamaica:
            return "JMD"
        case .all:
            return "$" /// temp
        }
    }
    
    private func getAppleIds(for offers: [Any]) -> [String] {
        return offers.flatMap {
            let id: String
            if let offer = $0 as? PackageModelResponse, let appleId = offer.inAppPurchaseId {
                id = appleId
            } else if let offer = $0 as? SubscriptionPlanBaseResponse, let appleId = offer.subscriptionPlanInAppPurchaseId {
                id = appleId
            } else {
                id = ""
            }
            return id
        }
    }
    
    private func getOfferPeriod(for offer: Any) -> String? {
        var period: String?
        if let offer = offer as? PackageModelResponse, let periodString = offer.period {
            period = localized(offerPeriod: periodString.lowercased())
        } else if let offer = offer as? SubscriptionPlanBaseResponse, let periodString = offer.subscriptionPlanPeriod {
            period = localized(offerPeriod: periodString.lowercased()) 
        }
        return period
    }
    
    private func localized(offerPeriod: String) -> String {
        if offerPeriod.contains("year") {
            return TextConstants.packagePeriodYear
        } else if offerPeriod.contains("month") {
            return TextConstants.packagePeriodMonth
        } else if offerPeriod.contains("week") {
            return TextConstants.packagePeriodWeek
        } else if offerPeriod.contains("day") {
            return TextConstants.packagePeriodDay
        }
        
        return offerPeriod
    }
    
    func getOfferPrice(for offer: Any) -> String? {
        var price: String?
        if let offer = offer as? PackageModelResponse, let priceFloat = offer.price, priceFloat > 0 {
            price = String(priceFloat)
        } else if let offer = offer as? SubscriptionPlanBaseResponse, let priceFloat = offer.subscriptionPlanPrice, priceFloat > 0 {
            price = String(priceFloat)
        } else if let offer = offer as? SKProduct {
            price = offer.localizedPrice
        }
        return price
    }
    
    func getOfferCurrency(for offer: Any) -> String? {
        var currency: String?
        if let offer = offer as? PackageModelResponse, let currencyString = offer.currency {
            currency = currencyString
        } else if let offer = offer as? SubscriptionPlanBaseResponse, let currencyString = offer.subscriptionPlanCurrency {
            currency = currencyString
        } else if let offer = offer as? SKProduct {
            currency = offer.priceLocale.currencyCode ?? "USD"
        }
        return currency
    }
    
    private func getOfferQuota(for offer: Any) -> Int64? {
        var quota: Int64?
        if let offer = offer as? PackageModelResponse, let quotaString = offer.quota {
            quota = quotaString
        } else if let offer = offer as? SubscriptionPlanBaseResponse, let quotaString = offer.subscriptionPlanQuota {
            quota = quotaString
        }
        return quota
    }
    
    private func getOfferDisplayName(for offer: Any) -> String? {
        var displayName: String?
        if let offer = offer as? PackageModelResponse, let displayNameString = offer.displayName {
            displayName = displayNameString
        } else if let offer = offer as? SubscriptionPlanBaseResponse, let displayNameString = offer.subscriptionPlanDisplayName {
            displayName = displayNameString
        }
        return displayName
    }
    
    private func getOfferType(for offer: Any) -> SubscriptionPlanType {
        var type: SubscriptionPlanType = .default
        if let offer = offer as? SubscriptionPlanBaseResponse {
            type = offer.subscriptionPlanPrice ?? 0 == 0 ? .free : .current
        }
        return type
    }
    
    private func getOfferRole(for offer: Any) -> String {
        let role: String
        if let offer = offer as? SubscriptionPlanBaseResponse, let offerRole = offer.subscriptionPlanRole {
            role = offerRole
        } else if let offer = offer as? PackageModelResponse, let offerRole = offer.role {
            role = offerRole
        } else {
            role = AccountType.all.rawValue
        }
        return role.uppercased()
    }
    
    //MARK: Utility Methods(public)
    func getAccountType(for accountType: String, offers: [Any] = []) -> AccountType {
        if AccountType(rawValue: accountType) == .turkcell {
            return .turkcell
        } else {
            let roles: [String] = offers.flatMap { return getOfferRole(for: $0) }
            for role in roles {
                if role.starts(with: "DIGICELL-") {
                    ///FeaturePackageType need for leave premium
                    if role.contains(AccountType.FWI.rawValue) || FeaturePackageType(rawValue: role) != nil {
                        return .FWI
                    } else if role.contains(AccountType.jamaica.rawValue) {
                        return .jamaica
                    }
                } else if let index = role.index(of: "-"), let accountType = AccountType(rawValue: String(role[..<index])) {
                    return accountType
                }
            }
            
            return .all
        }
    }
    
    func getInfoForAppleProducts(offers: [Any], success: @escaping () -> (), fail: @escaping (Error) -> ()) {
        let appleOffers = getAppleIds(for: offers)
        iapManager.loadProducts(productIds: appleOffers) { response in
            switch response {
            case .success(_):
                success()
            case .failed(let error):
                fail(error)
            }
        }
    }
    
    func getPriceInfo(for offer: Any, accountType: AccountType) -> String {
        
        let fullPrice: String
        if let iapProductId = getAppleIds(for: [offer]).first, let product = iapManager.product(for: iapProductId), !product.isFree {
            
            let price = product.localizedPrice
            if #available(iOS 11.2, *) {
                guard let subscriptionPeriod = product.subscriptionPeriod else {
                    fullPrice = String(format: TextConstants.packageApplePrice, price, TextConstants.packagePeriodMonth)
                    return fullPrice
                }
                let period: String
                switch subscriptionPeriod.unit {
                case .day:
                    period = TextConstants.packagePeriodDay
                case .week:
                    period = TextConstants.packagePeriodWeek
                case .month:
                    period = TextConstants.packagePeriodMonth
                case .year:
                    period = TextConstants.packagePeriodYear
                }
                fullPrice = String(format: TextConstants.packageApplePrice, price, period)
            } else {
                if let period = getOfferPeriod(for: offer) {
                    fullPrice = String(format: TextConstants.packageApplePrice, price, period)
                } else {
                    fullPrice = price
                }
            }
        } else {
            if let price = getOfferPrice(for: offer) {
                let currency = getOfferCurrency(for: offer) ?? getCurrency(for: accountType)
                let priceString = String(price) + " " + currency
                if let period = getOfferPeriod(for: offer) {
                    fullPrice = String(format: TextConstants.packageApplePrice, priceString, period)
                } else {
                    fullPrice = priceString
                }
            } else {
                fullPrice = TextConstants.free
            }
        }
        return fullPrice
    }
    
    func convertToSubscriptionPlan(offers: [Any], accountType: AccountType) -> [SubscriptionPlan] {
        return offers.flatMap { offer in
            let priceString: String = getPriceInfo(for: offer, accountType: accountType)
            let name = getOfferQuota(for: offer)?.bytesString ?? (getOfferDisplayName(for: offer) ?? "")
            
            return subscriptionPlanWith(name: name, priceString: priceString, type: getOfferType(for: offer), model: offer)
        }
    }
    
    //MARK: - Analytics
    func getPurchaseEvent(for offer: Any) -> AnalyticsEvent? {
        var event: AnalyticsEvent?
        
        let isTurkcellOffer = offer is PackageModelResponse
        if let name = getOfferName(for: offer) {
            if isPremiumPurchase(for: offer) {
                event = isTurkcellOffer ? .purchaseTurkcellPremium : .purchaseNonTurkcellPremium
                
            } else if name.contains("500") {
                event = isTurkcellOffer ? .purchaseTurkcell500 : .purchaseNonTurkcell500
                
            } else if name.contains("100") {
                event = isTurkcellOffer ? .purchaseTurkcell100 : .purchaseNonTurkcell100
                
            } else if name.contains("50") {
                event = isTurkcellOffer ? .purchaseTurkcell50 : .purchaseNonTurkcell50
                
            } else if name.contains("2.5") || name.contains("2,5") {
                event = isTurkcellOffer ? .purchaseTurkcell2500 : .purchaseNonTurkcell2500
                
            }
        }
        return event
    }
    
    private func getOfferName(for offer: Any) -> String? {
        var name: String?
        if let offer = offer as? PackageModelResponse, let nameString = offer.name {
            name = nameString
        } else if let offer = offer as? SKProduct {
            name = offer.localizedTitle.lowercased()
        }
        return name
    }
    
    private func isPremiumPurchase(for offer: Any) -> Bool {
        var isPremiumPurchase = false
        if let offer = offer as? PackageModelResponse , let authorities = offer.authorities {
            isPremiumPurchase = authorities.contains(where: { $0.authorityType == .premiumUser })
        } else if let offer = offer as? SKProduct {
            isPremiumPurchase = offer.isPremiumPurchase
        }
        return isPremiumPurchase
    }
}
