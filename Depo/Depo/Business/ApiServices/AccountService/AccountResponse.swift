//
//  AccountResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/22/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

struct AccountJSONConstants {
    
    static let mobileUploadsSpecialFolderUuid = "mobileUploadsSpecialFolderUuid"
    static let isCropyTagAvailable = "isCropyTagAvailable"
    static let isFavouriteTagAvailable = "isFavouriteTagAvailable"
    static let cellografId = "cellografId"
    static let name = "name"
    static let surname = "surname"
    static let birthday = "birthday"
    static let accountType = "accountType"
    static let language = "language"
    static let countryCode = "countryCode"
    static let phoneNumber = "phoneNumber"
    static let email = "email"
    static let emailVerified = "emailVerified"
    static let username = "username"
    static let url = "url"
    static let otp = "otp"
    static let referenceToken = "referenceToken"
    static let gapID = "gapId"
    
    static let quotaBytes = "quotaBytes"
    static let quotaExceeded = "quotaExceeded"
    static let quotaCount = "quotaCount"
    static let bytesUsed = "bytesUsed"
    static let objectCount = "objectCount"
    static let projectID = "projectId"
    
    static let securitySettingsTurkcellPassword = "turkcellPasswordAuthEnabled"
    static let securitySettingsMobileNetwor = "mobileNetworkAuthEnabled"
}

class AccountInfoResponse: ObjectRequestResponse {
    
    var mobileUploadsSpecialFolderUuid: String?
    var isCropyTagAvailable: Bool?
    var isFavouriteTagAvailable: Bool?
    var cellografId: String?
    var name: String?
    var surname: String?
    var accountType: String?
    var language: String?
    var countryCode: String?
    var phoneNumber: String?
    var email: String?
    var emailVerified: Bool?
    var username: String?
    var dob: String?
    var urlForPhoto: URL?
    var projectID: String?
    var gapId: String?
    
    var fullPhoneNumber: String {
        if let code = countryCode, let number = phoneNumber {
            return "+\(code)\(number)"
        }
        return ""
    }
    
    override func mapping() {
        mobileUploadsSpecialFolderUuid = json?[AccountJSONConstants.mobileUploadsSpecialFolderUuid].string
        isCropyTagAvailable = json?[AccountJSONConstants.isCropyTagAvailable].bool
        isFavouriteTagAvailable = json?[AccountJSONConstants.isFavouriteTagAvailable].bool
        cellografId = json?[AccountJSONConstants.cellografId].string
        name = json?[AccountJSONConstants.name].string
        gapId = json?[AccountJSONConstants.gapID].string
        
        ///---changed due difficulties with complicated names(such as names that contain more than 2 words). Now we are using same behaviour as android client
        if let actualSurNaame = json?[AccountJSONConstants.surname].string,
                !actualSurNaame.isEmpty {
            name = (name ?? "") + " " + actualSurNaame
        }
        surname = ""
        ///---
        
        username = json?[AccountJSONConstants.username].string
        dob = json?[AccountJSONConstants.birthday].string
        accountType = json?[AccountJSONConstants.accountType].string
        language = json?[AccountJSONConstants.language].string
        countryCode = json?[AccountJSONConstants.countryCode].string
        phoneNumber = json?[AccountJSONConstants.phoneNumber].string
        email = json?[AccountJSONConstants.email].string
        emailVerified = json?[AccountJSONConstants.emailVerified].bool
        urlForPhoto = json?[AccountJSONConstants.url].url
        projectID = json?[AccountJSONConstants.projectID].string
    }
}

class SecuritySettingsInfoResponse: ObjectRequestResponse {
    var turkcellPasswordAuthEnabled: Bool?
    var mobileNetworkAuthEnabled: Bool?
    
    override func mapping() {
        turkcellPasswordAuthEnabled = json?[AccountJSONConstants.securitySettingsTurkcellPassword].bool
        mobileNetworkAuthEnabled = json?[AccountJSONConstants.securitySettingsMobileNetwor].bool
    }
    
}

