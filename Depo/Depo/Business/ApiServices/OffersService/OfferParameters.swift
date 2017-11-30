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
    
    static let initOffer = "/api/account/initOfferPurchase"
    static let verifyOffer = "/api/account/verifyOfferPurchase"
    
    static let jobExists = "/api/account/isSubscriptionJobExists"
    
    static let submitPromocode = "/api/account/verifyOfferPurchase"
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

final class InitOfferParameters: BaseRequestParametrs {
    
    let offerId: String
    
    init(offerId: String) {
        self.offerId = offerId
    }
    
    override var patch: URL {
        return URL(string: OfferPath.initOffer, relativeTo: super.patch)!
    }
    
    override var requestParametrs: Any {
        return offerId
    }
}

final class VerifyOfferParameters: BaseRequestParametrs {
    
    let otp: String
    let referenceToken: String
    
    init(otp: String, referenceToken: String) {
        self.otp = otp
        self.referenceToken = referenceToken
    }
    
    override var patch: URL {
        return URL(string: OfferPath.verifyOffer, relativeTo: super.patch)!
    }
    
    override var requestParametrs: Any {
        return ["otp": otp,
                "referenceToken": referenceToken]
    }
}

final class JobExistsParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: OfferPath.jobExists, relativeTo: super.patch)!
    }
}

final class SubmitPromocodeParameters: BaseRequestParametrs {
    
    let promocode: String
    
    init(promocode: String) {
        self.promocode = promocode
    }
    
    override var patch: URL {
        return URL(string: OfferPath.submitPromocode, relativeTo: super.patch)!
    }
    
    override var requestParametrs: Any {
        return ["promocode": promocode]
    }
}
