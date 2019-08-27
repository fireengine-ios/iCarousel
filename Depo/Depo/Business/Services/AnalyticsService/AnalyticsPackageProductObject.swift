//
//  AnalyticsPackageProductObject.swift
//  Depo
//
//  Created by Aleksandr on 7/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Firebase

struct AnalyticsPackageProductObject {
    let itemName: String
    let itemID: String
    let price: String
    let itemBrand: String
    let itemCategory: String
    let itemVariant: String
    let index: String
    let quantity: String
    
    var productParametrs: [String: Any] {
        return [
            AnalyticsParameterItemName : itemName,
            AnalyticsParameterItemID : itemID,
            AnalyticsParameterPrice : price,
            AnalyticsParameterItemBrand : itemBrand,
            AnalyticsParameterItemCategory : itemCategory,
            AnalyticsParameterItemVariant : itemVariant,
            AnalyticsParameterIndex : index,
            AnalyticsParameterQuantity : quantity
        ]
    }
}

struct AnalyticsEcommerce {
    let items: [AnalyticsPackageProductObject]
    let itemList: String
    let transactionID: String
    let tax: String
    let priceValue: String
    let shipping: String
    
    var ecommerceParametrs: [String: Any] {
        return [
            AnalyticsPackageEcommerce.items.text : items.map { $0.productParametrs },
            AnalyticsParameterItemList : itemList,
            AnalyticsParameterTransactionID : transactionID,
            AnalyticsParameterTax : tax,
            AnalyticsParameterValue : priceValue,
            AnalyticsParameterShipping : shipping
        ]
    }
}