class FaceImageAllowedResponse: ObjectRequestResponse {
    var allowed: Bool?
    
    override func mapping() {
        allowed = json?.bool
    }
}

class QuotaInfoResponse: ObjectRequestResponse {
    
    var bytes: Int64?
    var bytesUsed: Int64?
    var exceeded: Bool?
    var objectsCount: Int64?
    
    override func mapping() {
        if let buf1 = json?[AccountJSONConstants.quotaBytes].string {
            bytes = Int64(buf1)
        }
        if let buf2 = json?[AccountJSONConstants.bytesUsed].string {
            bytesUsed = Int64(buf2)
        }
        exceeded = json?[AccountJSONConstants.quotaExceeded].bool
        if let buf3 = json?[AccountJSONConstants.objectCount].int64 {
            objectsCount = Int64(buf3)
        }
    }
}

class LanguageListResponse: ObjectRequestResponse {
    override func mapping() {
    }
}


class UserPhoto: BaseRequestParametrs {
    let photo: Data?
    
    init(photo: Data? = nil) {
        self.photo = photo
    }
    
    override var requestParametrs: Any {
        return photo ?? Data()
    }
    
    override var patch: URL {
        return URL(string: AccountPath.profilePhoto, relativeTo: super.patch)!
    }
}

class UserPhotoResponse: ObjectRequestResponse {
    override func mapping() {
        
    }
}

class UsageResponse: ObjectRequestResponse {
    
    private struct UsageResponseKeys {
        static let base = "storageUsage"
        
        static let totalUsage = "totalUsage"
        static let imageUsage = "imageUsage"
        static let videoUsage = "videoUsage"
        static let audioUsage = "audioUsage"
        static let othersUsage = "othersUsage"
        static let quotaBytes = "Quota-Bytes"
        static let usedBytes = "Bytes-Used"
        
        static let totalFileCount = "totalFileCount"
        static let folderCount = "folderCount"
        static let imageCount = "imageCount"
        static let videoCount = "videoCount"
        static let audioCount = "audioCount"
        static let othersCount = "othersCount"
        static let objectCount = "Object-Count"
        
        static let internetDataUsage = "internetDataUsage"
    }
    
    var totalUsage: Int64?
    var imageUsage: Int64?
    var videoUsage: Int64?
    var audioUsage: Int64?
    var othersUsage: Int64?
    var quotaBytes: Int64?
    var usedBytes: Int64?
    
    var totalFileCount: Int?
    var folderCount: Int?
    var imageCount: Int?
    var videoCount: Int?
    var audioCount: Int?
    var othersCount: Int?
    var objectCount: Int?
    
    var internetDataUsage: [InternetDataUsage] = []
    
    override func mapping() {
        let storageUsage = json?[UsageResponseKeys.base]
        
        totalUsage = storageUsage?[UsageResponseKeys.totalUsage].int64
        imageUsage = storageUsage?[UsageResponseKeys.imageUsage].int64
        videoUsage = storageUsage?[UsageResponseKeys.videoUsage].int64
        audioUsage = storageUsage?[UsageResponseKeys.audioUsage].int64
        othersUsage = storageUsage?[UsageResponseKeys.othersUsage].int64
        quotaBytes = storageUsage?[UsageResponseKeys.quotaBytes].string?.int64
        usedBytes = storageUsage?[UsageResponseKeys.usedBytes].string?.int64
        
        totalFileCount = storageUsage?[UsageResponseKeys.totalFileCount].int
        folderCount = storageUsage?[UsageResponseKeys.folderCount].int
        imageCount = storageUsage?[UsageResponseKeys.imageCount].int
        videoCount = storageUsage?[UsageResponseKeys.videoCount].int
        audioCount = storageUsage?[UsageResponseKeys.audioCount].int
        othersCount = storageUsage?[UsageResponseKeys.othersCount].int
        objectCount = storageUsage?[UsageResponseKeys.objectCount].string?.int
        
        let internetDataUsageJsonArray = json?[UsageResponseKeys.internetDataUsage].array
        if let tmpList = internetDataUsageJsonArray?.flatMap({ InternetDataUsage(withJSON: $0) }) {
            internetDataUsage = tmpList
        }
    }
}

