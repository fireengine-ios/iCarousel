//
//  AccountResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/22/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

struct AccountJSONConstants {
    
    static let mobileUploadsSpecialFolderUuid = "mobileUploadsSpecialFolderUuid"
    static let isCropyTagAvailable = "isCropyTagAvailable"
    static let isFavouriteTagAvailable = "isFavouriteTagAvailable"
    static let isUpdateInformationRequired = "isUpdateInformationRequired"
    static let hasSecurityQuestionInfo = "hasSecurityQuestionInfo"
    static let securityQuestionId = "securityQuestionId"
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
    static let recoveryEmail = "recoveryEmail"
    static let recoveryEmailVerified = "isRecoveryEmailVerified"
    static let username = "username"
    static let url = "url"
    static let otp = "otp"
    static let referenceToken = "referenceToken"
    static let gapID = "gapId"
    static let isUpdateMobilePaymentPermissionRequired = "isUpdateMobilePaymentPermissionRequired"
    
    static let quotaBytes = "quotaBytes"
    static let quotaExceeded = "quotaExceeded"
    static let quotaCount = "quotaCount"
    static let bytesUsed = "bytesUsed"
    static let objectCount = "objectCount"
    static let projectID = "projectId"
    
    static let emailVerificationRemainingDays = "emailVerificationRemainingDays"
    static let recoveryEmailVerificationRemainingDays = "recoveryEmailVerificationRemainingDays"
    static let address = "address"
    
    static let securitySettingsTurkcellPassword = "turkcellPasswordAuthEnabled"
    static let securitySettingsMobileNetwor = "mobileNetworkAuthEnabled"
    static let twoFactorAuthEnabled = "twoFactorAuthEnabled"
    static let msisdnRegion = "msisdnRegion"
    static let showInvitation = "showInvitation"
    static let hasRecoveryMail = "hasRecoveryMailInfo"
    static let showPaycell = "showPaycell"
    
    
    static let photoPrintPackage = "photoPrintPackage"
    static let photoPrintSendRemaining = "photoPrintSendRemaining"
    static let photoPrintMaxSelection = "photoPrintMaxSelection"
}

class AccountInfoResponse: ObjectRequestResponse {
    
    var mobileUploadsSpecialFolderUuid: String?
    var isCropyTagAvailable: Bool?
    var isFavouriteTagAvailable: Bool?
    var isUpdateInformationRequired: Bool?
    var cellografId: String?
    var hasSecurityQuestionInfo: Bool?
    var securityQuestionId: Int?
    var name: String?
    var surname: String?
    var accountType: String?
    var language: String?
    var countryCode: String?
    var phoneNumber: String?
    var email: String?
    var emailVerified: Bool?
    var recoveryEmail: String?
    var recoveryEmailVerified: Bool?
    var username: String?
    var dob: String?
    var urlForPhoto: URL?
    var projectID: String?
    var gapId: String?
    var address: String?
    var emailVerificationRemainingDays: Int?
    var recoveryEmailVerificationRemainingDays: Int?
    var isUpdateMobilePaymentPermissionRequired: Bool?
    var msisdnRegion: String?
    var showInvitation: Bool?
    var hasRecoveryMail: Bool?
    var showPaycell: Bool?
    var photoPrintPackage: Bool?
    var photoPrintSendRemaining: Int?
    var photoPrintMaxSelection: Int?

    var fullPhoneNumber: String {
        if let code = countryCode, let number = phoneNumber {
            return number.contains("+") ? number : "+\(code)\(number)"
        }
        return ""
    }
    
    var isTurkcellUser: Bool {
        return accountType == "TURKCELL"
    }
    
    var isUserFromTurkey: Bool {
        return countryCode == "90"
    }
    
