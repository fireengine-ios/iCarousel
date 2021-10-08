//
//  FirebaseAnalyticsEvents.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
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
    case purchaseTurkcell100
    case purchaseTurkcell500
    case purchaseTurkcell250
    case purchaseTurkcell250_SixMonth
    case purchaseTurkcell2500
    case purchaseTurkcellPremium

    case purchaseNonTurkcell50
    case purchaseNonTurkcell100
    case purchaseNonTurkcell500
    case purchaseNonTurkcell250
    case purchaseNonTurkcell250_SixMonth
    case purchaseNonTurkcell2500
    case purchaseNonTurkcellPremium

    case importDropbox
    case importFacebook
    case importInstagram

    case turnOnAutosync
    case contactBackup
    case freeUpSpace
    case setPasscode
    case createStory
    
    
    var token: String {
        #if LIFEDRIVE
            switch self {
            case .signUp: return "vq33ql"
            case .login: return "6p1zes"
                
            case .uploadPhoto: return "bb7rkc"
            case .uploadVideo: return "syfucn"
            case .uploadFromCamera: return "f1xmv5"
            case .uploadMusic: return "92mj33"
            case .uploadDocument: return "at77np"
                
            case .purchaseTurkcell50: return "8oapnp"
            case .purchaseTurkcell100: return "oziuyb"
            case .purchaseTurkcell250: return "48kuya"
            case .purchaseTurkcell250_SixMonth: return "a6uav1"
            case .purchaseTurkcell500: return "hmuea4"
            case .purchaseTurkcell2500: return "br8bqi"
            case .purchaseTurkcellPremium: return "48qsxv"
                
            case .purchaseNonTurkcell50: return "pdouoa"
            case .purchaseNonTurkcell100: return "qsa0yw"
            case .purchaseNonTurkcell250: return "48kuya"
            case .purchaseNonTurkcell250_SixMonth: return "a6uav1"
            case .purchaseNonTurkcell500: return "alvhrn"
            case .purchaseNonTurkcell2500: return "lr6i1j"
            case .purchaseNonTurkcellPremium: return "cxf2hr"
                
            case .importDropbox: return "afb0bz"
            case .importFacebook: return "pto7xt"
            case .importInstagram: return "kp4fu3"
                
            case .turnOnAutosync: return "4nsckx"
            case .contactBackup: return "c94pqu"
            case .freeUpSpace: return "3cccmx"
            case .setPasscode: return "kj4blr"
            case .createStory: return "x35cgx"
            }
        #else
            switch self {
            case .signUp: return "ese4q4"
            case .login: return "qqnm9p"
                
            case .uploadPhoto: return "esdqth"
            case .uploadVideo: return "noawdt"
            case .uploadFromCamera: return "yx3j4p"
            case .uploadMusic: return "ba947a"
            case .uploadDocument: return "jb1jc6"
                
            case .purchaseTurkcell50: return "trie85"
            case .purchaseTurkcell100: return "62s83p"
            case .purchaseTurkcell250: return "zdgrdx"
            case .purchaseTurkcell250_SixMonth: return "gmnxmu"
            case .purchaseTurkcell500: return "wdqlvk"
            case .purchaseTurkcell2500: return "7bf7gu"
            case .purchaseTurkcellPremium: return "qexub9"
                
            case .purchaseNonTurkcell50: return "q3ivog"
            case .purchaseNonTurkcell100: return "lbrusf"
            case .purchaseNonTurkcell250: return "zdgrdx"
            case .purchaseNonTurkcell250_SixMonth: return "gmnxmu"
            case .purchaseNonTurkcell500: return "x6zaly"
            case .purchaseNonTurkcell2500: return "zab8u6"
            case .purchaseNonTurkcellPremium: return "9pyt2d"
                
            case .importDropbox: return "tdvlrq"
            case .importFacebook: return "y5dz5j"
            case .importInstagram: return "jk78lq"
                
            case .turnOnAutosync: return "kwo7m3"
            case .contactBackup: return "u440dw"
            case .freeUpSpace: return "w9vvtl"
            case .setPasscode: return "ojquhk"
            case .createStory: return "afp233"
            }
        #endif
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
        case .purchaseTurkcell100: return "PURCHASE_100_GB_TURKCELL"
        case .purchaseTurkcell250: return "PURCHASE_250_GB_TURKCELL"
        case .purchaseTurkcell250_SixMonth: return "PURCHASE_250_GB_SIXMONTH_TURKCELL"
        case .purchaseTurkcell500: return "PURCHASE_500_GB_TURKCELL"
        case .purchaseTurkcell2500: return "PRUCHASE_25_TB_TURKCELL"
        case .purchaseTurkcellPremium: return "PURCHASE_PREMIUM_TURKCELL"

        case .purchaseNonTurkcell50: return "PURCHASE_50_GB_NONTURKCELL"
        case .purchaseNonTurkcell100: return "PURCHASE_100_GB_NONTURKCELL"
        case .purchaseNonTurkcell250: return "PURCHASE_250_GB_NONTURKCELL"
        case .purchaseNonTurkcell250_SixMonth: return "PURCHASE_250_GB_SIXMONTH_NONTURKCELL"
        case .purchaseNonTurkcell500: return "PURCHASE_500_GB_NONTURKCELL"
        case .purchaseNonTurkcell2500: return "PRUCHASE_25_TB_NONTURKCELL"
        case .purchaseNonTurkcellPremium: return "PURCHASE_PREMIUM_NONTURKCELL"

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
