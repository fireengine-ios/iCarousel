//
//  OfferParameters.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation


private struct OfferPath {
    static let offers = "account/offers"
    static let activateOffer = "account/activateOffer"
    static let allAccessOffers = "account/allAccessOffers/APPLE"
    static let validateApplePurchase = "inapppurchase/apple/validatePurchase"
    
    static let initOffer = "account/initOfferPurchase"
    static let verifyOffer = "account/verifyOfferPurchase"
    
    static let jobExists = "account/isSubscriptionJobExists"
    
    static let submitPromocode = "https://mylifebox.com/api/promo/activate"
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
    let referer: String?
    
    init(receiptId: String, productId: String? = nil, referer: String? = nil) {
        self.receiptId = receiptId
        self.productId = productId
        self.referer   = referer
    }
    
    override var patch: URL {
        return URL(string: OfferPath.validateApplePurchase, relativeTo: super.patch)!
    }
    
    override var requestParametrs: Any {
        var params = ["receiptId": receiptId]
        
        if let productId = productId {
            params.updateValue(productId, forKey: "productId")
        }
        
        if let referer = referer {
            params.updateValue(referer, forKey: "referer")
        }
        
        return params
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
        return URL(string: OfferPath.submitPromocode)!
    }
    
    override var requestParametrs: Any {
        return promocode
    }
}
