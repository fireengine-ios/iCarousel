//
//  SubscriptionPlanBaseResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum SubscriptionType: String {
    case free = "FREE_OF_CHARGE"
    case google = "INAPP_PURCHASE_GOOGLE"
    case apple = "INAPP_PURCHASE_APPLE"
    case promo = "PROMO_CODE"
    
    var description: String {
        switch self {
        case .google: return TextConstants.subscriptionGoogleText
        case .apple: return TextConstants.subscriptionAppleText
        default: return ""
        }
    }
}

class SubscriptionPlanBaseResponse: ObjectRequestResponse {
    
    struct SubscriptionConstants {
        static let createdDate = "createdDate"
        static let lastModifiedDate = "lastModifiedDate"
        static let createdBy = "createdBy"
        static let lastModifiedBy = "lastModifiedBy"
        static let isCurrentSubscription = "isCurrentSubscription"
        static let status = "status"
        static let nextRenewalDate = "nextRenewalDate"
        static let subscriptionEndDate = "subscriptionEndDate"
        static let renewalStatus = "renewalStatus"
        
        static let subscriptionPlan = "subscriptionPlan"
        
        static let subscriptionPlanName = "name"
        static let subscriptionPlanDisplayName = "displayName"
        static let subscriptionPlanDescription = "description"
        static let subscriptionPlanPrice = "price"
        static let subscriptionPlanCurrency = "currency"
        static let subscriptionPlanisDefault = "isDefault"
        static let subscriptionPlanRole = "role"
        static let subscriptionPlanStatus = "status"
        static let subscriptionPlanAuthorities = "authorities"
        static let subscriptionPlanType = "type"
        static let subscriptionPlanSlcmOfferId = "slcmOfferId"
        static let subscriptionPlanCometOfferId = "cometOfferId"
        static let subscriptionPlanQuota = "quota"
        static let subscriptionPlanPeriod = "period"
        static let subscriptionPlaninAppPurchaseId = "inAppPurchaseId"
    }
    
    var createdDate: NSNumber?
    var lastModifiedDate: NSNumber?
    var createdBy: String?
    var lastModifiedBy: String?
    var isCurrentSubscription: Bool?
    var status: String?
    var nextRenewalDate: NSNumber?
    var subscriptionEndDate: NSNumber?
    var renewalStatus: String?
    
    var subscriptionPlan: [AnyHashable: Any]?
    
    var subscriptionPlanName: String?
    var subscriptionPlanDisplayName: String?
    var subscriptionPlanDescription: String?
    var subscriptionPlanPrice: Float?
    var subscriptionPlanCurrency: String?
    var subscriptionPlanIsDefault: Bool?
    var subscriptionPlanRole: String?
    var subscriptionPlanStatus: PackageModelResponse.PackageStatus?
    var subscriptionPlanAuthorities: [PackagePackAuthoritiesResponse]?
    var subscriptionPlanType: PackageType?
    var subscriptionPlanFeatureType: FeaturePackageType?
    var subscriptionPlanSlcmOfferId: String?
    var subscriptionPlanCometOfferId: String?
    var subscriptionPlanQuota: Int64?
    var subscriptionPlanPeriod: String?
    var subscriptionPlanInAppPurchaseId: String?
    
    override func mapping() {
        createdDate = json?[SubscriptionConstants.createdDate].number
        lastModifiedDate = json?[SubscriptionConstants.lastModifiedDate].number
        createdBy = json?[SubscriptionConstants.createdBy].string
        lastModifiedBy = json?[SubscriptionConstants.lastModifiedBy].string
        isCurrentSubscription = json?[SubscriptionConstants.isCurrentSubscription].bool
        status = json?[SubscriptionConstants.status].string
        nextRenewalDate = json?[SubscriptionConstants.nextRenewalDate].number
        subscriptionEndDate = json?[SubscriptionConstants.subscriptionEndDate].number
        renewalStatus = json?[SubscriptionConstants.renewalStatus].string
        
        let tempoSubscriptionPlan = json?[SubscriptionConstants.subscriptionPlan].dictionary
        
        subscriptionPlan = tempoSubscriptionPlan
        
        subscriptionPlanName = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanName]?.string
        subscriptionPlanDisplayName = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanDisplayName]?.string
        subscriptionPlanDescription = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanDescription]?.string
        subscriptionPlanPrice = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanPrice]?.float
        subscriptionPlanCurrency = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanCurrency]?.string
        subscriptionPlanIsDefault = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanisDefault]?.bool
        subscriptionPlanRole = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanRole]?.string
        if let status = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanStatus]?.string {
            subscriptionPlanStatus = PackageModelResponse.PackageStatus(rawValue: status)
        }
        if let authorities = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanAuthorities]?.array {
            subscriptionPlanAuthorities = authorities.flatMap({ PackagePackAuthoritiesResponse(withJSON: $0) })
        }
        if let type = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanType]?.string {
            if type.uppercased().contains("DIGICELL"), let role = subscriptionPlanRole {
                if role.uppercased().contains(AccountType.FWI.rawValue) && type == PackageType.FWI.rawValue {
                    subscriptionPlanType = .FWI
                } else if role.uppercased().contains(AccountType.jamaica.rawValue) && type == PackageType.jamaica.rawValue {
                    subscriptionPlanType = .jamaica
                }
            } else {
                subscriptionPlanType = PackageType(rawValue: type)
                subscriptionPlanFeatureType = FeaturePackageType(rawValue: type)
            }
        }
        subscriptionPlanSlcmOfferId = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanSlcmOfferId]?.string
        subscriptionPlanCometOfferId = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanCometOfferId]?.string
        subscriptionPlanQuota = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanQuota]?.int64
        subscriptionPlanPeriod = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanPeriod]?.string
        subscriptionPlanInAppPurchaseId = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlaninAppPurchaseId]?.string
    }
}

class ActiveSubscriptionResponse: ObjectRequestResponse {
    
    var list: [SubscriptionPlanBaseResponse] = []
    
    override func mapping() {
        guard let tmpList = json?.array?.flatMap({ SubscriptionPlanBaseResponse(withJSON: $0) }) else { return }
        list = tmpList
    }
}

/// MAYBE WILL BE NEED
//class CurrentSubscriptionResponse: ObjectRequestResponse {
//
//    var subscription: SubscriptionPlanBaseResponse?
//
//    override func mapping() {
//        subscription = SubscriptionPlanBaseResponse(withJSON: json)
//    }
//}

/// MAYBE WILL BE NEED
//class CancelSubscriptionResponse: ObjectRequestResponse {
//
//    override func mapping() {
//        print(json?.array ?? "- CurrentSubscriptionResponse nil")
//    }
//}
