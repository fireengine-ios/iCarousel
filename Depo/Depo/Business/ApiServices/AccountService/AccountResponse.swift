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

    var permitions: [PermissionResponse]?

    override func mapping() {
        permitions = json?.arrayObject as? [PermissionResponse]
    }
    
    func hasPermissionFor(_ type: PermissionResponse.PackageType) -> Bool {
        var isGranted = false
        if let hasPermission = permitions?.contains(where: { $0.type == type }) {
            isGranted = hasPermission
        }
        return isGranted
    }
}

final class PermissionResponse: ObjectRequestResponse {
    
    enum PackageType: String {
        case none
        case faceRecognition    = "AUTH_FACE_IMAGE_LOCATION"
        case deleteDublicate    = "AUTH_DELETE_DUPLICATE"
        case premiumUser        = "AUTH_PREMIUM_USER"
        
        static func getPackageType(with key: String? = "") -> PackageType {
            switch key {
            case self.faceRecognition.rawValue: return self.faceRecognition
                
            case self.deleteDublicate.rawValue: return self.deleteDublicate
                
            case self.premiumUser.rawValue: return self.premiumUser
                
            default: return self.none
            }
        }
        
        func title() -> String {
            switch self {
                case .faceRecognition: return TextConstants.faceRecognitionTitle
                
                case .deleteDublicate: return TextConstants.deleteDuplicatedTitle
                
                default: return ""
            }
        }
        
        enum FeatureType: String {
            case none
            case apple  = "FEATURE_APPLE"
            case slcm   = "FEATURE_SLCM"
            
            static func getPackageType(with key: String? = "") -> FeatureType {
                switch key {
                    case apple.rawValue: return self.apple
                    
                    case slcm.rawValue: return self.slcm
                    
                    default: return self.none
                }
            }
        }
        
        enum AuthorityType: String {
            case none
            case premium  = "AUTH_PREMIUM_USER"
            case standart   = "AUTH_STANDART_USER"
            
            static func getPackageType(with key: String? = "") -> AuthorityType {
                switch key {
                    case premium.rawValue: return self.premium
                    
                    case standart.rawValue: return self.standart
                    
                    default: return self.none
                }
            }
        }
    }
    
    private struct PermissionResponseKeys {
        static let type = "type"
    }
    
    var type: PackageType?
    
    
    override func mapping() {
        let typeString = json?[PermissionResponseKeys.type].string
        type = PackageType.getPackageType(with: typeString)
    }
}

final class FeaturePacksResponse: ObjectRequestResponse {

    private struct FeaturePacksResponseKeys {
        static let name = "name"
        static let displayName = "displayName"
        static let price = "price"
        static let currency = "currency"
        static let slcmOfferId = "slcmOfferId"
        static let cometOfferId = "cometOfferId"
        static let quota = "quota"
        static let status = "status"
        static let details = "details"
        static let type = "type"
    }

    var name: String?
    var displayName: String?
    var price: Float?
    var currency: String?
    var slcmOfferId: Int?
    var cometOfferId: Int?
    var quota: Int64?
    var status: String?
    var details: [FeaturePacksDetailsResponse]?
    var type: String?

    override func mapping() {
        name = json?[FeaturePacksResponseKeys.name].string
        displayName = json?[FeaturePacksResponseKeys.displayName].string
        price = json?[FeaturePacksResponseKeys.price].float
        currency = json?[FeaturePacksResponseKeys.currency].string
        slcmOfferId = json?[FeaturePacksResponseKeys.slcmOfferId].int
        cometOfferId = json?[FeaturePacksResponseKeys.cometOfferId].int
        quota = json?[FeaturePacksResponseKeys.quota].int64
        status = json?[FeaturePacksResponseKeys.status].string
        if let detailsArray = json?[FeaturePacksResponseKeys.details].arrayObject as? [FeaturePacksDetailsResponse] {
            details = detailsArray
        }
        type = json?[FeaturePacksResponseKeys.type].string
    }
}

final class FeaturePacksDetailsResponse: ObjectRequestResponse {
    
    private struct FeaturePacksDetailsResponseKeys {
        static let authorityType = "authorityType"
    }
    
    var authorityType: String?

    override func mapping() {
        authorityType = json?[FeaturePacksDetailsResponseKeys.authorityType].string
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
