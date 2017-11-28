//
//  OfferServiceResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

class OfferServiceResponse: ObjectRequestResponse {
    
    struct OfferAllConstants {
        static let offerId = "aeOfferId"
        static let name = "aeOfferName"
        static let campaignChannel = "campaignChannel"
        static let campaignCode = "campaignCode"
        static let campaignId = "campaignId"
        static let campaignUserCode = "campaignUserCode"
        static let cometParameters = "cometParameters"
        static let responseApi = "responseApi"
        static let validationKey = "validationKey"
        static let price = "price"
        static let role = "role"
        static let quota = "quota"
        static let period = "period"
    }
    
    var offerId: Int64?
    var name: String?
    var campaignChannel: String?
    var campaignCode: String?
    var campaignId: String?
    var campaignUserCode: String?
    var cometParameters: String?
    var responseApi: Int?
    var validationKey: String?
    var price: Float?
    var role: String?
    var quota: Int64?
    var period: String?
    
    override func mapping() {
        offerId = json?[OfferAllConstants.offerId].int64
        name = json?[OfferAllConstants.name].string
        campaignChannel = json?[OfferAllConstants.campaignChannel].string
        campaignCode = json?[OfferAllConstants.campaignCode].string
        campaignId = json?[OfferAllConstants.campaignId].string
        campaignUserCode = json?[OfferAllConstants.campaignUserCode].string
        cometParameters = json?[OfferAllConstants.cometParameters].string
        responseApi = json?[OfferAllConstants.responseApi].int
        validationKey = json?[OfferAllConstants.validationKey].string
        price = json?[OfferAllConstants.price].float
        role = json?[OfferAllConstants.role].string
        quota = json?[OfferAllConstants.quota].int64
        period = json?[OfferAllConstants.period].string
    }
    
    func getJson() -> [String: Any] {
        return [
            OfferAllConstants.offerId: offerId ?? "",
            OfferAllConstants.name: name ?? "",
            OfferAllConstants.campaignChannel: campaignChannel ?? "",
            OfferAllConstants.campaignCode: campaignCode ?? "",
            OfferAllConstants.campaignId: campaignId ?? "",
            OfferAllConstants.campaignUserCode: campaignUserCode ?? "",
            OfferAllConstants.cometParameters: cometParameters ?? "",
            OfferAllConstants.responseApi: responseApi ?? "",
            OfferAllConstants.validationKey: validationKey ?? "",
            OfferAllConstants.price: price ?? 0,
            OfferAllConstants.role: role ?? "",
            OfferAllConstants.quota: quota ?? 0,
            OfferAllConstants.period: period ?? ""
        ]
    }
}

class OfferActivateServiceResponse: ObjectRequestResponse {
    
    var offer: String?
    
    override func mapping() {
        print(json ?? "json nil")
        offer = json?.string
    }
}

class OfferAllAppleServiceResponse: ObjectRequestResponse {
    
    var list: [String] = []
    
    override func mapping() {
        guard let tmpList = json?.array?.flatMap({ $0.string }) else { return }
        list = tmpList
    }
}

class OfferAllResponse: ObjectRequestResponse {
    
    var list: [OfferServiceResponse] = []
    
    override func mapping() {
        guard let tmpList = json?.array?.flatMap({ OfferServiceResponse(withJSON: $0) }) else { return }
        list = tmpList
    }
}

class ValidateApplePurchaseResponse: ObjectRequestResponse {
    
    var offer: String?
    
    override func mapping() {
        offer = json?.string
    }
}

final class InitOfferResponse: ObjectRequestResponse {
    
    struct InitOfferKeys {
        static let status = "status"
        static let value = "value"
    }
    
    var status: String?
    var value: String?
    
    override func mapping() {
        status = json?[InitOfferKeys.status].string ///"OK" - good
        value = json?[InitOfferKeys.value].string
    }
}

class VerifyOfferResponse: ObjectRequestResponse {
    
    var error: String?
    
    override func mapping() {
        error = json?.string
    }
}
