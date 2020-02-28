//
//  PackageModelResponse.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 12/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    case allAccessFeature           = "FEATURE_ALL_ACCESS"
    case paycellSLCMFeature         = "FEATURE_PAYCELL_SLCM"
    case allAccessPaycellFeature    = "FEATURE_ALL_ACCESS_PAYCELL"
    case digicellFeature            = "DIGICELL-FEATURE"

    var cancelText: String {
        switch self {
        case .appleFeature:
            return TextConstants.featureAppleCancelText
        case .SLCMFeature:
            return TextConstants.featureSLCMCancelText
        case .googleFeature:
            return TextConstants.featureGoogleCancelText
        case .paycellAllAccessFeature:
            return TextConstants.featurePaycellAllAccessCancelText
        case .SLCMPaycellFeature:
            return TextConstants.featureSLCMPaycellCancelText
        case .freeOfChargeFeature:
            return TextConstants.featureFreeOfChargeCancelText
        case .lifeCellFeature:
            return TextConstants.featureLifeCellCancelText
        case .promoFeature:
            return TextConstants.featurePromoCancelText
        case .KKTCellFeature:
            return TextConstants.featureKKTCellCancelText
        case .MoldCellFeature:
            return TextConstants.featureMoldCellCancelText
        case .lifeFeature:
            return TextConstants.featureLifeCancelText
        case .allAccessFeature:
            return TextConstants.featureDefaultCancelText
        case .paycellSLCMFeature:
            return TextConstants.featurePaycellSLCMCancelText
        case .allAccessPaycellFeature:
            return TextConstants.featureAllAccessPaycellCancelText
        case .digicellFeature:
            return TextConstants.featureDigicellCancelText
        }
    }
    
    var paymentType: PaymentType {
        switch self {
        case .appleFeature:
            return .appStore
        case .SLCMFeature:
            return .slcm
        case .SLCMPaycellFeature, .paycellAllAccessFeature:
            return .paycell
        default:
            assertionFailure()
            return .appStore
        }
    }
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
    case albanian                   = "ALBTELECOM"
    case FWI                        = "DIGICELL_FWI"
    case jamaica                    = "DIGICELL_JAMAICA"

    var cancelText: String {
        switch self {
        case .apple:
            return TextConstants.offersAllCancel
        case .SLCM:
            return TextConstants.offersCancelTurkcell
        case .google:
            return TextConstants.packageGoogleCancelText
        case .freeOfCharge:
            return TextConstants.packageFreeOfChargeCancelText
        case .lifeCell:
            return TextConstants.offersCancelUkranian
        case .promo:
            return TextConstants.packagePromoCancelText
        case .KKTCell:
            return TextConstants.offersCancelCyprus
        case .MoldCell:
            return TextConstants.offersCancelMoldcell
        case .life:
            return TextConstants.offersCancelLife
        case .paycellAllAccess:
            return TextConstants.packagePaycellAllAccessCancelText
        case .paycellSLCM:
            return TextConstants.packagePaycellSLCMCancelText
        case .albanian:
            return TextConstants.packageAlbanianCancelText
        case .FWI:
            return TextConstants.packageFWICancelText
        case .jamaica:
            return TextConstants.packageJamaicaCancelText
        }
    }
    
    var paymentType: PaymentType {
        switch self {
            case .apple:
                return .appStore
            case .SLCM:
                return .slcm
            case .paycellSLCM:
                return .paycell
            case .paycellAllAccess:
                return .paycell
            default:
                return .appStore
        }
    }
}

final class PackageModelResponse: Equatable {
    static func == (lhs: PackageModelResponse, rhs: PackageModelResponse) -> Bool {
        return (lhs.quota ?? 0) > (rhs.quota ?? 0)
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
        static let recommended = "recommended"
        static let hasAttachedFeature = "hasAttachedFeature"
        static let isFeaturePack = "isFeaturePack"
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
    var isRecommended: Bool?
    var hasAttachedFeature: Bool?
    var isFeaturePack: Bool?
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
        
        isRecommended = json[ResponseKeys.recommended].bool
        hasAttachedFeature = json[ResponseKeys.hasAttachedFeature].bool
        isFeaturePack = json[ResponseKeys.isFeaturePack].bool
    }
}