final class PermissionsResponse: ObjectRequestResponse {

    var permissions: [PermissionResponse]?
    
    func hasPermissionFor(_ type: PermissionResponse.AuthorityType) -> Bool {
        let hasPermission = permissions?.contains(where: { $0.type == type })
        return hasPermission ?? false
    }

    override func mapping() {
        let permissionsJsonArray = json?.array
        if let permissionList = permissionsJsonArray?.flatMap({ PermissionResponse.init(withJSON: $0) }) {
            permissions = permissionList
        }
    }
}

final class PermissionResponse: ObjectRequestResponse {
    
    enum AuthorityType: String {
        case faceRecognition    = "AUTH_FACE_IMAGE_LOCATION"
        case deleteDublicate    = "AUTH_DELETE_DUPLICATE"
        case premiumUser        = "AUTH_PREMIUM_USER"
    }
    
    private enum ResponseKeys {
        static let type = "type"
    }
    
    var type: AuthorityType?
    
    
    override func mapping() {
        let typeString = json?[ResponseKeys.type].string
        if let string = typeString, let type = AuthorityType(rawValue: string) {
            self.type = type
        }
    }
}

final class FeaturePacksResponse: ObjectRequestResponse {
    var packs: [PackageModelResponse]?

    override func mapping() {
        let packsJsonArray = json?.array
        if let packsList = packsJsonArray?.flatMap({ PackageModelResponse.init(withJSON: $0) }) {
            packs = packsList
        }
    }
}

final class PackageModelResponse: ObjectRequestResponse {
    enum PackageType: String {
        
        static let allFeatures: [PackageType] = [appleFeature, SLCMFeature, SLCMPaycellFeature, googleFeature,
                                                 freeOfChargeFeature, freeOfChargeFeature, lifeCellFeature, promoFeature,
                                                 KKTCellFeature, MoldCellFeature, lifeFeature, KKTCellFeature, MoldCellFeature,
                                                 lifeFeature, paycellAllAccessFeature, paycellSLCMFeature, allAccessPaycellFeature]
        
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
        
        var isFeature: Bool {
            return PackageType.allFeatures.contains(self)
        }
        
