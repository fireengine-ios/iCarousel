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
    
    init(name: String, photosCount: Int, videosCount: Int, songsCount: Int, docsCount: Int, priceString: String, type: SubscriptionPlanType, model: Any) {
        self.name = name
        self.photosCount = photosCount
        self.videosCount = videosCount
        self.songsCount = songsCount
        self.docsCount = docsCount
        self.priceString = priceString
        self.type = type
        self.model = model
    }
}
