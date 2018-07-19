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
    case splashScreen
    case welcomeScreen
    case tutorial
    case loginScreen
    case signUpScreen
    case termsAndServices
    case phoneVerefication
    case autosyncSettings
    ///Main Screens
    case homePage
    case photosAndVideos
    case music
    case documents
    ///HomePage cards And adjusted Screens
    case freeAppSpace
    case filterCard
    case allFiles
    case favorites
    case contactSync
    case useCamera
    case upload
    case createStory ///do we need every step?
    case newFolder
    case search
    case uploadFromLifeBox
    case allFilesFolder
    ///Albums
    case albums
    case myStories
    case album(String)///specific album
    ///FaceImageRecognition
    case peopleFIR
    case thingsFIR
    case placesFIR
    case FIR(String)///specific album
    ///Settings
    case importPhotos
    case settingsFIR
    case activityTimeline
    case usageInfo
    case packages
    case lifeBoxTouchId
    case turkcellSecurity
    case FAQ
    case contactUS
    case profileEdit
    ///Previews
    case photoPreview
    case videoPreview
    case musicPlayerFull
    case documentPreview
    ///Misc
    case info//some information about the file?
    
    case share//???? or it should be other enum
    
    case move//some information about the file?
    
}
