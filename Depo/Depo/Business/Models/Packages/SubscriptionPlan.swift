//
//  SubscriptionPlan.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/20/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class SubscriptionPlan {
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

    init(name: String, photosCount: Int, videosCount: Int, songsCount: Int, docsCount: Int, priceString: String, type: SubscriptionPlanType, model: Any, quota: Int64, price: Float) {
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
