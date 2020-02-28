//
//  SubscriptionPlan.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/20/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class SubscriptionPlan {
    enum AddonType {
        case bundle
        case storageOnly
        case featureOnly
        
        static func make(with model: Any) -> AddonType? {
            guard let model = model as? PackageModelResponse else {
                return nil
            }
            
            if model.isFeaturePack == true {
                return .featureOnly
            } else if model.hasAttachedFeature == false {
                return .storageOnly
            } else {
                return .bundle
            }
        }
    }
    
    let name: String
    let photosCount: Int
    let videosCount: Int
    let songsCount: Int
    let docsCount: Int
    let priceString: String
    let type: SubscriptionPlanType
    let model: Any
    let quota: Int64
    let price: Float
    let isRecommended: Bool
    let features: [AuthorityType]
    let addonType: AddonType?

    init(name: String,
         photosCount: Int,
         videosCount: Int,
         songsCount: Int,
         docsCount: Int,
         priceString: String,
         type: SubscriptionPlanType,
         model: Any,
         quota: Int64,
         price: Float,
         isRecommended: Bool,
         features: [AuthorityType],
         addonType: AddonType?) {
        self.name = name
        self.photosCount = photosCount
        self.videosCount = videosCount
        self.songsCount = songsCount
        self.docsCount = docsCount
        self.priceString = priceString
        self.type = type
        self.model = model
        self.quota = quota
        self.price = price
        self.isRecommended = isRecommended
        self.features = features
        self.addonType = addonType
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