    override func mapping() {
        mobileUploadsSpecialFolderUuid = json?[AccountJSONConstants.mobileUploadsSpecialFolderUuid].string
        isCropyTagAvailable = json?[AccountJSONConstants.isCropyTagAvailable].bool
        isFavouriteTagAvailable = json?[AccountJSONConstants.isFavouriteTagAvailable].bool
        isUpdateInformationRequired = json?[AccountJSONConstants.isUpdateInformationRequired].bool
        cellografId = json?[AccountJSONConstants.cellografId].string
        hasSecurityQuestionInfo = json?[AccountJSONConstants.hasSecurityQuestionInfo].bool
        securityQuestionId = json?[AccountJSONConstants.securityQuestionId].int
        name = json?[AccountJSONConstants.name].string
        gapId = json?[AccountJSONConstants.gapID].string
        surname = json?[AccountJSONConstants.surname].string
        username = json?[AccountJSONConstants.username].string
        dob = json?[AccountJSONConstants.birthday].string
        accountType = json?[AccountJSONConstants.accountType].string
        language = json?[AccountJSONConstants.language].string
        countryCode = json?[AccountJSONConstants.countryCode].string
        phoneNumber = json?[AccountJSONConstants.phoneNumber].string
        email = json?[AccountJSONConstants.email].string
        emailVerified = json?[AccountJSONConstants.emailVerified].bool
        recoveryEmail = json?[AccountJSONConstants.recoveryEmail].string
        recoveryEmailVerified = json?[AccountJSONConstants.recoveryEmailVerified].bool
        urlForPhoto = json?[AccountJSONConstants.url].url
        projectID = json?[AccountJSONConstants.projectID].string
        emailVerificationRemainingDays = json?[AccountJSONConstants.emailVerificationRemainingDays].int
        recoveryEmailVerificationRemainingDays = json?[AccountJSONConstants.recoveryEmailVerificationRemainingDays].int
        address = json?[AccountJSONConstants.address].string
        isUpdateMobilePaymentPermissionRequired = json?[AccountJSONConstants.isUpdateMobilePaymentPermissionRequired].bool
        msisdnRegion = json?[AccountJSONConstants.msisdnRegion].string
        showInvitation = json?[AccountJSONConstants.showInvitation].bool
        hasRecoveryMail = json?[AccountJSONConstants.hasRecoveryMail].bool
        showPaycell = json?[AccountJSONConstants.showPaycell].bool
        photoPrintPackage = json?[AccountJSONConstants.photoPrintPackage].bool
        photoPrintSendRemaining = json?[AccountJSONConstants.photoPrintSendRemaining].int
        photoPrintMaxSelection = json?[AccountJSONConstants.photoPrintMaxSelection].int
    }
}

class SecuritySettingsInfoResponse: ObjectRequestResponse {
    var turkcellPasswordAuthEnabled: Bool?
    var mobileNetworkAuthEnabled: Bool?
    var twoFactorAuthEnabled: Bool?
    
    override func mapping() {
        turkcellPasswordAuthEnabled = json?[AccountJSONConstants.securitySettingsTurkcellPassword].bool
        mobileNetworkAuthEnabled = json?[AccountJSONConstants.securitySettingsMobileNetwor].bool
        twoFactorAuthEnabled = json?[AccountJSONConstants.twoFactorAuthEnabled].bool
    }
    
}

enum SettingsInfoPermissionsJsonKeys {
    static let faceImage = "faceImageRecognitionAllowed"
    static let faceImageStatus = "faceImageRecognitionAllowedStatus"
    static let facebook = "facebookTaggingEnabled"
    static let facebookStatus = "facebookTaggingEnabledStatus"
    static let instapick = "instapickAllowed"
}

final class SettingsInfoPermissionsResponse: ObjectRequestResponse {
    
    var isFaceImageAllowed: Bool?
    var isFaceImageRecognitionAllowedStatus: Bool?
    var isFacebookAllowed: Bool?
    var isFacebookTaggingEnabledStatus: Bool?
    var isInstapickAllowed: Bool?
    
    private let jsonStatusOK = "OK"
    
