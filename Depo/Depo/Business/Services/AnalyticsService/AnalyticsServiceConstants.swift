//
//  AnalyticsServiceConstants.swift
//  Depo
//
//  Created by Andrei Novikau on 28.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

enum AnalyticsEvent {
    case signUp
    case login
    case uploadPhoto
    case uploadVideo
    case uploadFromCamera
    case uploadMusic
    case uploadDocument
    case purchaseTurkcell50
    case purchaseTurkcell500
    case purchaseTurkcell2500
    case purchaseNonTurkcell50
    case purchaseNonTurkcell500
    case purchaseNonTurkcell2500
    case importDropbox
    case importFacebook
    case importInstagram
    case turnOnAutosync
    case contactBackup
    case freeUpSpace
    case setPasscode
    case createStory
    
    var token: String {
        switch self {
        case .signUp: return "ese4q4"
        case .login: return "qqnm9p"
        case .uploadPhoto: return "esdqth"
        case .uploadVideo: return "noawdt"
        case .uploadFromCamera: return "yx3j4p"
        case .uploadMusic: return "ba947a"
        case .uploadDocument: return "jb1jc6"
        case .purchaseTurkcell50: return "trie85"
        case .purchaseTurkcell500: return "wdqlvk"
        case .purchaseTurkcell2500: return "7bf7gu"
        case .purchaseNonTurkcell50: return "q3ivog"
        case .purchaseNonTurkcell500: return "x6zaly"
        case .purchaseNonTurkcell2500: return "zab8u6"
        case .importDropbox: return "tdvlrq"
        case .importFacebook: return "y5dz5j"
        case .importInstagram: return "jk78lq"
        case .turnOnAutosync: return "kwo7m3"
        case .contactBackup: return "u440dw"
        case .freeUpSpace: return "w9vvtl"
        case .setPasscode: return "ojquhk"
        case .createStory: return "afp233"
        }
    }
        
    var facebookEventName: String {
        switch self {
        case .signUp: return "SIGNUP"
        case .login: return "LOGIN"
        case .uploadPhoto: return "UPLOAD_PHOTO"
        case .uploadVideo: return "UPLOAD_VIDEO"
        case .uploadFromCamera: return "UPLOAD_FROM_CAMERA"
        case .uploadMusic: return "UPLOAD_MUSIC"
        case .uploadDocument: return "UPLOAD_DOCUMENT"
        case .purchaseTurkcell50: return "PURCHASE_50_GB_TURKCELL"
        case .purchaseTurkcell500: return "PURCHASE_500_GB_TURKCELL"
        case .purchaseTurkcell2500: return "PRUCHASE_25_TB_TURKCELL"
        case .purchaseNonTurkcell50: return "PURCHASE_50_GB_NONTURKCELL"
        case .purchaseNonTurkcell500: return "PURCHASE_500_GB_NONTURKCELL"
        case .purchaseNonTurkcell2500: return "PRUCHASE_25_TB_NONTURKCELL"
        case .importDropbox: return "DROPBOX_IMPORT"
        case .importFacebook: return "FACEBOOK_IMPORT"
        case .importInstagram: return "INSTAGRAM_IMPORT"
        case .turnOnAutosync: return "TURN_ON_AUTOSYNC"
        case .contactBackup: return "CONTACT_BACKUP"
        case .freeUpSpace: return "FREE_UP_SPACE"
        case .setPasscode: return "PASSCODE_SET"
        case .createStory: return "CREATE_STORY"
        }
    }
}

enum AnalyticsAppScreens {
    ///authorization
    case loginScreen
    case signUpScreen
    case forgotPassword
    case termsAndServices
    case signUpOTP
    case doubleOTP
    case autosyncSettingsFirst
    ///Main Screens
    case homePage
    case photos
    case videos
    case music
    case documents
    ///HomePage cards And adjusted Screens
    case freeAppSpace
    case allFiles
    case favorites
    case upload
    case search
    ///Create Story
    case createStoryName
    case createStoryPhotosSelection
    case createStoryMusicSelection
    case createStoryPreview
    ///Albums
    case albums
    case myStories
    ///FaceImageRecognition
    case peopleFIR
    case thingsFIR
    case placesFIR
    ///Settings
    case settings
    case importPhotos
    case settingsFIR
    case activityTimeline
    case usageInfo
    case packages
    case lifeBoxTouchIdPasscode
    case turkcellSecurity
    case FAQ
    case contactUS
    case profileEdit
    case settingsPhotoEdit
    case autoSyncSettings
    ///contactSync
    case contacSyncDeleteDuplicates
    case contactSyncBackUp
    case contactSyncGeneral
    ///Previews
//    case photoPreview
//    case videoPreview
//    case musicPlayerFull
//    case documentPreview
    ///Misc
    case nativeGalleryShare
    case welcomePage(Int)
    
    var name: String {
        switch self {
        ///authorization
        case .welcomePage(let welcomeNumber):
            return "Welcome Page -\(welcomeNumber)"
        case .loginScreen:
            return "Login"
        case .signUpScreen:
            return "Signup"
        case .forgotPassword:
            return "Forget Password"
        case .termsAndServices:
            return "Eula"
        case .signUpOTP:
            return "OTP - Signup"
        case .doubleOTP:
            return "OTP - DoubleOptIn"
        case .autosyncSettingsFirst:
            return "First Auto Sync Screen"
        case .autoSyncSettings:
            return "Auto Sync"
        ///Main Screens
        case .homePage:
            return "Home Page"
        case .photos:
            return "Photos"
        case .videos:
            return "Videos"
        case .music:
            return "Music"
        case .documents:
            return "Documents"
        ///HomePage cards And adjusted Screens
        case .freeAppSpace:
            return "Free Up Space"
        case .allFiles:
            return "All Files"
        case .favorites:
            return "Favorites"
        case .contacSyncDeleteDuplicates:
            return "Delete Duplicate"
        case .contactSyncBackUp:
            return "Contact Back Up"
        case .contactSyncGeneral:
            return "Contacts Sync"
        case .upload:
            return "Manual Upload"
        case .search:
            return "Search"
        ///Create Story
        case .createStoryName:
            return "Create Story - Name"
        case .createStoryPhotosSelection:
            return "Create Story - Photo Selection"
        case .createStoryMusicSelection:
            return "Create Story - Music Selection"
        case .createStoryPreview:
            return "Create Story - Preview"
        ///Albums
        case .albums:
            return "Albums"
        case .myStories:
            return "Stories"
        ///FaceImageRecognition
        case .peopleFIR:
            return "People"
        case .thingsFIR:
            return "Things"
        case .placesFIR:
            return "Places"
        ///Settings
        case .settings:
            return "Settings"
        case .importPhotos:
            return "Import Photos"
        case .settingsFIR:
            return "Face & Image Grouping"
        case .activityTimeline:
            return "Activitiy Timeline"
        case .usageInfo:
            return "Usage Info"
        case .packages:
            return "Packages"
        case .lifeBoxTouchIdPasscode:
            return "Passcode"
        case .turkcellSecurity:
            return "Login Settings"
        case .FAQ:
            return "FAQ"
        case .contactUS:
            return "Contact Us"
        case .profileEdit:
            return "Profile Edit"
        case .settingsPhotoEdit:
            return "Photo Edit"
        ///Misc
        case .nativeGalleryShare:
            return "Native Share from Gallery"
        }
    }
}
