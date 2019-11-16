//
//  MenloworksTags.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class MenloworksTags {
    
    class Firstsession: MenloworksTag {
        init() {
            super.init(name: NameConstants.firstsession)
        }
    }
    
    class Tutorial: MenloworksTag {
        init() {
            super.init(name: NameConstants.tutorial)
        }
    }
    
    class WiFi3G: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.wifi3g, value: isWiFi, boolType: .wifiMobile)
        }
    }
    
    class NotificationPermissionStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.notificationsPermissionStatus, value: isEnabled, boolType: .permission)
        }
    }
    
    class GalleryPermissionStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.galleryPermissionStatus, value: isEnabled, boolType: .permission)
        }
    }
    
//    class LocationPermissionStatus: MenloworksBoolTag {
//        init(isEnabled: Bool) {
//            super.init(name: NameConstants.locationPermissionStatus, value: isEnabled, boolType: .permission)
//        }
//    }
    
    class LocationPermissionStatus: MenloworksTag {
        init(authorization: String) {
            super.init(name: NameConstants.locationPermissionStatus, value: authorization)
        }
    }
    
    class PeriodicContactSync: MenloworksTag {
        init(periodicContactSync: String) {
            super.init(name: NameConstants.periodicContactSync, value: periodicContactSync)
        }
    }
    
    class TurkcellPasswordChanged: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.turkcellPasswordChanged, value: isEnabled, boolType: .yesNo)
        }
    }
    
    class AutoLoginChanged: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.autoLoginChanged, value: isEnabled, boolType: .trueFalse)
        }
    }
    
    class FiftyGBClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.fiftyGBClicked)
        }
    }
    
    class FiveHundredGBClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.fiveHundredGBClicked)
        }
    }
    
    class TwoThousandFiveHundredGBClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.twoThousandFiveHundredGBClicked)
        }
    }
    
    class MusicUpload: MenloworksTag {
        init() {
            super.init(name: NameConstants.musicUpload)
        }
    }
    
    class FileUpload: MenloworksTag {
        init() {
            super.init(name: NameConstants.fileUpload)
        }
    }
    
    class LoggedIn: MenloworksBoolTag {
        init(isLoggedIn: Bool) {
            super.init(name: NameConstants.loggedIn, value: isLoggedIn, boolType: .yesNo)
        }
    }
    
    class LogginCompleted: MenloworksTag {
        init() {
            super.init(name: NameConstants.loginCompleted)
        }
    }
    
    class SignUpCompleted: MenloworksTag {
        init() {
            super.init(name: NameConstants.signupCompleted)
        }
    }
    
    class PlatinUserStatus: MenloworksTag {
        init() {
            super.init(name: NameConstants.platinUserStatus)
        }
    }
    
    class PromocodeActivated: MenloworksTag {
        init() {
            super.init(name: NameConstants.promocodeActivated)
        }
    }
    
    class FacebookConnected: MenloworksTag {
        init() {
            super.init(name: NameConstants.facebookConnected)
        }
    }
    
    class InstagramConnected: MenloworksTag {
        init() {
            super.init(name: NameConstants.instagramConnected)
        }
    }
    
    
    class AllFilesOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.allFilesOpen)
        }
    }
    
    class PhotosAndVideosOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.photosAndVideosOpen)
        }
    }
    
    class MusicOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.musicOpen)
        }
    }
    
    class DocumentsOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.documentsOpen)
        }
    }
    
    class ContactSyncPageOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.contactSyncPageOpen)
        }
    }

    class CreateStoryPageOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.storyPageOpen)
        }
    }
    
    class PreferencesOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.preferencesOpen)
        }
    }
    
    class PackagesOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.packagesOpen)
        }
    }
    
    class AutoSyncVideosViaWifi: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncVideosViaWifi)
        }
    }
    
    class FirstAutoSyncVideosViaWifi: MenloworksTag {
        init() {
            super.init(name: NameConstants.firstAutoSyncVideosViaWifi)
        }
    }
    
    class AutoSyncVideosViaLte: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncVideosViaLte)
        }
    }
    
    class FirstAutoSyncVideosViaLte: MenloworksTag {
        init() {
            super.init(name: NameConstants.firstAutoSyncVideosViaLte)
        }
    }
    
    class FirstAutoSyncVideosOff: MenloworksTag {
        init() {
            super.init(name: NameConstants.firstAutoSyncVideosOff)
        }
    }
    
    class AutoSyncPhotosViaWifi: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncPhotosViaWifi)
        }
    }
    
    class FirstAutoSyncPhotosViaWifi: MenloworksTag {
        init() {
            super.init(name: NameConstants.firstAutoSyncPhotosViaWifi)
        }
    }
    
    class AutoSyncPhotosViaLte: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncPhotosViaLte)
        }
    }
    
    class FirstAutoSyncPhotosViaLte: MenloworksTag {
        init() {
            super.init(name: NameConstants.firstAutoSyncPhotosViaLte)
        }
    }
    
    class FirstAutoSyncPhotosOff: MenloworksTag {
        init() {
            super.init(name: NameConstants.firstAutoSyncPhotosOff)
        }
    }
    
    class AutoSyncPhotosOff: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncPhotosOff)
        }
    }
    
    class AutoSyncVideosOff: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncVideosOff)
        }
    }
    
    class AutoSyncOff: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncOff)
        }
    }
    
    class ContactUploaded: MenloworksTag {
        init() {
            super.init(name: NameConstants.contactUploaded)
        }
    }
    
    class ContactDownloaded: MenloworksTag {
        init() {
            super.init(name: NameConstants.contactDownloaded)
        }
    }
    
    class EditClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.photoEdit)
        }
    }
    
    class VideoDisplayed: MenloworksTag {
        init() {
            super.init(name: NameConstants.videoDisplayed)
        }
    }
    
    class StoryCreated: MenloworksTag {
        init() {
            super.init(name: NameConstants.storyCreated)
        }
    }
    
    class RemoveFromAlbumClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.removeFromAlbumClicked)
        }
    }
    
    class PrintClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.cellographClicked)
        }
    }
    
    class SyncClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.syncClicked)
        }
    }
    
    class DownloadClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.downloadClicked)
        }
    }
    
    class DeleteClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.deleteClicked)
        }
    }
    
    class ShareClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.shareClicked)
        }
    }
    
    class FavoritesOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.favoritesClicked)
        }
    }
    
    class SearchOpen: MenloworksTag {
        init() {
            super.init(name: NameConstants.search)
        }
    }
    
    class UserPackageStatus: MenloworksTag {
        init() {
            super.init(name: NameConstants.userPackage)
        }
    }
    
    class NoUserPackageStatus: MenloworksTag {
        init() {
            super.init(name: NameConstants.noUserPackage)
        }
    }
    
    class FaceImageRecognitionStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.faceImageRecognitionStatus, value: isEnabled, boolType: .trueFalse)
        }
    }
    
    class InstagramImportStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.instagramImportStatus, value: isEnabled, boolType: .trueFalse)
        }
    }
    
    class FacebookImportStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.facebookImportStatus, value: isEnabled, boolType: .trueFalse)
        }
    }
    
    class PasscodeStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.passcodeStatus, value: isEnabled, boolType: .trueFalse)
        }
    }
    
    class TouchIDStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.touchIDStatus, value: isEnabled, boolType: .trueFalse)
        }
    }
    
