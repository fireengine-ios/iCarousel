//
//  PackageModelResponse.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 12/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class PackageModelResponse: Equatable {
    static func == (lhs: PackageModelResponse, rhs: PackageModelResponse) -> Bool {
        return (lhs.quota ?? 0) > (rhs.quota ?? 0)
    }
    
    enum FeaturePackageType: String {
        case appleFeature               = "FEATURE_APPLE"
        case SLCMFeature                = "FEATURE_SLCM"
        case SLCMPaycellFeature         = "FEATURE_SLCM_PAYCELL"
        case googleFeature              = "FEATURE_GOOGLE"
        case freeOfChargeFeature        = "FEATURE_FREE_OF_CHARGE"
        case lifeCellFeature            = "FEATURE_LIFECELL"
        case promoFeature               = "FEATURE_PROMO"
        case KKTCellFeature             = "FEATURE_KKTCELL"
        case MoldCellFeature            = "FEATURE_MOLDCELL"
        case lifeFeature                = "FEATURE_LIFE"
        case paycellAllAccessFeature    = "FEATURE_PAYCELL_ALL_ACCESS"
        case paycellSLCMFeature         = "FEATURE_PAYCELL_SLCM"
        case allAccessPaycellFeature    = "FEATURE_ALL_ACCESS_PAYCELL"
    }
    
    enum PackageType: String {
        case apple                      = "APPLE"
        case SLCM                       = "SLCM"
        case google                     = "GOOGLE"
        case freeOfCharge               = "FREE_OF_CHARGE"
        case lifeCell                   = "LIFECELL"
        case promo                      = "PROMO"
        case KKTCell                    = "KKTCELL"
        case MoldCell                   = "MOLDCELL"
        case life                       = "LIFE"
        case paycellAllAccess           = "PAYCELL_ALL_ACCESS"
        case paycellSLCM                = "PAYCELL_SLCM"
        
        var cancelText: String {
            switch self {
            case .apple:
                return TextConstants.packageAppleCancelText
            case .SLCM:
                return TextConstants.packageSLCMCancelText
            case .google:
                return TextConstants.packageGoogleCancelText
            case .freeOfCharge:
                return TextConstants.packageFreeOfChargeCancelText
            case .lifeCell:
                return TextConstants.packageLifeCellCancelText
            case .promo:
                return TextConstants.packagePromoCancelText
            case .KKTCell:
                return TextConstants.packageKKTCellCancelText
            case .MoldCell:
                return TextConstants.packageMoldCellCancelText
            case .life:
                return TextConstants.packageLifeCancelText
            case .paycellAllAccess:
                return TextConstants.packagePaycellAllAccessCancelText
            case .paycellSLCM:
                return TextConstants.packagePaycellSLCMCancelText
            }
        }
    }
    
    enum PackageStatus: String {
        case enabled    = "ENABLED"
        case disabled   = "DISABLED"
    }
    
    private enum ResponseKeys {
        static let name = "name"
        static let currency = "currency"
        static let displayName = "displayName"
        static let offerDescription = "description"
        static let price = "price"
        static let isDefault = "isDefault"
        static let role = "role"
        static let slcmOfferId = "slcmOfferId"
        static let cometOfferId = "cometOfferId"
        static let offerProductId = "offerProductId"
        static let cpcmOfferId = "cpcmOfferId"
        static let inAppPurchaseId = "inAppPurchaseId"
        static let period = "period"
        static let type = "type"
        static let quota = "quota"
        static let status = "status"
        static let authorities = "authorities"
    }
    
    var name: String?
    var currency: String?
    var displayName: String?
    var offerDescription: String?
    var price: Float?
    var isDefault: Bool?
    var role: String?
    var slcmOfferId: Int?
    var cometOfferId: Int?
    var offerProductId: Int?
    var cpcmOfferId: Int?
    var inAppPurchaseId: String?
    var period: String?
    var type: PackageType?
    var featureType: FeaturePackageType?
    var quota: Int64?
    var status: PackageStatus?
    var authorities: [PackagePackAuthoritiesResponse]?
}

extension PackageModelResponse: Map {
    convenience init?(json: JSON) {
        self.init()
        
        name = json[ResponseKeys.name].string
        currency = json[ResponseKeys.currency].string
        displayName = json[ResponseKeys.displayName].string
        offerDescription = json[ResponseKeys.offerDescription].string
        price = json[ResponseKeys.price].float
        isDefault = json[ResponseKeys.isDefault].bool
        role = json[ResponseKeys.role].string
        slcmOfferId = json[ResponseKeys.slcmOfferId].int
        cometOfferId = json[ResponseKeys.cometOfferId].int
        cpcmOfferId = json[ResponseKeys.cpcmOfferId].int
        offerProductId = json[ResponseKeys.offerProductId].int
        inAppPurchaseId = json[ResponseKeys.inAppPurchaseId].string
        period = json[ResponseKeys.period].string
        quota = json[ResponseKeys.quota].int64
        
        if let typeString = json[ResponseKeys.type].string {
            //helps recognize type of the pack by checking for nil one of those vars
            type = PackageType(rawValue: typeString)
            featureType = FeaturePackageType(rawValue: typeString)
        }
        
        if let statusString = json[ResponseKeys.status].string {
            status = PackageStatus(rawValue: statusString)
        }
        
        let authoritiesJsonArray = json[ResponseKeys.authorities].array
        if let authoritiesList = authoritiesJsonArray?.flatMap({ PackagePackAuthoritiesResponse(withJSON: $0) }) {
            authorities = authoritiesList
        }
    }
}
