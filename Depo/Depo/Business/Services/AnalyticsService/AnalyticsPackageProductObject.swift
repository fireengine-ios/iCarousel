//
//  AnalyticsPackageProductObject.swift
//  Depo
//
//  Created by Aleksandr on 7/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

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
            AnalyticsPackageProductParametrs.itemName.text : itemName,
            AnalyticsPackageProductParametrs.itemID.text : itemID,
            AnalyticsPackageProductParametrs.price.text : price,
            AnalyticsPackageProductParametrs.itemBrand.text : itemBrand,
            AnalyticsPackageProductParametrs.itemCategory.text : itemCategory,
            AnalyticsPackageProductParametrs.itemVariant.text : itemVariant,
            AnalyticsPackageProductParametrs.index.text : index,
            AnalyticsPackageProductParametrs.quantity.text : quantity
        ]
    }
    ///should be something like this:
//        'AnalyticsParameterItemName': '50GB', // Product Name
//        'AnalyticsParameterItemID': 'sku1234', // Product ID
//        'AnalyticsParameterPrice': '117.00',
//        'AnalyticsParameterItemBrand': 'Lifebox',
//        'AnalyticsParameterItemCategory': 'Saklama Alanı', // Product Category
//        'AnalyticsParameterItemVariant': '',
//        'AnalyticsParameterIndex': 1 //Position number of the product in the list its shown.
//        'AnalyticsParameterQuantity': 1 //Information on how many pieces are purchased. Sepete Add will fill in Checkout and Purchase actions.
}
