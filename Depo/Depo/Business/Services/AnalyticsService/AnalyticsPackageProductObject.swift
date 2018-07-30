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
            AnalyticsPackageEcommerce.items.text : items.map{$0.productParametrs},
            AnalyticsPackageEcommerce.itemList.text : itemList,
            AnalyticsPackageEcommerce.transactionID.text : transactionID,
            AnalyticsPackageEcommerce.tax.text : tax,
            AnalyticsPackageEcommerce.priceValue.text : priceValue,
            AnalyticsPackageEcommerce.shipping.text : shipping
        ]
    }
}
//'AnalyticsParameterItemName': '50GB', // Product Name
//'AnalyticsParameterItemID': 'sku1234', // Product ID
//'AnalyticsParameterPrice': '117.00',
//'AnalyticsParameterItemBrand': 'Lifebox',
//'AnalyticsParameterItemCategory': 'Saklama Alanı', // Product Category
//'AnalyticsParameterItemVariant': '',
//'AnalyticsParameterIndex': 1 //Position number of the product in the list its shown.
//'AnalyticsParameterQuantity': 1