    override func mapping() {
        isFaceImageAllowed = json?[SettingsInfoPermissionsJsonKeys.faceImage].bool
        isFaceImageRecognitionAllowedStatus = json?[SettingsInfoPermissionsJsonKeys.faceImageStatus].string == jsonStatusOK ? true : false
        isFacebookAllowed = json?[SettingsInfoPermissionsJsonKeys.facebook].bool
        isFacebookTaggingEnabledStatus = json?[SettingsInfoPermissionsJsonKeys.facebookStatus].string == jsonStatusOK ? true : false
        isInstapickAllowed = json?[SettingsInfoPermissionsJsonKeys.instapick].bool
    }
}

final class SettingsPermissionsResponse: ObjectRequestResponse {

    var type: PermissionType?
    var eulaURL: String?
    var isEulaApproved: Bool?
    var isAllowed: Bool?
    var isApproved: Bool?
    var isApprovalPending: Bool?
    
    private enum ResponseKeys {
        static let type = "type"
        static let eulaURL = "eulaURL"
        static let isEulaApproved = "eulaApproved"
        static let isAllowed = "allowed"
        static let isApproved = "approved"
        static let isApprovalPending = "approvalPending"
    }
    
    override func mapping() {
        guard let typeString = json?[ResponseKeys.type].string else {
            return
        }
        
        type = PermissionType(rawValue: typeString)
        eulaURL = json?[ResponseKeys.eulaURL].string
        isEulaApproved = json?[ResponseKeys.isEulaApproved].bool
        isAllowed = json?[ResponseKeys.isAllowed].bool
        isApproved = json?[ResponseKeys.isApproved].bool
        isApprovalPending = json?[ResponseKeys.isApprovalPending].bool
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

enum OverQuotaStatusValue: String {
    case nonOverQuota = "NON_OVER_QUOTA"
    case overQuotaFreemium = "OVER_QUOTA_FREEMIUM"
    case overQuotaPremium = "OVER_QUOTA_PREMIUM"
}

final class OverQuotaStatusResponse: ObjectRequestResponse {
    private enum ResponseKey {
        static let status = "status"
        static let value = "value"
    }
    
    var status: String?
    var value: OverQuotaStatusValue?
    
    override func mapping() {
        status = json?[ResponseKey.status].string
        if let valueString = json?[ResponseKey.value].string {
            value = OverQuotaStatusValue(rawValue: valueString)
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
        let storageUsage: JSON? = json?[UsageResponseKeys.base]
        
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
        if let tmpList = internetDataUsageJsonArray?.compactMap({ InternetDataUsage(withJSON: $0) }) {
            internetDataUsage = tmpList
        }
    }
}

final class PermissionsResponse: ObjectRequestResponse {

    var permissions: [PermissionResponse]?
    
    func hasPermissionFor(_ type: AuthorityType) -> Bool {
        let hasPermission = permissions?.contains(where: { $0.type == type })
        return hasPermission ?? false
    }

    override func mapping() {
        let permissionsJsonArray = json?.array
        if let permissionList = permissionsJsonArray?.compactMap({ PermissionResponse(withJSON: $0) }) {
            permissions = permissionList
        }
    }
}

final class PermissionResponse: ObjectRequestResponse {
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

final class PackagePackAuthoritiesResponse: ObjectRequestResponse {
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
    
    var usedString: String {
        return sizeString(for: (total ?? 0) - (remaining ?? 0))
    }
    
    private func sizeString(for size: Double?) -> String {
        guard let unit = self.unit, let size = size else {
            return ""
        }
        switch unit {
        case .mb:
            if size >= BytesType.size {
                return cleanZero(for: size / BytesType.size, unit: "GB")
            } else if size >= 1 {
                return cleanZero(for: size, unit: "MB")
            } else {
                return cleanZero(for: size * BytesType.size, unit: "KB")
            }
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

final class FeaturesResponse: ObjectRequestResponse {
    
    private enum ResponseKey {
        static let nonTcellPaycellSubscription = "non-tcell-paycell-subscription"
        static let autoVideoUpload = "auto-video-upload"
        static let faceImageRecognition = "face-image-recognition"
        static let autoMusicUpload = "auto-music-upload"
        static let autoPhotoUpload = "auto-photo-upload"
        static let autoVideoUploadV2 = "auto-video-upload-v2"
        static let tcellPaycellSubscription = "tcell-paycell-subscription"
        static let autoSyncDisabled = "auto-sync-disabled"
        static let isResumableUploadEnabled = "resumable-upload-enabled"
        static let resumableUploadChunkSize = "resumable-upload-chunk-size-in-bytes"
        static let maxSharingInviteeCount = "max-sharing-invitee-count"
    }
    
    var isNonTcellPaycellSubscription: Bool?
    var isAutoVideoUpload: Bool?
    var isFaceImageRecognition: Bool?
    var isAutoMusicUpload: Bool?
    var isAutoPhotoUpload: Bool?
    var isAutoVideoUploadV2: Bool?
    var isTcellPaycellSubscription: Bool?
    var isAutoSyncDisabled: Bool?
    var isResumableUploadEnabled: Bool?
    var resumableUploadChunkSize: Int?
    var maxSharingInviteeCount: Int?

    override func mapping() {
        isNonTcellPaycellSubscription = json?[ResponseKey.nonTcellPaycellSubscription].bool
        isAutoVideoUpload = json?[ResponseKey.autoVideoUpload].bool
        isFaceImageRecognition = json?[ResponseKey.faceImageRecognition].bool
        isAutoMusicUpload = json?[ResponseKey.autoMusicUpload].bool
        isAutoPhotoUpload = json?[ResponseKey.autoPhotoUpload].bool
        isAutoVideoUploadV2 = json?[ResponseKey.autoVideoUploadV2].bool
        isTcellPaycellSubscription = json?[ResponseKey.tcellPaycellSubscription].bool
        isAutoSyncDisabled = json?[ResponseKey.autoSyncDisabled].bool
        isResumableUploadEnabled = json?[ResponseKey.isResumableUploadEnabled].bool
        resumableUploadChunkSize = json?[ResponseKey.resumableUploadChunkSize].int
        maxSharingInviteeCount = json?[ResponseKey.maxSharingInviteeCount].int
    }
    
}

final class SecretQuestionsResponse {
    
    private enum ResponseKey {
        static let id = "id"
        static let text = "text"
    }
    
    var id: Int
    var text: String
    
    init(id: Int, text: String) {
        self.id = id
        self.text = text
    }
}

extension SecretQuestionsResponse {
    convenience init?(json: JSON) {
        guard
            let id = json[ResponseKey.id].int,
            let text = json[ResponseKey.text].string
        else {
            assertionFailure()
            return nil
        }
        
        self.init(id: id, text: text)
    }
}

final class FeedbackEmailResponse: ObjectRequestResponse {
    
    private enum ResponseKey {
        static let status = "status"
        static let value = "value"
    }
    
    var status: String?
    var value: String?
    
    override func mapping() {
        status = json?[ResponseKey.status].string
        value = json?[ResponseKey.value].string
    }
}

final class TwoFAChallengeParametersResponse: ObjectRequestResponse {
    
    enum ChallengeStatus: String {
        case new = "SENT_NEW_CHALLENGE"
        case existing = "USE_EXISTING_CHALLENGE"
    }
    
    private enum ResponseKey {
        static let status = "status"
        static let remainingTimeInSeconds = "remainingTimeInSeconds"
        static let expectedInputLength = "expectedInputLength"
    }
    
    var status: ChallengeStatus?
    var remainingTimeInSeconds: Int?
    var expectedInputLength: Int?

    override func mapping() {
        remainingTimeInSeconds = json?[ResponseKey.remainingTimeInSeconds].int
        expectedInputLength = json?[ResponseKey.expectedInputLength].int
        
        if let status = json?[ResponseKey.status].string?.uppercased() {
            self.status = ChallengeStatus(rawValue: status)
        }
    }
}

struct AccountTicket: Codable {
    let ticket: String
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
