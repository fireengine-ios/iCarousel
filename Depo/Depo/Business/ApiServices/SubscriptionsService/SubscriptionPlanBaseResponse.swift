//
//  SubscriptionPlanBaseResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

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
        static let type = "type"
        static let renewalStatus = "renewalStatus"
        
        static let subscriptionPlan = "subscriptionPlan"
        static let subscriptionPlanName = "name"
        static let subscriptionPlanDisplayName = "displayName"
        static let subscriptionPlanDescription = "description"
        static let subscriptionPlanPrice = "price"
        static let subscriptionPlanisDefault = "isDefault"
        static let subscriptionPlanRole = "role"
        static let subscriptionPlanSlcmOfferId = "slcmOfferId"
        static let subscriptionPlanCometOfferId = "cometOfferId"
        static let subscriptionPlanQuota = "quota"
        static let subscriptionPlanPeriod = "period"
        static let subscriptionPlaninAppPurchaseId = "inAppPurchaseId"
        static let subscriptionPlanType = "type"
    }
    
    var createdDate: NSNumber?
    var lastModifiedDate: NSNumber?
    var createdBy: String?
    var lastModifiedBy: String?
    var isCurrentSubscription: Bool?
    var status: String?
    var nextRenewalDate: NSNumber?
    var subscriptionEndDate: NSNumber?
    var type: String?
    var renewalStatus: String?
    
    var subscriptionPlan: [AnyHashable: Any]?
    
    var subscriptionPlanName: String?
    var subscriptionPlanDisplayName: String?
    var subscriptionPlanDescription: String?
    var subscriptionPlanPrice: Float?
    var subscriptionPlanIsDefault: Bool?
    var subscriptionPlanRole: String?
    var subscriptionPlanSlcmOfferId: String?
    var subscriptionPlanCometOfferId: String?
    var subscriptionPlanQuota: Int64?
    var subscriptionPlanPeriod: String?
    var subscriptionPlanInAppPurchaseId: String?
    var subscriptionPlanType: String?
    
    override func mapping() {
        createdDate = json?[SubscriptionConstants.createdDate].number
        lastModifiedDate = json?[SubscriptionConstants.lastModifiedDate].number
        createdBy = json?[SubscriptionConstants.createdBy].string
        lastModifiedBy = json?[SubscriptionConstants.lastModifiedBy].string
        isCurrentSubscription = json?[SubscriptionConstants.isCurrentSubscription].bool
        status = json?[SubscriptionConstants.status].string
        nextRenewalDate = json?[SubscriptionConstants.nextRenewalDate].number
        subscriptionEndDate = json?[SubscriptionConstants.subscriptionEndDate].number
        type = json?[SubscriptionConstants.type].string
        renewalStatus = json?[SubscriptionConstants.renewalStatus].string
        
        let tempoSubscriptionPlan = json?[SubscriptionConstants.subscriptionPlan].dictionary
        
        subscriptionPlan = tempoSubscriptionPlan
        
        subscriptionPlanName = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanName]?.string
        subscriptionPlanDisplayName = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanDisplayName]?.string
        subscriptionPlanDescription = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanDescription]?.string
        subscriptionPlanPrice = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanPrice]?.float
        subscriptionPlanIsDefault = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanisDefault]?.bool
        subscriptionPlanRole = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanRole]?.string
        subscriptionPlanSlcmOfferId = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanSlcmOfferId]?.string
        subscriptionPlanCometOfferId = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanCometOfferId]?.string
        subscriptionPlanQuota = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanQuota]?.int64
        subscriptionPlanPeriod = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanPeriod]?.string
        subscriptionPlanInAppPurchaseId = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlaninAppPurchaseId]?.string
        subscriptionPlanType = tempoSubscriptionPlan?[SubscriptionConstants.subscriptionPlanType]?.string
        
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
