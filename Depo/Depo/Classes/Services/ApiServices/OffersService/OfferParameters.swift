//
//  OfferParameters.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation


private struct OfferPath {
    static let offers = "/api/account/offers"
    static let activateOffer = "/api/account/activateOffer"
    static let allAccessOffers = "/api/account/allAccessOffers/APPLE"
    static let validateApplePurchase = "/api/inapppurchase/apple/validatePurchase"
}

class OfferAllParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: OfferPath.offers, relativeTo: super.patch)!
    }
}

class OfferAtivateParameters: BaseRequestParametrs {
    
    let offer: OfferServiceResponse
    
    init(offer: OfferServiceResponse) {
        self.offer = offer
    }
    
    override var patch: URL {
        return URL(string: OfferPath.activateOffer, relativeTo: super.patch)!
    }
    
    override var requestParametrs: Any {
        return offer.getJson()
    }
}

class OfferAllAppleParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: OfferPath.allAccessOffers, relativeTo: super.patch)!
    }
}

class ValidateApplePurchaseParameters: BaseRequestParametrs {
    
    let receiptId: String
    let productId: String?
    
    init(receiptId: String, productId: String? = nil) {
        self.receiptId = receiptId
        self.productId = productId
    }
    
    override var patch: URL {
        return URL(string: OfferPath.validateApplePurchase, relativeTo: super.patch)!
    }
    
    override var requestParametrs: Any {
        if let productId = productId {
            return ["receiptId": receiptId,
                    "productId": productId]
        }
        return ["receiptId": receiptId]
    }
}