//    class TurkcellPasswordStatus: MenloworksBoolTag {
//        init(isEnabled: Bool) {
//            super.init(name: NameConstants.turckcellPasswordStatus, value: isEnabled, boolType: .trueFalse)
//        }
//    }
//    
//    class AutologinStatus: MenloworksBoolTag {
//        init(isEnabled: Bool) {
//            super.init(name: NameConstants.autologinStatus, value: isEnabled, boolType: .trueFalse)
//        }
//    }
    
    class FileDeleted: MenloworksTag {
        init() {
            super.init(name: NameConstants.fileDeleted)
        }
    }
    
    class QuotaStatus: MenloworksPercentageTag {
        init(percentageValue: Int) {
            super.init(name: NameConstants.quotaStatus, percentageValue: percentageValue)
        }
    }
    
    class AutosyncStatus: MenloworksBoolTag {
        init(isOn: Bool) {
            super.init(name: NameConstants.autosyncStatus, value: isOn, boolType: .onOff)
        }
    }
    
    class AutosyncFirstOff: MenloworksTag {
        init() {
            super.init(name: NameConstants.firstAutoSyncOff)
        }
    }
    
    class AutosyncPhotosStatus: MenloworksBoolTag {
        init(isWifi: Bool) {
            super.init(name: NameConstants.autosyncPhotosStatus, value: isWifi, boolType: .wifiLTE)
        }
    }
    
    class AutosyncVideosStatus: MenloworksBoolTag {
        init(isWifi: Bool) {
            super.init(name: NameConstants.autosyncVideosStatus, value: isWifi, boolType: .wifiLTE)
        }
    }
    
    class FiftyGBPurchasedStatus: MenloworksTag {
        init() {
            super.init(name: NameConstants.fiftyGBPurchasedStatus)
        }
    }
    
    class FiveHundredGBPurchasedStatus: MenloworksTag {
        init() {
            super.init(name: NameConstants.fiveHundredGBPurchasedStatus)
        }
    }
    
    class TwoThousandFiveHundredGBPurchasedStatus: MenloworksTag {
        init() {
            super.init(name: NameConstants.twoThousandFiveHundredGBPurchasedStatus)
        }
    }
    
    class FavoritesPageClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.favoritesPageClicked)
        }
    }
    
    class SocialMediaPageClicked: MenloworksTag {
        init() {
            super.init(name: NameConstants.socialMediaPageClicked)
        }
    }
    class EditedPhotoSaved: MenloworksTag {
        init() {
            super.init(name: NameConstants.editedPhotoSave)
        }
    }
    
    class PhotoUploadAutosync: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.photoUploadAutosync, value: isWiFi, boolType: .wifiMobile)
        }
    }
    
    class PhotoUploadManual: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.photoUploadManual, value: isWiFi, boolType: .wifiMobile)
        }
    }
    
    class PhotoUploadBackground: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.photoUploadBackground, value: isWiFi, boolType: .wifiMobile)
        }
    }
    
    class VideoUploadAutosync: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.videoUploadAutosync, value: isWiFi, boolType: .wifiMobile)
        }
    }
    
    class VideoUploadManual: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.videoUploadManual, value: isWiFi, boolType: .wifiMobile)
        }
    }
    
    class VideoUploadBackground: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.videoUploadBackground, value: isWiFi, boolType: .wifiMobile)
        }
    }

    class ProfileName: MenloworksTag {
        init(isEmpty: Bool) {
            super.init(name: NameConstants.profileName, value: isEmpty ? "empty": "full")
        }
    }
    
    class ProfileNameEmpty: MenloworksTag {
        init() {
            super.init(name: NameConstants.profileNameEmpty)
        }
    }
    
    class ProfileNameFull: MenloworksTag {
        init() {
            super.init(name: NameConstants.profileNameFull)
        }
    }
    
    class PhotopickLeftAnalysis: MenloworksTag {
        init(isFree: Bool, value: Int) {
            super.init(name: NameConstants.photopickLeftAnalysis, value: isFree ? MenloworksTags.ValueConstants.free : String(value))
        }
    }
    
    class PhotopickAnalyze: MenloworksTag {
        init(isSuccess: Bool) {
            super.init(name: NameConstants.photopickAnalyze, value: isSuccess ? MenloworksTags.ValueConstants.success : MenloworksTags.ValueConstants.fail)
        }
    }
    
    class PhotopickAnalyzeResult: MenloworksTag {
        init(isSuccess: Bool) {
            super.init(name: isSuccess ? NameConstants.photopickAnalyzeSuccess : NameConstants.photopickAnalyzeFail)
        }
    }
    
    class PhotopickDailyDrawLeft: MenloworksTag {
        init(value: Int) {
            super.init(name: NameConstants.photopickDailyDrawLeft, value: String(value))
        }
    }
    
    class PhotopickTotalDraw: MenloworksTag {
        init(value: Int) {
            super.init(name: NameConstants.photopickTotalDraw, value: String(value))
        }
    }

}

