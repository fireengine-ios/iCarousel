//
//  SKProduct+Localized.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.positiveFormat = "#.## ¤¤"
        numberFormatter.locale = priceLocale
        return numberFormatter.string(from: price) ?? ""
    }
    
    var isFree: Bool {
        return price == .zero
    }
    
    var isPremiumPurchase: Bool {
        return productIdentifier.contains("feature")
    }
}
