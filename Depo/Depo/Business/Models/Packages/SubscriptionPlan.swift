//
//  SubscriptionPlan.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/20/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

final class SubscriptionPlan {
    enum AddonType {
        case bundle
        case middleOnly
        case storageOnly
        case featureOnly
        
        static func make(model: Any) -> AddonType? {
            let isFeaturePack: Bool
            let hasAttachedFeature: Bool
            var isMiddleUser: Bool?
            
            if let package = model as? PackageModelResponse {
                isFeaturePack = package.isFeaturePack ?? false
                hasAttachedFeature = package.hasAttachedFeature ?? false
                isMiddleUser = getMiddleAuthority(authorities: package.authorities)
            } else if let plan = model as? SubscriptionPlanBaseResponse {
                isFeaturePack = plan.subscriptionPlanIsFeaturePack ?? false
                hasAttachedFeature = plan.subscriptionPlanHasAttachedFeature ?? false
                isMiddleUser = getMiddleAuthority(authorities: plan.subscriptionPlanAuthorities)
            } else {
                return nil
            }
            
            if isFeaturePack {
                return isMiddleUser == true ? .middleOnly : .featureOnly
            } else if hasAttachedFeature == false {
                return .storageOnly
            } else {
                return .bundle
            }
        }
        
        static private func getMiddleAuthority(authorities: [PackagePackAuthoritiesResponse]?) -> Bool? {
            guard let authorities = authorities else { return false }
            return authorities.compactMap({ $0.authorityType }).contains(.middleUser)
        }
    }
    
    let name: String
    let price: String
    let type: SubscriptionPlanType
    let model: Any
    let quota: Int64
    let amount: Float
    let isRecommended: Bool
    let features: [AuthorityType]
    let addonType: AddonType?
    let date: String
    let store: String
    let packageStatus: String?
    let gracePeriodEndDate: String
    let introductoryPrice: String?

    init(name: String,
         price: String,
         introductoryPrice: String?,
         type: SubscriptionPlanType,
         model: Any,
         quota: Int64,
         amount: Float,
         isRecommended: Bool,
         features: [AuthorityType],
         addonType: AddonType?,
         date: String,
         store: String,
         packageStatus: String?,
         gracePeriodEndDate: String) {
        self.name = name
        self.price = price
        self.introductoryPrice = introductoryPrice
        self.type = type
        self.model = model
        self.quota = quota
        self.amount = amount
        self.isRecommended = isRecommended
        self.features = features
        self.addonType = addonType
        self.date = date
        self.store = store
        self.packageStatus = packageStatus
        self.gracePeriodEndDate = gracePeriodEndDate
    }
    
    ///FE-990 2.5TB SLCM (Turkcell) quota package cancel text
    ///https://jira.turkcell.com.tr/browse/FE-990
    func getNameForSLCM() -> String {
        if let range = name.range(of: "2.5") {
            let changedName = name.replacingCharacters(in: range, with: "25")
            return changedName
        } else if let range = name.range(of: "2,5") {
            let changedName = name.replacingCharacters(in: range, with: "25")
            return changedName
        } else {
            return name
        }
    }
}
