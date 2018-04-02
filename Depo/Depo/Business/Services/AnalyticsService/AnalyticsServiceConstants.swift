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
