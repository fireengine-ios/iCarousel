//
//  PackageOffer.swift
//  Depo
//
//  Created by Maxim Soldatov on 9/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

class PackageOffer {
    let quotaNumber: Int64
    var offers: [SubscriptionPlan]
    
    init(quotaNumber: Int64, offers: [SubscriptionPlan]) {
        self.quotaNumber = quotaNumber
        self.offers = PackageOffer.sortOffersByPrice(offers: offers)
    }
    
    private class func sortOffersByPrice(offers: [SubscriptionPlan]) -> [SubscriptionPlan] {
        return offers.sorted { (first, second) -> Bool in
            return first.amount.isLess(than: second.amount)
        }
    }
}
