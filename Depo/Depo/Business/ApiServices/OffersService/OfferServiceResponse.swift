//
//  OfferServiceResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class OfferServiceResponse: ObjectRequestResponse {
    
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

final class OfferActivateServiceResponse: ObjectRequestResponse {
    
    var offer: String?
    
    override func mapping() {
        print(json ?? "json nil")
        offer = json?.string
    }
}

final class OfferAllAppleServiceResponse: ObjectRequestResponse {
    
    var list: [String] = []
    
    override func mapping() {
        guard let tmpList = json?.array?.compactMap({ $0.string }) else { return }
        list = tmpList
    }
}

final class OfferAllResponse: ObjectRequestResponse {
    
    var list: [OfferServiceResponse] = []
    
    override func mapping() {
        guard let tmpList = json?.array?.compactMap({ OfferServiceResponse(withJSON: $0) }) else { return }
        list = tmpList
    }
}

enum ValidatePurchaseType: String {
    case success = "SUCCESS"
    case invalid = "INVALID_SUBSCRIPTION"
    case temporaryError = "TEMPORARY_ERROR"
    case alreadySubscribed = "ALREADY_SUBSCRIBED_FOR_AN_ACCOUNT"
    case restored = "RESTORED"
    
    var description: String {
        switch self {
        case .success: return TextConstants.validatePurchaseSuccessText
        case .invalid: return TextConstants.validatePurchaseInvalidText
        case .temporaryError: return TextConstants.validatePurchaseTemporaryErrorText
        case .alreadySubscribed: return TextConstants.validatePurchaseAlreadySubscribedText
        case .restored: return TextConstants.validatePurchaseRestoredText
        }
    }
}

final class ValidateApplePurchaseResponse: ObjectRequestResponse {
    
    struct ValidateApplePurchaseConstants {
        static let status = "status"
        static let value = "value"
    }
    
    var status: ValidatePurchaseType?
    var value: String?
    
    override func mapping() {
        if let statusString = json?[ValidateApplePurchaseConstants.status].string {
            status = ValidatePurchaseType(rawValue: statusString)
        }
        value = json?[ValidateApplePurchaseConstants.value].string
    }
}

final class InitOfferResponse: ObjectRequestResponse {
    
    struct InitOfferKeys {
        static let status = "status"
        static let value = "value"
        static let referenceToken = "referenceToken"
    }
    
    var status: String?
    var referenceToken: String?
    
    override func mapping() {
        status = json?[InitOfferKeys.status].string ///"OK" - good
        referenceToken = json?[InitOfferKeys.value][InitOfferKeys.referenceToken].string
    }
}

//final class VerifyOfferResponse: ObjectRequestResponse {
//    
//    var error: String?
//    
//    override func mapping() {
//        error = json?.string
//    }
//}

final class JobExistsResponse: ObjectRequestResponse {
    
    var isJobExists: Bool?
    
    override func mapping() {
        isJobExists = json?["isJobExists"].bool
    }
}

final class SubmitPromocodeResponse: ObjectRequestResponse {
    
    var error: String?
    
    override func mapping() {
        error = json?.string
    }
}
