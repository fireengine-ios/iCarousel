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
        case storageOnly
        case featureOnly
        
        static func make(model: Any) -> AddonType? {
            let isFeaturePack: Bool
            let hasAttachedFeature: Bool
            
            if let package = model as? PackageModelResponse {
                isFeaturePack = package.isFeaturePack ?? false
                hasAttachedFeature = package.hasAttachedFeature ?? false
            } else if let plan = model as? SubscriptionPlanBaseResponse {
                isFeaturePack = plan.subscriptionPlanIsFeaturePack ?? false
                hasAttachedFeature = plan.subscriptionPlanHasAttachedFeature ?? false
            } else {
                return nil
            }
            
            if isFeaturePack {
                return .featureOnly
            } else if hasAttachedFeature == false {
                return .storageOnly
            } else {
                return .bundle
            }
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

    init(name: String,
         price: String,
         type: SubscriptionPlanType,
         model: Any,
         quota: Int64,
         amount: Float,
         isRecommended: Bool,
         features: [AuthorityType],
         addonType: AddonType?,
         date: String,
         store: String) {
        self.name = name
        self.price = price
        self.type = type
        self.model = model
        self.quota = quota
        self.amount = amount
        self.isRecommended = isRecommended
        self.features = features
        self.addonType = addonType
        self.date = date
        self.store = store
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