class MenloworksTag {
    let name: String
    let value: String?
    
    private init() {
        name = ""
        value = nil
    }
    
    init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}

class MenloworksBoolTag: MenloworksTag {
    enum BoolType {
        case trueFalse
        case yesNo
        case onOff
        case permission
        case wifiMobile
        case wifiLTE
    }
    
    init(name: String, value: Bool, boolType: BoolType) {
        let stringValue: String
        switch boolType {
        case .trueFalse:
            stringValue = value ? MenloworksTags.ValueConstants.true : MenloworksTags.ValueConstants.false
        case .yesNo:
            stringValue = value ? MenloworksTags.ValueConstants.yes : MenloworksTags.ValueConstants.no
        case .onOff:
            stringValue = value ? MenloworksTags.ValueConstants.on : MenloworksTags.ValueConstants.off
        case .permission:
            stringValue = value ? MenloworksTags.ValueConstants.granted : MenloworksTags.ValueConstants.denied
        case .wifiMobile:
            stringValue = value ? MenloworksTags.ValueConstants.wifi : MenloworksTags.ValueConstants.mobile
        case .wifiLTE:
            stringValue = value ? MenloworksTags.ValueConstants.wifi : MenloworksTags.ValueConstants.lte
        }
        
        super.init(name: name, value: stringValue)
    }
}

//class MenloworksPermissionTag: MenloworksTag {
//    init(name: String, isGranted: Bool) {
//        super.init(name: name,
//                   value: isGranted ? MenloworksTags.ValueConstants.granted : MenloworksTags.ValueConstants.denied)
//    }
//}

class MenloworksPercentageTag: MenloworksTag {
    init(name: String, percentageValue: Int) {
        super.init(name: name, value: String(percentageValue))
    }
}
