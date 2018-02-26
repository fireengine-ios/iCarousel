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
    
    class PhotoUpload: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.photoUpload, value: isWiFi, boolType: .wifi)
        }
    }
    
    class WiFi3G: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.wifi3g, value: isWiFi, boolType: .wifi)
        }
    }
    
    class MusicUpload: MenloworksTag {
        init() {
            super.init(name: NameConstants.musicUpload)
        }
    }
    
    class VideoUpload: MenloworksTag {
        init() {
            super.init(name: NameConstants.videoUpload)
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
            super.init(name: NameConstants.documentsOpen)
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
    
    class AutoSyncVideosViaLte: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncVideosViaLte)
        }
    }
    
    class AutoSyncPhotosViaWifi: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncPhotosViaWifi)
        }
    }
    
    class AutoSyncPhotosViaLte: MenloworksTag {
        init() {
            super.init(name: NameConstants.autoSyncPhotosViaLte)
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
    
    class TurkcellPasswordStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.turckcellPasswordStatus, value: isEnabled, boolType: .trueFalse)
        }
    }
    
    class AutologinStatus: MenloworksBoolTag {
        init(isEnabled: Bool) {
            super.init(name: NameConstants.autologinStatus, value: isEnabled, boolType: .trueFalse)
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
        case wifi
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
        case .wifi:
            stringValue = value ? MenloworksTags.ValueConstants.wifi : MenloworksTags.ValueConstants.mobile
        }
        
        super.init(name: name, value: stringValue)
    }
}

class MenloworksPermissionTag: MenloworksTag {
    init(name: String, isGranted: Bool) {
        super.init(name: name,
                   value: isGranted ? MenloworksTags.ValueConstants.granted : MenloworksTags.ValueConstants.denied)
    }
}