        var cancelText: String {
            switch self {
            case .apple:
                return "apple subscription cancel text"
            case .SLCM:
                return "SLCM subscription cancel text"
            case .google:
                return "google subscription cancel text"
            case .freeOfCharge:
                return "freeOfCharge subscription cancel text"
            case .lifeCell:
                return "lifeCell subscription cancel text"
            case .promo:
                return "promo subscription cancel text"
            case .KKTCell:
                return "KKTCell subscription cancel text"
            case .MoldCell:
                return "MoldCell subscription cancel text"
            case .life:
                return "life subscription cancel text"
            case .paycellAllAccess:
                return "paycellAllAccess subscription cancel text"
            case .paycellSLCM:
                return "paycellSLCM subscription cancel text"
            default:
                return "common subscription cancel text"
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
    var quota: Int64?
    var status: PackageStatus?
    var authorities: [PackagePackAuthoritiesResponse]?

    override func mapping() {
        name = json?[ResponseKeys.name].string
        currency = json?[ResponseKeys.currency].string
        displayName = json?[ResponseKeys.displayName].string
        offerDescription = json?[ResponseKeys.offerDescription].string
        price = json?[ResponseKeys.price].float
        isDefault = json?[ResponseKeys.isDefault].bool
        role = json?[ResponseKeys.role].string
        slcmOfferId = json?[ResponseKeys.slcmOfferId].int
        cometOfferId = json?[ResponseKeys.cometOfferId].int
        cpcmOfferId = json?[ResponseKeys.cpcmOfferId].int
        offerProductId = json?[ResponseKeys.offerProductId].int
        inAppPurchaseId = json?[ResponseKeys.inAppPurchaseId].string
        period = json?[ResponseKeys.period].string
        quota = json?[ResponseKeys.quota].int64
        if let typeString = json?[ResponseKeys.type].string {
            type = PackageType(rawValue: typeString)
        }
        if let statusString = json?[ResponseKeys.status].string {
            status = PackageStatus(rawValue: statusString)
        }
        let authoritiesJsonArray = json?[ResponseKeys.authorities].array
        if let authoritiesList = authoritiesJsonArray?.flatMap({ PackagePackAuthoritiesResponse.init(withJSON: $0) }) {
            authorities = authoritiesList
        }
    }
}

final class PackagePackAuthoritiesResponse: ObjectRequestResponse {
    
    enum AuthorityType: String {
        case faceRecognition    = "AUTH_FACE_IMAGE_LOCATION"
        case deleteDublicate    = "AUTH_DELETE_DUPLICATE"
        case premiumUser        = "AUTH_PREMIUM_USER"
    }
    
    private enum ResponseKey {
        static let authorityType = "authorityType"
    }
    
    var authorityType: AuthorityType?

    override func mapping() {
        if let typeString = json?[ResponseKey.authorityType].string {
            authorityType = AuthorityType(rawValue: typeString)
        }
    }
}

final class AvailableOffersResponse: ObjectRequestResponse {
    var offers: [PackageModelResponse]?

    override func mapping() {
        let packsJsonArray = json?.array
        if let packsList = packsJsonArray?.flatMap({ PackageModelResponse.init(withJSON: $0) }) {
            offers = packsList
        }
    }
}

class InternetDataUsage: ObjectRequestResponse {
    
    private struct InternetDataUsageKeys {
        static let offerName = "offerName"
        static let total = "total"
        static let remaining = "remaining"
        static let unit = "unit"
        static let expiryDate = "expiryDate"
    }
    
    var offerName: String?
    var total: Double?
    var remaining: Double?
    var unit: BytesType?
    var expiryDate: Date?
    
    var totalString: String {
        return sizeString(for: total)
    }
    
    var remainingString: String {
        return sizeString(for: remaining)
    }
    
    private func sizeString(for size: Double?) -> String {
        guard let unit = self.unit, let size = size else {
            return ""
        }
        switch unit {
        case .mb:
            return cleanZero(for: size / BytesType.size, unit: "GB")
        }
    }
    
    private func cleanZero(for value: Double, unit: String) -> String {
        let isDisplayFloat = value.truncatingRemainder(dividingBy: 1) != 0
        let numberOfDigits = isDisplayFloat ? 1 : 0
        return String(format: "%.\(numberOfDigits)f \(unit)", value)
        // value.truncatingRemainder(dividingBy: 1) == 0 ? String(value) : String(format: "%.1f \(unit)", value)
    }
    
    override func mapping() {
        offerName = json?[InternetDataUsageKeys.offerName].string
        total = json?[InternetDataUsageKeys.total].double
        remaining = json?[InternetDataUsageKeys.remaining].double
        unit = json?[InternetDataUsageKeys.unit].bytesType
        expiryDate = json?[InternetDataUsageKeys.expiryDate].date
    }
}

/// MAYBE WILL BE USED
//class InternetDataUsageResponse: ObjectRequestResponse {
//
//    private struct InternetDataUsageKeys {
//        static let expiryDate = "expiryDate"
//        static let offerName = "offerName"
//        static let remaining = "remaining"
//        static let total = "total"
//        static let unit = "unit"
//    }
//
//    var expiryDate: Date?
//    var offerName: String?
//    var remaining: Int64?
//    var total: Int64?
//    var unit: String?
//
//    override func mapping() {
//        expiryDate = json?[InternetDataUsageKeys.expiryDate].date
//        offerName = json?[InternetDataUsageKeys.offerName].string
//        remaining = json?[InternetDataUsageKeys.remaining].int64
//        total = json?[InternetDataUsageKeys.total].int64
//        unit = json?[InternetDataUsageKeys.unit].string
//    }
//}
