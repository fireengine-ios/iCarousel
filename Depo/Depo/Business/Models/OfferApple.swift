//
//  OfferApple.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import StoreKit

class OfferApple {
    var storeProductIdentifier: String?
    var period: String?
    var name: String?
    var rawPrice: Float = 0
    var price: String?
    var description: String?
    var skProduct = SKProduct()
    
    
    init(productId: String) {
        storeProductIdentifier = productId
    }
    
    init(skProduct: SKProduct) {
        storeProductIdentifier = skProduct.productIdentifier
        period = parseDuration(byIdentifier: skProduct.productIdentifier)
        name = skProduct.localizedTitle
        rawPrice = skProduct.price.floatValue
        price = skProduct.localizedPrice
        description = skProduct.localizedDescription
        self.skProduct = skProduct
    }
    
    private func parseDuration(byIdentifier rawId: String) -> String {
        if rawId != "" {
            let splittedList = rawId.components(separatedBy: "_")
            if splittedList.count > 1 {
                let lastItem = splittedList[splittedList.count - 1].uppercased()
                if lastItem == "MONTH" {
                    return "MONTH"
                } else if lastItem == "MONTHS" {
                    let length = splittedList[splittedList.count - 2]
                    return "\(length)_\("MONTHS")"
                } else if lastItem == "DAYS" {
                    let length = splittedList[splittedList.count - 2]
                    return "\(length)_\("DAYS")"
                } else if lastItem == "YEAR" {
                    return "YEAR"
                }
            }
        }
        return ""
    }
}
