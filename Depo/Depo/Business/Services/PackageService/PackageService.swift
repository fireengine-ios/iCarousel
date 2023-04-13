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

    @available(iOS 12.0, *)
    private var iapIntroEligibilityChecker: IAPIntroPriceEligibilityChecker {
        get {
            return IAPIntroPriceEligibilityChecker.shared
        }
    }

    private lazy var introOfferEligibilityStatusByProductId: [String: IAPIntroEligibilityStatus] = [:]

    @available(iOS 11.2, *)
    private var iapSubscriptionPeriodFormatter: ProductSubscriptionPeriodFormatter {
        get {
            return ProductSubscriptionPeriodFormatter.shared
        }
    }

    
    //MARK: Utility Methods(public)
    func getAccountType(for accountType: String, offers: [Any] = []) -> AccountType? {
        guard AccountType(rawValue: accountType) != .turkcell else {
            return .turkcell
        }

        let roles = offers.map { getOfferRole(for: $0) }
        for role in roles {
            if role.starts(with: "DIGICELL") {
                ///FeaturePackageType need for leave premium
                if role.contains(AccountType.FWI.rawValue) {
                    return .FWI
                } else if role.contains(AccountType.jamaica.rawValue) {
                    return .jamaica
                }
            } else if let index = role.firstIndex(of: "-"), let accountType = AccountType(rawValue: String(role[..<index])) {
                return accountType
            }
        }

        return nil
    }
    
    func getInfoForAppleProducts(offers: [Any], isActivePurchases: Bool = false, success: @escaping () -> (), fail: @escaping (Error) -> ()) {
        let appleOffers = getAppleIds(for: offers)
        iapManager.loadProducts(productIds: appleOffers, isActivePurchases: isActivePurchases) { [weak self] response in
            switch response {
            case .success(_):
                self?.introOfferEligibilityStatusByProductId = [:]
                guard #available(iOS 12.0, *) else {
                    success()
                    return
                }

                // No need to check eligibility for already purchased products
                guard !isActivePurchases else {
                    success()
                    return
                }

                guard let receiptData = self?.iapManager.receiptData else {
                    success()
                    return
                }

                self?.iapIntroEligibilityChecker.checkEligibility(
                    with: receiptData,
                    productIdentifiers: Set(appleOffers)
                ) { [weak self] eligibilityStatusDict, _ in
                    self?.introOfferEligibilityStatusByProductId = eligibilityStatusDict
                    success()
                }

            case .failed(let error):
                fail(error)
            }
        }
    }
    
    func getOfferPrice(for offer: Any, accountType: AccountType) -> String {
        
        let fullPrice: String
        if let iapProductId = getAppleIds(for: [offer]).first, let product = iapManager.product(for: iapProductId), !product.isFree {
            
            let price = product.localizedPrice

            if #available(iOS 11.2, *) {
                guard let subscriptionPeriod = product.subscriptionPeriod,
                      let period = iapSubscriptionPeriodFormatter.string(from: subscriptionPeriod) else {
                    return String(format: TextConstants.packageApplePrice, price, TextConstants.packagePeriodMonth)
                }

                return String(format: TextConstants.packageApplePrice, price, period)
            } else {
                if let period = getOfferPeriod(for: offer) {
                    fullPrice = String(format: TextConstants.packageApplePrice, price, period)
                } else {
                    fullPrice = price
                }
            }
        } else {
            if let price = getOfferPrice(for: offer) {
                let currency = getOfferCurrency(for: offer) ?? getOfferCurrency(for: accountType)
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

    func getIntroductoryPrice(for offer: Any, isPurchasedOffer: Bool) -> String? {
        guard #available(iOS 11.2, *) else {
            return nil
        }

        // get SKProduct
        guard let productId = getAppleIds(for: [offer]).first,
              let product = iapManager.product(for: productId) else {
            return nil
        }

        // Make sure it has an intro offer
        guard let introductoryPrice = product.introductoryPrice else {
            return nil
        }

        let shouldDisplayIntroPrice: Bool

        if !isPurchasedOffer {
            // Make sure the user is eligible for buying an intro offer for this product
            shouldDisplayIntroPrice = introOfferEligibilityStatusByProductId[product.productIdentifier] == .eligible
        } else {
            // Make sure the user has a product that was purchased with an intro price
            shouldDisplayIntroPrice = (try? receiptHasActiveSubscriptionPurchasedWithIntroPrice(productId: productId)) ?? false
        }

        guard shouldDisplayIntroPrice else {
            return nil
        }

        return formattedIntroductoryOfferText(from: introductoryPrice, product: product)
    }

    private func receiptHasActiveSubscriptionPurchasedWithIntroPrice(productId: String) throws -> Bool {
        let receipt = try ReceiptParser().parse(from: iapManager.receiptData ?? Data())
        let inAppPurchases = receipt.inAppPurchases
        return inAppPurchases.contains { purchase in
            return purchase.productId == productId &&
                   (purchase.isInIntroOfferPeriod == true || purchase.isInTrialPeriod == true)
        }
    }

    @available(iOS 11.2, *)
    private func formattedIntroductoryOfferText(from introductoryPrice: SKProductDiscount, product: SKProduct) -> String {
        guard let subscriptionPeriod = product.subscriptionPeriod else {
            return ""
        }

        let price = formattedPrice(product.price, priceLocale: product.priceLocale)
        let period = iapSubscriptionPeriodFormatter.string(from: subscriptionPeriod) ?? ""

        let discountPrice = formattedPrice(introductoryPrice.price, priceLocale: introductoryPrice.priceLocale)
        let discountPeriod = iapSubscriptionPeriodFormatter.string(from: introductoryPrice.subscriptionPeriod) ?? ""
        let discountTotalPeriod = iapSubscriptionPeriodFormatter.string(
            from: introductoryPrice.subscriptionPeriod,
            numberOfPeriods: introductoryPrice.numberOfPeriods
        ) ?? ""

        func combined(_ price: String, _ period: String) -> String {
            [price, period].joined(separator: "/")
        }

        switch introductoryPrice.paymentMode {
        case .freeTrial:
            return String(
                format: localized(.iapIntroOfferFreeTrial),
                discountTotalPeriod,
                combined(price, period)
            )
        case .payAsYouGo:
            return String(
                format: localized(.iapIntroOfferPayAsYouGo),
                discountTotalPeriod,
                combined(discountPrice, discountPeriod),
                combined(price, period)
            )
        case .payUpFront:
            return String(
                format: localized(.iapIntroOfferPayUpFront),
                discountTotalPeriod,
                discountPrice,
                combined(price, period)
            )
        @unknown default:
            return ""
        }
    }

    private func formattedPrice(_ price: NSNumber, priceLocale: Locale) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.positiveFormat = "#.## ¤¤"
        numberFormatter.locale = priceLocale
        return numberFormatter.string(from: price) ?? ""
    }

    func convertToSubscriptionPlan(
        offers: [Any],
        accountType: AccountType,
        isPurchasedOffers: Bool = false
    ) -> [SubscriptionPlan] {
        return offers.map { offer in
            subscriptionPlanWith(
                name: getOfferName(offer: offer),
                price: getOfferPrice(for: offer, accountType: accountType),
                introductoryPrice: getIntroductoryPrice(for: offer, isPurchasedOffer: isPurchasedOffers),
                type: getOfferType(for: offer),
                model: offer,
                quota: getOfferQuota(offer: offer),
                amount: getOfferAmount(offer: offer),
                isRecommended: getOfferRecommendationStatus(offer: offer),
                features: getOfferAvailableFeatures(offer: offer),
                addonType: .make(model: offer),
                date: getOfferDate(for: offer),
                store: getOfferStore(for: offer),
                packageStatus: getPackageStatus(for: offer),
                gracePeriodEndDate: getGracePeriodEndDate(for: offer),
                period: getPeriod(for: offer)
            )
        }
    }
    
    //MARK: Analytics
    func getPurchaseEvent(for offer: Any) -> AnalyticsEvent? {
        func getOfferName(for offer: Any) -> String? {
            var name: String?
            if let offer = offer as? PackageModelResponse, let nameString = offer.name {
                name = nameString
            } else if let offer = offer as? SKProduct {
                name = offer.localizedTitle.lowercased()
            }
            return name
        }

        func isSixMonthOffer(_ offer: Any) -> Bool {
            if let offer = offer as? PackageModelResponse {
                return offer.period == PackageModelResponse.Period.sixMonth.rawValue
            } else if let offer = offer as? SKProduct, #available(iOS 11.2, *) {
                return offer.subscriptionPeriod?.unit == .month && offer.subscriptionPeriod?.numberOfUnits == 6
            }
            return false
        }
        
        func hasIntroductoryPrice(_ offer: Any) -> Bool {
            if let offer = offer as? SKProduct, #available(iOS 11.2, *) {
                return offer.introductoryPrice != nil
            }
            return false
        }
        
        func offerPeriod(for offer: Any) -> String {
            var period: String?
            if let offer = offer as? PackageModelResponse, let periodName = offer.period {
                period = periodName
            }
            return period ?? ""
        }
        
        var event: AnalyticsEvent?
        
        let isTurkcellOffer = offer is PackageModelResponse
        if offerPeriod(for: offer) == "MONTH" || offerPeriod(for: offer) == "SIXMONTH" {
            if let name = getOfferName(for: offer) {
                if getOfferPremiumPurchaseStatus(for: offer) {
                    event = isTurkcellOffer ? .purchaseTurkcellPremium : .purchaseNonTurkcellPremium
                    
                } else if name.contains("500") {
                    event = isTurkcellOffer ? .purchaseTurkcell500 : .purchaseNonTurkcell500
                } else if name.contains("100") {
                    event = isTurkcellOffer ? .purchaseTurkcell100 : .purchaseNonTurkcell100
                    
                } else if name.contains("250") {
                    if isSixMonthOffer(offer) {
                        event = isTurkcellOffer ? .purchaseTurkcell250_SixMonth : .purchaseNonTurkcell250_SixMonth
                    } else if hasIntroductoryPrice(offer) {
                        event = isTurkcellOffer ? .purchaseTurkcell250Freemium : .purchaseNonTurkcell250Freemium
                    } else {
                        event = isTurkcellOffer ? .purchaseTurkcell250 : .purchaseNonTurkcell250
                    }
                    
                } else if name.contains("50") {
                    event = isTurkcellOffer ? .purchaseTurkcell50 : .purchaseNonTurkcell50
                    
                } else if name.contains("2.5") || name.contains("2,5") {
                    event = isTurkcellOffer ? .purchaseTurkcell2500 : .purchaseNonTurkcell2500
                    
                } else if name.contains("digital advertising package") {
                    event = isTurkcellOffer ? .purchaseTurkcell500Advertising : .purchaseNonTurkcell500Advertising
                }
            }
        } else if offerPeriod(for: offer) == "YEAR" {
            if let name = getOfferName(for: offer) {
                if getOfferPremiumPurchaseStatus(for: offer) {
                    event = isTurkcellOffer ? .purchaseTurkcellPremium : .purchaseNonTurkcellPremium
                } else if name.contains("500") {
                    event = isTurkcellOffer ? .purchaseTurkcell500Year : .purchaseNonTurkcell500Year
                }  else if name.contains("250") {
                    event = isTurkcellOffer ? .purchaseTurkcell250Year : .purchaseNonTurkcell250Year
                } else if name.contains("100") {
                    event = isTurkcellOffer ? .purchaseTurkcell100Year : .purchaseNonTurkcell100Year
                } else if name.contains("2.5") || name.contains("2,5") {
                    event = isTurkcellOffer ? .purchaseTurkcell2500Year : .purchaseNonTurkcell2500Year
                } else if name.contains("digital advertising package") {
                    event = isTurkcellOffer ? .purchaseTurkcell500Advertising : .purchaseNonTurkcell500Advertising
                }
            }
        }
        return event
    }
    
    //MARK: Utility Methods(private)
    private func subscriptionPlanWith(name: String,
                                      price: String,
                                      introductoryPrice: String?,
                                      type: SubscriptionPlanType,
                                      model: Any,
                                      quota: Int64,
                                      amount: Float,
                                      isRecommended: Bool,
                                      features: [AuthorityType],
                                      addonType: SubscriptionPlan.AddonType?,
                                      date: String = "",
                                      store: String = "",
                                      packageStatus: String? = nil,
                                      gracePeriodEndDate: String = "",
                                      period: String?) -> SubscriptionPlan {
        return SubscriptionPlan(name: name,
                                price: price,
                                introductoryPrice: introductoryPrice,
                                type: type,
                                model: model,
                                quota: quota,
                                amount: amount,
                                isRecommended: isRecommended,
                                features: features,
                                addonType: addonType,
                                date: date,
                                store: store,
                                packageStatus: packageStatus,
                                gracePeriodEndDate: gracePeriodEndDate,
                                period: period)
    }
    
    private func localizedOfferPeriod(_ offerPeriod: String) -> String {
        if offerPeriod.contains("year") {
            return TextConstants.packagePeriodYear
        } else if offerPeriod.contains("sixmonth") {
            return String(format: TextConstants.packagePeriodXMonth, 6)
        } else if offerPeriod.contains("month") {
            return TextConstants.packagePeriodMonth
        } else if offerPeriod.contains("week") {
            return TextConstants.packagePeriodWeek
        } else if offerPeriod.contains("day") {
            return TextConstants.packagePeriodDay
        }
        
        return offerPeriod
    }
    
    private func getOfferCurrency(for accountType: AccountType) -> String {
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
        return offers.map {
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
            period = localizedOfferPeriod(periodString.lowercased())
        } else if let offer = offer as? SubscriptionPlanBaseResponse, let periodString = offer.subscriptionPlanPeriod {
            period = localizedOfferPeriod(periodString.lowercased())
        }
        return period
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

    func getOfferPriceAsNumber(for offer: Any) -> NSNumber? {
        if let offer = offer as? PackageModelResponse, let priceFloat = offer.price, priceFloat > 0 {
            return NSNumber(value: priceFloat)
        } else if let offer = offer as? SubscriptionPlanBaseResponse, let priceFloat = offer.subscriptionPlanPrice, priceFloat > 0 {
            return NSNumber(value: priceFloat)
        } else if let offer = offer as? SKProduct {
            return offer.price
        }

        return nil
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
            type = (offer.subscriptionPlanPrice ?? 0) == 0 ? .free : .current
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
    
    private func getOfferName(offer: Any) -> String {
        let name: String
        let addonType = SubscriptionPlan.AddonType.make(model: offer)
        if addonType == .featureOnly {
            name = TextConstants.featurePackageName
        } else if addonType == .middleOnly {
            name = TextConstants.middleFeaturePackageName
        } else {
            name = getOfferQuota(for: offer)?.bytesString ?? (getOfferDisplayName(for: offer) ?? "")
        }
        let prefix = ((getOfferType(for: offer) == .default) && (addonType != .featureOnly)) ? "+" : ""
        return prefix + name
    }
    
    private func getOfferAmount(offer: Any) -> Float {
        if let packageModel = offer as? PackageModelResponse, let price = packageModel.price {
            return price
        } else if let subscriptionPlan = offer as? SubscriptionPlanBaseResponse, let price = subscriptionPlan.subscriptionPlanPrice {
            return price
        } else {
            return 0
        }
    }
    
    
    private func getOfferQuota(offer: Any) -> Int64 {
        if let packageModel = offer as? PackageModelResponse, let quota = packageModel.quota {
            return quota
        } else if let subscriptionPlan = offer as? SubscriptionPlanBaseResponse, let quota = subscriptionPlan.subscriptionPlanQuota {
            return quota
        } else {
            return 0
        }
    }
    
    private func getOfferRecommendationStatus(offer: Any) -> Bool {
        if let packageModel = offer as? PackageModelResponse {
            return packageModel.isRecommended == true
        } else {
            return false
        }
    }
    
    private func getOfferAvailableFeatures(offer: Any) -> [AuthorityType] {
        if let packageModel = offer as? PackageModelResponse,
            let authorities = packageModel.authorities {
            return authorities
                .compactMap { $0.authorityType }
                .filter { AuthorityType.typesInOffer.contains($0) }
        } else if let plan = offer as? SubscriptionPlanBaseResponse,
            let authorities = plan.subscriptionPlanAuthorities {
            return authorities
                .compactMap { $0.authorityType }
                .filter { AuthorityType.typesInOffer.contains($0) }
        } else {
            return []
        }
    }
    
    private func getOfferPremiumPurchaseStatus(for offer: Any) -> Bool {
        var isPremiumPurchase = false
        if let offer = offer as? PackageModelResponse, let authorities = offer.authorities {
            isPremiumPurchase = authorities.contains(where: { $0.authorityType == .premiumUser })
        } else if let offer = offer as? SKProduct {
            isPremiumPurchase = offer.isPremiumPurchase
        }
        return isPremiumPurchase
    }
    
    private func dateString(from dateInterval: NSNumber) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(dateInterval.doubleValue / 1000)))
    }
    
    private func getOfferDate(for offer: Any) -> String {
        guard let model = offer as? SubscriptionPlanBaseResponse else {
            return ""
        }
        
        let resultDate: String
        if let expirationDate = model.subscriptionEndDate, model.subscriptionPlanType.isSameAs(QuotaPackageType.promo) {
            let date = dateString(from: expirationDate)
            resultDate = String(format: TextConstants.subscriptionEndDate, date)
            
        } else if let renewalDate = model.nextRenewalDate {
            let date = dateString(from: renewalDate)
            resultDate = String(format: TextConstants.renewalDate, date)
            
        } else {
            resultDate = ""
        }
        
        return resultDate
    }
    
    private func getOfferStore(for offer: Any) -> String {
        let contentType: PackageContentType?
        let store: String
        if let offer = offer as? SubscriptionPlanBaseResponse {
            contentType = offer.subscriptionPlanType
            
        } else if let offer = offer as? PackageModelResponse {
            contentType = offer.type
        } else {
            assertionFailure("Unknown offer object type")
            return ""
        }
        
        guard let type = contentType else {
            return ""
        }
        
        switch type {
        case .quota(let type):
            switch type {
            case .apple:
                store = TextConstants.offerStoreAppleStore
            case .google:
                store = TextConstants.offerStoreGoogleStore
            case .promo:
                store = TextConstants.offerStorePromo
            default:
                store = ""
            }
        case .feature(let type):
            switch type {
            case .appleFeature:
                store = TextConstants.offerStoreAppleStore
            case .googleFeature:
                store = TextConstants.offerStoreGoogleStore
            case .promoFeature:
                store = TextConstants.offerStorePromo
            default:
                store = ""
            }
        }
        
        return store
    }
    
    private func getPackageStatus(for offer: Any) -> String? {
        if let offer = offer as? SubscriptionPlanBaseResponse {
            return offer.status
        } else {
            return nil
        }
    }
    
    private func getGracePeriodEndDate(for offer: Any) -> String {
        if let offer = offer as? SubscriptionPlanBaseResponse {
            if let gracePeriodEndDate = offer.gracePeriodEndDate {
                let date = dateString(from: gracePeriodEndDate)
                return date
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    private func getPeriod(for offer: Any) -> String {
        if let offer = offer as? PackageModelResponse {
            if let gracePeriodEndDate = offer.period {
                return gracePeriodEndDate
            } else {
                return ""
            }
        } else {
            return ""
        }
    }

}
