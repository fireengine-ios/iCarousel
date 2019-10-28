//
//  PaymentModels.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 9/2/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

struct PaymentModel {
    let name: String
    let subtitle: String
    let types: [PaymentMethod]
}

struct PaymentMethod {
    let name: String
    let priceLabel: String
    let type: PaymentType
    let action: VoidHandler
}

enum PaymentType {
    case appStore
    case paycell
    case slcm
    
    var image: UIImage? {
        let imageName: String
        switch self {
        case .appStore:
            imageName = "payment_app_store"
        case .paycell:
            imageName = "payment_paycell"
        case .slcm:
            imageName = "payment_slcm"
        }
        return UIImage(named: imageName)
    }
    
    var title: String {
        let title: String
        switch self {
        case .appStore:
            title = TextConstants.paymentTitleAppStore
        case .paycell:
            title = TextConstants.paymentTitleCreditCard
        case .slcm:
            title = TextConstants.paymentTitleInvoice
        }
        return title
    }
    
    func quotaPaymentType(quota: String) -> GAEventLabel.QuotaPaymentType {
        let type: GAEventLabel.QuotaPaymentType
        switch self {
        case .appStore:
            type = .appStore(quota)
        case .paycell:
            type = .creditCard(quota)
        case .slcm:
            type = .chargeToBill(quota)
        }
        
        return type
    }
}
