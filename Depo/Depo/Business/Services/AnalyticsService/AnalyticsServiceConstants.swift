//
//  AnalyticsServiceConstants.swift
//  Depo
//
//  Created by Andrei Novikau on 28.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import FirebaseAnalytics

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
    case purchaseTurkcell2500
    case purchaseTurkcellPremium

    case purchaseNonTurkcell50
    case purchaseNonTurkcell100
    case purchaseNonTurkcell500
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
            case .purchaseTurkcell500: return "hmuea4"
            case .purchaseTurkcell2500: return "br8bqi"
            case .purchaseTurkcellPremium: return "48qsxv"
                
            case .purchaseNonTurkcell50: return "pdouoa"
            case .purchaseNonTurkcell100: return "qsa0yw"
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
            case .purchaseTurkcell500: return "wdqlvk"
            case .purchaseTurkcell2500: return "7bf7gu"
            case .purchaseTurkcellPremium: return "qexub9"
                
            case .purchaseNonTurkcell50: return "q3ivog"
            case .purchaseNonTurkcell100: return "lbrusf"
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
        case .purchaseTurkcell500: return "PURCHASE_500_GB_TURKCELL"
        case .purchaseTurkcell2500: return "PRUCHASE_25_TB_TURKCELL"
        case .purchaseTurkcellPremium: return "PURCHASE_PREMIUM_TURKCELL"

        case .purchaseNonTurkcell50: return "PURCHASE_50_GB_NONTURKCELL"
        case .purchaseNonTurkcell100: return "PURCHASE_100_GB_NONTURKCELL"
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
    case createStoryPhotosSelection
    case createStoryMusicSelection
    case createStoryPreview
    case createStoryDetails
    ///Albums
    case albums
    case myStories
    ///FaceImageRecognition
    case peopleFIR
    case thingsFIR
    case placesFIR
    ///Settings
    case settings
    case connectedAccounts
    case settingsFIR
    case activityTimeline
    case usageInfo
    case packages
    case appTouchIdPasscode
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
    ///PhotoPick
    case photoPickHistory
    case photoPickPhotoSelection
    case photoPickAnalysisDetail
    ///PackageDetails
    case standartAccountDetails
    case standartPlusAccountDetails
    case premiumAccountDetails
    ///MyProfile
    case myStorage
    case changePassword
    ///Spotify
    case spotifyImport
    case spotifyImportPlaylistSelection
    case spotifyImportPlaylistDetails
    case spotifyImportProgress
    case spotifyImportResult
    case spotifyPlaylistDetails
    case spotifyPlaylists
    case spotifyAuthentification
    ///TwoFactorAuth
    case securityCheck
    case enterSecurityCode
    case enterSecurityCodeResend
    ///EmailVerification
    case verifyEmailPopUp
    case changeEmailPopUp
    ///CredsUpdateCheckPopUp
    case periodicInfoScreen

    case info(FileType)
    
    case tbmatikPushNotification
    case tbmatikHomePageCard
    case tbmatikSwipePhoto(_ page: Int)
    
    case securityQuestion
    case securityQuestionSelect
    
    case campaignSamsungPopupFirst
    case campaignSamsungPopupLast
    case campaignSamsungPopupBecomePremium
    case campaignDetailDuring
    case campaignDetailAfter
    
    //Smash
    case smashConfirmPopUp
    case saveSmashSuccessfullyPopUp
    case nonStandardUserWithFIGroupingOffPopUp
    case standardUserWithFIGroupingOffPopUp
    case standardUserWithFIGroupingOnPopUp
    case smashPreview
    
    case saveHiddenSuccessPopup
    case hiddenBin
    case trashBin
    case fileOperationConfirmPopup(GAOperationType)
    
    case mobilePaymentPermission
    case mobilePaymentExplanation
    case eulaExplanation
    
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
        case .createStoryPhotosSelection:
            return "Create Story - Photo Selection"
        case .createStoryMusicSelection:
            return "Create Story - Music Selection"
        case .createStoryPreview:
            return "Create Story - Preview"
        case .createStoryDetails:
            return "Create Story - Details"
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
        case .connectedAccounts:
            return "Connected Accounts"
        case .settingsFIR:
            return "Face & Image Grouping"
        case .activityTimeline:
            return "Activitiy Timeline"
        case .usageInfo:
            return "Usage Info"
        case .packages:
            return "Packages"
        case .appTouchIdPasscode:
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
        ///PhotoPick
        case .photoPickHistory:
            return "PhotoPick History"
        case .photoPickPhotoSelection:
            return "PhotoPick Photo Selection"
        case .photoPickAnalysisDetail:
            return "PhotoPick Analysis Detail"
        ///PackageDetails
        case .standartAccountDetails:
            return "Standard Details"
        case .standartPlusAccountDetails:
            return "Standard Plus Details"
        case .premiumAccountDetails:
            return "Premium Details"
        ///
        case .myStorage:
            return "My Storage"
        case .changePassword:
            return "Change Password"
        ///
        case .spotifyImport:
            return "Spotify Import"
        case .spotifyImportPlaylistSelection:
            return "Spotify Import Playlist Selection"
        case .spotifyImportPlaylistDetails:
            return "Spotify Import Playlist Details"
        case .spotifyImportProgress:
            return "Spotify Import Progress"
        case .spotifyImportResult:
            return "Sporify Import Result"
        case .spotifyPlaylists:
            return "Spotify Playlists"
        case .spotifyPlaylistDetails:
            return "Spotify Playlist Details"
        case .spotifyAuthentification:
            return "Spotify Authentication "
        ///
        case .securityCheck:
            return "Security Check"
        case .enterSecurityCode:
            return "Enter Security Code"
        case .enterSecurityCodeResend:
            return "Enter Security Code - Resend Code"
        ///
        case .verifyEmailPopUp:
            return "Email verification - Popup"
        case .changeEmailPopUp:
            return "Email verification - Change Email"
        ///
        case .periodicInfoScreen:
            return "Periodic Info Screen"
        ///
        case .info(let fileType):
            switch fileType {
            case .image:
                return "Photo_Info"
            case .video:
                return "Video_Info"
            case .application:
                return "Document_Info"
            case .audio:
                return "Music_Info"
            case .photoAlbum:
                return "Album_Info"
            case .folder:
                return "Folder_Info"
            default:
                return "Info"
            }
            
        case .tbmatikHomePageCard:
            return "Home-Page Card-TBMatik"
        case .tbmatikPushNotification:
            return "Push-Notification-TBMatik"
        case .tbmatikSwipePhoto(let page):
            return "TBMatik Swipe \(page)"
        case .securityQuestion:
            return "Security Question"
        case .securityQuestionSelect:
            return "Security Question - Select"
        case .campaignSamsungPopupFirst:
            return "Campaign - Samsung POP-UP First"
        case .campaignSamsungPopupLast:
            return "Campaign - Samsung POP-UP Last"
        case .campaignSamsungPopupBecomePremium:
            return "Campaign - Samsung POP-UP Become Premium"
        case .campaignDetailDuring:
            return "Campaign - Detail During"
        case .campaignDetailAfter:
            return "Campaign - Detail After"
        case .smashConfirmPopUp:
            return "Smash Confirm Pop up"
        case .saveSmashSuccessfullyPopUp:
            return "Save Smash Successfully Pop up"
        case .nonStandardUserWithFIGroupingOffPopUp:
            return "NonStandard User With F/I Grouping OFF Pop Up"
        case .standardUserWithFIGroupingOffPopUp:
            return "Standard User With F/I Grouping OFF Pop Up"
        case .standardUserWithFIGroupingOnPopUp:
            return "Standard User With F/I Grouping ON Pop Up"
        case .smashPreview:
            return "Smash Preview"
        case .saveHiddenSuccessPopup:
            return "Save Hidden Successfully Pop Up"
        case .hiddenBin:
            return "Hidden Bin"
        case .trashBin:
            return "Trash Bin"
        case .fileOperationConfirmPopup(let operationType):
            return operationType.confirmPopupEventActionText
        case .mobilePaymentPermission:
            return "Mobile Payment Permission"
        case .mobilePaymentExplanation:
            return "Mobile Payment Explanation"
        case .eulaExplanation:
            return "Eula Explanation"
        }
    }
}

//enum AnalyticsPackageProductParametrs {
//    case itemName
//    case itemID
//    case price
//    case itemBrand
//    case itemCategory
//    case itemVariant
//    case index
//    case quantity
//
//    var text: String {
//        switch self {
//        case .itemName:
//            return "AnalyticsParameterItemName"
//        case .itemID:
//            return "AnalyticsParameterItemID"
//        case .price:
//            return "AnalyticsParameterPrice"
//        case .itemBrand:
//            return "AnalyticsParameterItemBrand"
//        case .itemCategory:
//            return "AnalyticsParameterItemCategory"
//        case .itemVariant:
//            return "AnalyticsParameterItemVariant"
//        case .index:
//            return "AnalyticsParameterIndex"
//        case .quantity:
//            return "AnalyticsParameterQuantity"
//        }
//    }
//}

enum AnalyticsPackageEcommerce {
    case items
//    case itemList
//    case transactionID
//    case tax
//    case priceValue
//    case shipping
    
    var text: String {
        switch self {
        case .items:
            return "items"
//        case .itemList:
//            return "AnalyticsParameterItemList"
//        case .transactionID:
//            return "AnalyticsParameterTransactionID"
//        case .tax:
//            return "AnalyticsParameterTax"
//        case .priceValue:
//            return "AnalyticsParameterValue"
//        case .shipping:
//            return "AnalyticsParameterShipping"
        }
    }
}

enum GACustomEventKeys {
    case category
    case action
    case label
    case value
    
    var key: String {
        switch self {
        case .category:
            return "eventCategory"
        case .action:
            return "eventAction"
        case .label:
            return "eventLabel"
        case .value:
            return "eventValue"
        }
    }
}

enum GACustomEventsType {
    case event
    case screen
    case purchase
    case selectContent
    
    var key: String {
        switch self {
        case .event:
            return "GAEvent"
        case .screen:
            return "screenView"
        case .purchase:
            return AnalyticsEventEcommercePurchase
        case .selectContent:
            return AnalyticsEventSelectContent
        }
    }
}

enum GAEventCategory {
    case enhancedEcommerce
    case functions
    case videoAnalytics
    case errors
    case popUp
    case twoFactorAuthentication
    case emailVerification
    case securityQuestion
    case campaign

    var text: String {
        switch self {
        case .enhancedEcommerce:
            return "Enhance Ecommerce"
        case .functions:
            return "Functions"
        case .videoAnalytics:
            return "Video Analytics"
        case .errors:
            return "Errors"
        case .popUp:
            return "POP UP"
        case .twoFactorAuthentication:
            return "Two Factor Authentication"
        case .emailVerification:
            return "E-mail verification"
        case .securityQuestion:
            return "Security Question"
        case .campaign:
            return "Campaign"
        }
    }
}

enum GAEventAction {
    enum FavoriteLikeStatus {
        case favorite
        case like
        var text: String {
            switch self {
            case .like:
                return "Like"
            case .favorite:
                return "Favorite"
            }
        }
    }
    
    case purchase
    case login
    case logout
    case register
    case removefavorites
    case favoriteLike(FavoriteLikeStatus)
    case feedbackForm
    case download
    case share
    case quota
    case delete
    case click
    case notification
    case sort
    case search
    case newFolder
    case clickOtherTurkcellServices
    case phonebook
    case photoEdit
    case importFrom
    case print
    case uploadFile
    case story
    case freeUpSpace
    case faceRecognition
    case profilePhoto
    case sync
    case recognition
    case contact
    case startVideo ///or story
    case everyMinuteVideo
    case serviceError
    case paymentErrors
    case photopickAnalysis
    case firstAutoSync
    case settingsAutoSync
    case captcha
    case photopickShare
    case contactOperation(SYNCMode)
    case plus
    case connectedAccounts
    case deleteAccount
    case periodicInfoUpdate
    case myProfile
    case msisdn
    case email
    case otp
    case changeEmail
    case clickQuotaPurchase
    case clickFeaturePurchase
    case tbmatik
    case supportLogin
    case supportSignUp
    case securityQuestionClick
    case saveSecurityQuestion(_ number: Int)
    case giftIcon
    case campaignDetail
    case analyzeWithPhotopick
    case smash
    case smashSave
    case smashConfirmPopUp
    case smashSuccessPopUp
    case nonStandardUserWithFIGroupingOff
    case standardUserWithFIGroupingOff
    case standardUserWithFIGroupingOn
    case hiddenBin
    case trashBin
    case saveHiddenSuccessPopup
    case overQuotaFreemiumPopup
    case overQuotaPremiumPopup
    case quotaAlmostFullPopup
    case quotaLimitFullPopup
    case mobilePaymentPermission
    case mobilePaymentExplanation
    case openMobilePaymentPermission
    
    case fileOperation(GAOperationType)
    case fileOperationPopup(GAOperationType)

    var text: String {
        switch self {
        case .purchase:
            return "Purchase"
        case .login:
            return "Login"
        case .logout:
            return "Logout"
        case .register:
            return "Signup"//FE-538  //"MSISDN"//FE-55 "Register"
        case .removefavorites:
            return "remove favorites"
        case .favoriteLike(let status):
            return status.text /// original name - Favorite/Like
        case .feedbackForm:
            return "Feedback Form"
        case .download:
            return "Download"
        case .share:
            return "Share"
        case .quota:
            return "Quota"
        case .delete:
            return "Delete"
        case .click:
            return "Click"
        case .notification:
            return "Notification"
        case .sort:
            return "Sort"
        case .search:
            return "Search"
        case .newFolder:
            return "New Folder"
        case .clickOtherTurkcellServices:
            return "Click Other Turkcell Services"
        case .phonebook:
            return "Phonebook"
        case .photoEdit:
            return "Photo Rename"
        case .importFrom:
            return "Import"
        case .print:
            return "Print"
        case .uploadFile:
            return "Upload File"
        case .story:
            return "Story"
        case .freeUpSpace:
            return "Free Up Space"
        case .faceRecognition:
            return "Face Recognition"
        case .profilePhoto:
            return "Profile Photo"
        case .sync:
            return "Sync"
        case .recognition:
            return "Recognition"
        case .contact:
            return "Contact"
        case .startVideo: ///or story
            return "Start"
        case .everyMinuteVideo:
            return "Every Minute"
        case .serviceError:
            return "Service Errors"
        case .paymentErrors:
            return "Payment Errors"
        case .photopickAnalysis:
            return "Photopick Analysis"
        case .firstAutoSync:
            return "First Auto Sync"
        case .settingsAutoSync:
            return "Auto Sync"
        case .captcha:
            return "Captcha"
        case .photopickShare:
            return "Photopick Share"
        case .contactOperation(let operation):
            switch operation {
            case .backup:
                return "Contact Backup"
            case .restore:
                return "Contact Restore"
            }
        case .plus:
            return "Plus"
        case .connectedAccounts:
            return "Connected Accounts"
        case .deleteAccount:
            return "Delete Account"
        case .periodicInfoUpdate:
            return "Periodic Info Update"
        case .myProfile:
            return "My Profile"
        case .msisdn:
            return "msisdn"
        case .email:
            return "E-mail"
        case .otp:
            return "OTP-1"
        case .changeEmail:
            return "Email"
        case .clickQuotaPurchase:
            return "Click Quota Purchase"
        case .clickFeaturePurchase:
            return "Click Feature Purchase"
        case .tbmatik:
            return "TBMatik"
        case .supportLogin:
            return "Support Form - Login"
        case .supportSignUp:
            return "Support Form - Sign Up"
        case .securityQuestionClick:
            return "Set Security Question - Click"
        case .saveSecurityQuestion(let number):
            return "Save Q\(number)"
        case .giftIcon:
            return "Gift icon"
        case .campaignDetail:
            return "Campaign Detail"
        case .analyzeWithPhotopick:
            return "Analyze with photopick"
        case .smash:
            return "Smash"
        case .smashConfirmPopUp:
            return "Smash Confirm Pop up"
        case .smashSuccessPopUp:
            return "Save Smash Successfully Pop Up"
        case .nonStandardUserWithFIGroupingOff:
            return "NonStandard User With F/I Grouping OFF Pop Up"
        case .standardUserWithFIGroupingOff:
            return "Standard User With F/I Grouping OFF Pop Up"
        case .standardUserWithFIGroupingOn:
            return "Standard User With F/I Grouping ON Pop Up"
        case .smashSave:
            return "Smash Save"
        case .hiddenBin:
            return "Hidden Bin"
        case .trashBin:
            return "Trash bin"
        case .saveHiddenSuccessPopup:
            return "Save Hidden Successfully Pop Up"
        case .overQuotaFreemiumPopup:
            return "Over Quota Freemium Pop up"
        case .overQuotaPremiumPopup:
            return "Over Quota Premium Pop up"
        case .quotaAlmostFullPopup:
            return "Quota Almost Full Pop up"
        case .quotaLimitFullPopup:
            return "Quota Limit Full Pop up"
        case .fileOperation(let operationType):
            return operationType.eventActionText
        case .fileOperationPopup(let operationType):
            return operationType.popupEventActionText
        case .mobilePaymentPermission:
            return "Mobile Payment Permission"
        case .mobilePaymentExplanation:
            return "Mobile Payment Explanation"
        case .openMobilePaymentPermission:
            return "Open Mobile Payment Permission"
        }
    }
}

enum GAEventLabel {
    enum FileType {
        case photo
        case video
        case people
        case things
        case places
        case story
        case albums
        case document
        case music
        case folder
        
        var text: String {
            switch self {
            case .photo:
                return "Photo"
            case .video:
                return "Video"
            case .people:
                return "Person"
            case .things:
                return "Thing"
            case .places:
                return "Place"
            case .story:
                return "Story"
            case .albums:
                return "Album"
            case .document:
                return "Document"
            case .music:
                return "Music"
            case .folder:
                return "Folder"
            }
        }
    }
    
    enum ShareType {
        case facebook
        case twitter
        case eMail
        
        var text: String {
            switch self {
            case .facebook:
                return "Facebook"
            case .twitter:
                return "Twitter"
            case .eMail:
                return "e - mail"
            }
        }
    }
    
    enum StoryEvent {
        case click
        case name
        case photoSelect
        case musicSelect
        case save
        var text: String {
            switch self {
            case .click:
                return "Click"
            case .name:
                return "Name"
            case .photoSelect:
                return "Photo Select"
            case .musicSelect:
                return "Music Select"
            case .save:
                return "Save"
            }
        }
    }
    
    enum CaptchaEvent {
        case changeClick
        case voiceClick
        
        var text: String {
            switch self {
            case .changeClick:
                return "Change Click"
            case .voiceClick:
                return "Voice Click"
            }
        }
    }
    
    enum ContactEvent {
        case backup
        case restore
        case deleteDuplicates
        
        var text: String {
            switch self {
            case .backup:
                return "Backup"
            case .restore:
                return "Restore"
            case .deleteDuplicates:
                return "Delete of Duplicate"
            }
        }
    }
    
    enum QuotaPaymentType {
        case chargeToBill(_ quota: String)
        case appStore(_ quota: String)
        case creditCard(_ quota: String)
        
        var text: String {
            switch self {
            case .chargeToBill(let quota):
                return "Charge to Bill - " + quota
            case .appStore(let quota):
                return "App Store - " + quota
            case .creditCard(let quota):
                return "Credit Card - " + quota
            }
        }
    }
    
    enum OverQuotaType {
        case expandMyStorage(_ checked: Bool = false)
        case deleteFiles(_ checked: Bool = false)
        case cancel(_ checked: Bool = false)
        case skip
        
        var text: String {
            switch self {
            case .expandMyStorage(let checked):
                return checked ? "Expand My Storage - Checked" : "Expand My Storage"
            case .deleteFiles(let checked):
                return checked ? "Delete Files - Checked" : "Delete Files"
            case .cancel(let checked):
                return checked ? "Cancel - Checked" : "Cancel"
            case .skip:
                return "Skip"
            }
        }
    }
    
    enum TBMatikEvent {
        case notification
        case seeTimeline
        case share
        case close
        case letsSee
        case selectAlbum
        case deleteAlbum
        case deletePhoto
        
        var text: String {
            switch self {
            case .notification:
                return "Notification"
            case .seeTimeline:
                return "See Timeline"
            case .share:
                return "Each Channel"
            case .close:
                return "Home Page Card - Cancel"
            case .letsSee:
                return "Home Page Card - Lets see"
            case .selectAlbum:
                return "Album Click"
            case .deleteAlbum:
                return "Album Delete"
            case .deletePhoto:
                return "Photo Delete"
            }
        }
    }
    
    enum SupportFormSubjectLoginEvent {
        case subject1
        case subject2
        case subject3
        case subject4
        case subject5
        case subject6
        case subject7
        
        func text(isSupportForm: Bool) -> String {
            var text = isSupportForm ? "Subject - " : ""
            
            switch self {
            case .subject1: text += "Q1"
            case .subject2: text += "Q2"
            case .subject3: text += "Q3"
            case .subject4: text += "Q4"
            case .subject5: text += "Q5"
            case .subject6: text += "Q6"
            case .subject7: text += "Q7"
            }
            
            return text
        }
    }
    
    enum SupportFormSubjectSignUpEvent {
        case subject1
        case subject2
        case subject3
        
        func text(isSupportForm: Bool) -> String {
            var text = isSupportForm ? "Subject - " : ""
            
            switch self {
            case .subject1: text += "Q1"
            case .subject2: text += "Q2"
            case .subject3: text += "Q3"
            }
            
            return text
        }
    }
    
    enum CampaignEvent {
        case neverParticipated
        case notParticipated
        case limitIsReached
        case otherwise
        
        var text: String {
            switch self {
            case .neverParticipated:
                return "Never participated"
            case .notParticipated:
                return "Not participated to the campaign today"
            case .limitIsReached:
                return "Participation limit is reached"
            case .otherwise:
                return "Otherwise"
            }
        }
    }
    
    case empty
    case custom(String)
    
    case success
    case failure
    case result(Error?)
    case feedbackOpen
    case feedbackSend
    case download(FileType)
    case share(ShareType)
    case quotaUsed(Int)
    case clickPhoto
    case clickVideo
    case notificationRecieved
    case notificationRead
    case sort(SortedRules)
    case search(String) ///searched word
    case clickOtherTurkcellServices ///This event should be sent after each login (just send after login)
    //
    case importDropbox
    case importFacebook
    case importInstagram
    case importSpotify
    //
    case importSpotifyPlaylist
    case importSpotifyTrack
    case importSpotifyResult(String)
    //
    case uploadFile(FileType)
    //
    case crateStory(StoryEvent)
    //
    case faceRecognition(Bool)
    //
    case profilePhotoClick
    case profilePhotoUpload
    //
    case recognitionFace
    case recognitionObject
    case recognitionPlace
    //
    case contactDelete
    //
    case syncEveryMinute
    //
    case videoStartVideo
    case videoStartStroy
    //
    case serverError
    case paymentError(String)
    //
    case photosNever
    case photosWifi
    case photosWifiLTE
    case videosNever
    case videosWifi
    case videosWifiLTE
    case captcha(CaptchaEvent)
    case contact(ContactEvent)
    case plusAction(TabBarViewController.Action)
    case shareViaLink
    case shareViaApp(String)
    case login
    case update
    case yes
    case edit
    case save(isSuccess: Bool)
    case send
    case confirm
    case confirmStatus(isSuccess: Bool)
    case resendCode
    case codeResent(isSuccessed: Bool)
    case changeEmail
    case emailChanged(isSuccessed: Bool)
    case later
    case cancel
    case storyOrVideo
    case tbmatik(_ event: TBMatikEvent)
    case paymentType(_ type: QuotaPaymentType)
    case supportLoginForm(_ event: SupportFormSubjectLoginEvent, isSupportForm: Bool)
    case supportSignUpForm(_ event: SupportFormSubjectSignUpEvent, isSupportForm: Bool)
    case clickSecurityQuestion(number: Int)
    case campaign(CampaignEvent)
    case ok
    case viewPeopleAlbum
    case enableFIGrouping
    case becomePremium
    case proceedWithExistingPeople    
    case divorceButtonVideo
    case fileTypeOperation(FileType)
    case overQuota(_ event: OverQuotaType)
    case mobilePaymentAction(_ isContinue: Bool)
    case backWithCheck(_ isChecked: Bool)
    case isOn(_ isOn: Bool)
    
    var text: String {
        switch self {
        case .empty:
            return ""
        case .custom(let value):
            return value
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        case .result(let error):
            return error == nil ? "Success" : "Failure"
        case .feedbackOpen:
            return "Open"
        case .feedbackSend:
            return "Send"
        case .download(let fileType):
            return fileType.text
        case .share(let shareType):
            return shareType.text
        case .quotaUsed(let quota): ///80 90 95 100
            return "\(quota)"
        case .clickPhoto:
            return "Photo"
        case .clickVideo:
            return "Video"
        case .notificationRecieved:
            return "Received"
        case .notificationRead:
            return "Read"
        case .sort(let sortRule):
            switch sortRule {
            case .lettersAZ, .albumlettersAZ:
                return "A-Z"
            case .lettersZA, .albumlettersZA:
                return "Z-A"
            case .sizeAZ:
                return "smallest-first"
            case .sizeZA:
                return "largest-first"
            case .timeUp, .metaDataTimeUp, .timeUpWithoutSection:
                return "newest-first"
            case .timeDown, .metaDataTimeDown, .timeDownWithoutSection:
                return "oldest-first"
            }
        case .search(let searchText): ///searched word
            return searchText
        case .clickOtherTurkcellServices: ///This event should be sent after each login (just send after login)
            return TextConstants.NotLocalized.appName
        //
        case .importDropbox:
            return "Dropbox"
        case .importFacebook:
            return "Facebook"
        case .importInstagram:
            return "Instagram"
        case .importSpotify:
            return "Import from Spotify"
        //
        case .importSpotifyPlaylist:
            return "Import from Spotify Playlist"
        case .importSpotifyTrack:
            return "Import from Spotify Track"
        case .importSpotifyResult(let result):
            return "Import from Spotify \(result)"
        //
        case .uploadFile(let fileType):
            return fileType.text
        //
        case .crateStory(let storyEvent):
            return storyEvent.text
        //
        case .faceRecognition(let isOn):
            return isOn ? "True" : "False"
        //
        case .profilePhotoClick:
            return "Click"
        case .profilePhotoUpload:
            return "Upload"
        //
        case .recognitionFace:
            return "Face"
        case .recognitionObject:
            return "Object"
        case .recognitionPlace:
            return "Place"
        //
        case .contactDelete:
            return "Delete"
        //
        case .syncEveryMinute:
            return "Every Minute"
        //
        case .videoStartVideo:
            return "video"
        case .videoStartStroy:
            return "story"
        //
        case .serverError:
            return "Server error"// \(errorCode)"
        case .paymentError(let paymentError):
            return "Definition(\(paymentError)"
        //
        case .photosNever:
            return "Photos - Never"
        case .photosWifi:
            return "Photos - Wifi"
        case .photosWifiLTE:
            return "Photos - Wifi&LTE"
        case .videosNever:
            return "Videos - Never"
        case .videosWifi:
            return "Videos - Wifi"
        case .videosWifiLTE:
            return "Videos - Wifi&LTE"
        case .captcha(let captchaEvent):
            return captchaEvent.text
        case .contact(let contantEvent):
            return contantEvent.text
        case .plusAction(let action):
            switch action {
            case .createAlbum:
                return "Create Album"
            case .createFolder:
                return "New Folder"
            case .createStory:
                return "Create Story"
            case .takePhoto:
                return "Use Camera"
            case .upload:
                return "Upload"
            case .uploadFromApp:
                return "Upload from \(TextConstants.NotLocalized.appName)"
            case .uploadFromAppFavorites:
                return "Upload from \(TextConstants.NotLocalized.appName) Favorites"
            case .importFromSpotify:
                return "Import From Spotify"
            }
        case .shareViaLink:
            return "Share via Link"
        case .shareViaApp(let appName):
            return appName
        case .login:
            return "Login"
        case .update:
            return "Update"
        case .yes:
            return "Yes"
        case .edit:
            return "Edit"
        case .save(isSuccess: let isSuccess):
            return "Save " + (isSuccess ? "Success" : "Failure")
        case .send:
            return "Send"
        case .confirm:
            return "Confirm"
        case .confirmStatus(isSuccess: let isSuccess):
            return "Confirm " + (isSuccess ? "Success" : "Failure")
        case .resendCode:
            return "Resend Code"
        case .codeResent(isSuccessed: let isSuccessed):
            return "Resend Code " + (isSuccessed ? "Success" : "Failure")
        case .changeEmail:
            return "Change Email"
        case .emailChanged(isSuccessed: let isSuccessed):
            return "Change Email " + (isSuccessed ? "Success" : "Failure")
        case .later:
            return "Later"
        case .cancel:
            return "Cancel"
        case .storyOrVideo:
            return "Story / Video"
        case .paymentType(let type):
            return type.text
        case .tbmatik(let event):
            return event.text
        case .supportLoginForm(let event, let isSupportForm):
            return event.text(isSupportForm: isSupportForm)
        case .supportSignUpForm(let event, let isSupportForm):
            return event.text(isSupportForm: isSupportForm)
        case .clickSecurityQuestion(let number):
            return "Q\(number)"
        case .campaign(let event):
            return event.text
        case .ok:
            return "OK"
        case .viewPeopleAlbum:
            return "View People Album"
        case .enableFIGrouping:
            return "Enable F/I Grouping"
        case .becomePremium:
            return "Become Premium"
        case .proceedWithExistingPeople:
            return "Proceed With Existing People"
        case .divorceButtonVideo:
            return "Divorce Button Video"
        case .fileTypeOperation(let fileType):
            return fileType.text
        case .overQuota(let type):
            return type.text
        case .mobilePaymentAction(let isContinue):
            return isContinue ? "Continue" : "Remind Me Later"
        case .backWithCheck(let isChecked):
            return isChecked ? "Back - Checked" : "Back"
        case .isOn(let isOn):
            return isOn ? "On" : "Off"
        }
    }
    
    static func getAutoSyncSettingEvent(autoSyncSettings: AutoSyncSetting) -> GAEventLabel {
        switch autoSyncSettings {
        case AutoSyncSetting(syncItemType: .photo, option: .never):
            return .photosNever
        case AutoSyncSetting(syncItemType: .photo, option: .wifiAndCellular):
            return .photosWifiLTE
        case AutoSyncSetting(syncItemType: .photo, option: .wifiOnly):
            return .photosWifi
        case AutoSyncSetting(syncItemType: .video, option: .never):
            return .videosNever
        case AutoSyncSetting(syncItemType: .video, option: .wifiAndCellular):
            return .videosWifiLTE
        case AutoSyncSetting(syncItemType: .video, option: .wifiOnly):
            return .videosWifi
        default:
            return .empty
        }
        
    }
    
}

enum GADementionsFields {
    case screenName
    case pageType
    case sourceType
    case loginStatus
    case loginType
    case platform
    case networkFixWifi
    case service
    case developmentVersion
    case paymentMethod
    case userID
    case operatorSystem ///Carrier Name should be sent for every page click.
    case faceImageStatus
    case userPackage
    case gsmOperatorType
    case connectStatus
    case deviceId
    case errorType
    case autoSyncState
    case autoSyncStatus
    case twoFactorAuth
    case spotify
    case dailyDrawleft
    case itemsCount(GAOperationType)
    
    var text: String {
        switch self {
        case .screenName:
            return "screenName"
        case .pageType:
            return "pageType"
        case .sourceType:
            return "sourceType"
        case .loginStatus:
            return "loginStatus"
        case .loginType:
            return "loginType"
        case .platform:
            return "platform"
        case .networkFixWifi:
            return "isWifi"
        case .service:
            return "service"
        case .developmentVersion:
            return "developmentVersion"
        case .paymentMethod:
            return "paymentMethod"
        case .userID:
            return "userId"
        case .operatorSystem:
            return "operatorSystem"
        case .faceImageStatus:
            return "facialRecognition"
        case .userPackage:
            return "userPackage"
        case .gsmOperatorType:
            return "gsmOperatorType"
        case .connectStatus:
            return "connectStatus"
        case .deviceId:
            return "deviceid"
        case .errorType:
            return "errorType"
        case .autoSyncState:
            return "AutoSync"
        case .autoSyncStatus:
            return "SyncStatus"
        case .twoFactorAuth:
            return "twoFactorAuthentication"
        case .spotify:
            return "connectStatus"
        case .dailyDrawleft:
            return "dailyDrawleft"
        case .itemsCount(let operationType):
            return operationType.itemsCountText
        }
    }
    
}

enum GAMetrics {
    case countOfUpload //After uploading of all files in the upload queue finihes, send the count of uploaded files
    case countOfDownload //After downloading finishes, send the count of downloaded files
    case playlistNumber
    case trackNumber
    case totalDraw
    
    case errorType
    
    var text: String {
        switch self {
        case .countOfUpload:
            return "countOfUpload"
        case .countOfDownload:
            return "countOfDownload"
        case .playlistNumber:
            return "playlistNumber"
        case .trackNumber:
            return "trackNumber"
        case .totalDraw:
            return "totalDraw"
        case .errorType:
            return "errorType"
        }
    }
}

enum GADementionValues {
    typealias ItemsOperationCount = (count: Int, operationType: GAOperationType)
    
    enum login {
        case gsm
        case email
        case rememberLogin
        case turkcellGSM
        var text: String {
            switch self {
            case .gsm:
                return "GSM no ile şifreli giriş"
            case .email:
                return "Email ile giriş"
            case .rememberLogin:
                return "Beni hatırla ile giriş"
            case .turkcellGSM:
                return "Header Enrichment (cellular) ile giriş"
            }
        }
    }
    
    enum loginError {
        case incorrectUsernamePassword
        case incorrectCaptcha
        case accountIsBlocked
        case signupRequired
        case turkcellPasswordDisabled
        case captchaRequired
        case networkError
        case serverError
        case unauthorized
        
        var text: String {
            switch self {
            case .incorrectUsernamePassword:
                return "INCORRECT_USERNAME_PASSWORD"
            case .incorrectCaptcha:
                return "INCORRECT_CAPTCHA"
            case .accountIsBlocked:
                return "ACCOUNT_IS_BLOCKED"
            case .signupRequired:
                return "SIGNUP_REQUIRED"
            case .turkcellPasswordDisabled:
                return "TURKCELL_PASSWORD_DISABLED"
            case .captchaRequired:
                return "CAPTCHA_REQUIRED"
            case .networkError:
                return "NETWORK_ERROR"
            case .serverError:
                return "SERVER_ERROR"
            case .unauthorized:
                return "UNAUTHORIZED"
            }
        }
    }
    
    enum signUpError {
        case invalidEmail
        case invalidPhoneNumber
        case emailAlreadyExists
        case gsmAlreadyExists
        case invalidPassword
        case tooManyOtpRequests
        case invalidOtp
        case tooManyInvalidOtpAttempts
        case networkError
        case serverError
        case incorrectCaptcha
        case captchaRequired
        case unauthorized
        
        var text: String {
            switch self {
            case .invalidEmail:
                return "INVALID_EMAIL"
            case .invalidPhoneNumber:
                return "PHONE_NUMBER_IS_INVALID"
            case .emailAlreadyExists:
                return "EMAIL_ALREADY_EXISTS"
            case .gsmAlreadyExists:
                return "GSM_ALREADY_EXISTS"
            case .invalidPassword:
                return "INVALID_PASSWORD"
            case .tooManyOtpRequests:
                return "TOO_MANY_OTP_REQUESTS"
            case .invalidOtp:
                return "INVALID_OTP"
            case .tooManyInvalidOtpAttempts:
                return "TOO_MANY_INVALID_OTP_ATTEMPTS"
            case .networkError:
                return "NETWORK_ERROR"
            case .serverError:
                return "SERVER_ERROR"
            case .incorrectCaptcha:
                return "INCORRECT_CAPTCHA"
            case .captchaRequired:
                return "CAPTCHA_REQUIRED"
            case .unauthorized:
                return "UNAUTHORIZED"
            }
        }
    }
    
    enum spotifyError {
        case importError
        case networkError

        var text: String {
            switch self {
            case .importError:
                return "SPOTIFY_IMPORT_ERROR"
            case .networkError:
                return "NETWORK_ERROR"
            }
        }
    }
    
    enum errorType {
        /// MyProfile
        case emptyEmail
        case phoneInvalidFormat
        case emailInvalidFormat
        case emailInUse
        case phoneInUse
        /// Two Factor Authentification
        case invalidOTPCode
        case invalidSession
        case invalidChallenge
        case tooManyInvalidAttempts
        /// Email Verification
        case accountNotFound
        case referenceTokenIsEmpty
        case expiredOTP
        case invalidEmail
        case invalidOTP
        case tooManyRequests
        /// Secret Question
        case invalidCaptcha
        case invalidId
        case invalidAnswer
        
        init?(with stringError: String) {
            switch stringError {
            case TextConstants.errorInvalidPhone:
                self = .phoneInvalidFormat
                
            case TextConstants.errorExistPhone:
                self = .phoneInUse
                
            case TextConstants.invalidOTP:
                self = .invalidOTP
                
            case "INVALID_OTP_CODE":
                self = .invalidOTPCode
                
            case TextConstants.expiredOTP:
                self = .expiredOTP
                
            case TextConstants.emptyEmail, HeaderConstant.emptyEmail:
                self = .emptyEmail
                
            case TextConstants.invalidEmail:
                self = .invalidEmail
                
            case TextConstants.errorInvalidEmail:
                self = .emailInvalidFormat
                
            case TextConstants.errorExistEmail:
                self = .emailInUse
                
            case "INVALID_SESSION":
                self = .invalidSession
                
            case "INVALID_CHALLENGE":
                self = .invalidChallenge
                
            case TextConstants.TOO_MANY_REQUESTS, "TOO_MANY_REQUESTS", TextConstants.tooManyRequests:
                self = .tooManyRequests
                
            case "TOO_MANY_INVALID_ATTEMPTS", TextConstants.tooManyInvalidAttempt:
                self = .tooManyInvalidAttempts
                
            case TextConstants.ACCOUNT_NOT_FOUND, TextConstants.noAccountFound:
                self = .accountNotFound
                
            case TextConstants.tokenIsMissing:
                self = .referenceTokenIsEmpty
                
            case "SEQURITY_QUESTION_ANSWER_IS_INVALID":
                self = .invalidAnswer
                
            case "SEQURITY_QUESTION_ID_IS_INVALID":
                self = .invalidId

            case "4001":
                self = .invalidCaptcha
                
            default:
                return nil
            }
        }
        
        var text: String {
            switch self {
            case .emptyEmail:
                return "EMPTY_E-MAIL_ERROR"
                
            case .phoneInvalidFormat:
                return "PHONE_NUMBER_INVALID_FORMAT_ERROR"
                
            case .emailInvalidFormat:
                return "EMAIL_INVALID_FORMAT_ERROR"
                
            case .emailInUse:
                return "EMAIL_IN_USE_ERROR"
                
            case .phoneInUse:
                return "PHONE_NUMBER_IN_USE_ERROR"
                
            case .invalidOTPCode:
                return "INVALID_OTP_CODE"
                
            case .invalidSession:
                return "INVALID_SESSION"
                
            case .invalidChallenge:
                return "INVALID_CHALLENGE"
                
            case .tooManyInvalidAttempts:
                return "TOO_MANY_INVALID_ATTEMPTS"
                
            case .accountNotFound:
                return "ACCOUNT_NOT_FOUND"
                
            case .referenceTokenIsEmpty:
                return "REFERENCE_TOKEN_IS_EMPTY"
                
            case .expiredOTP:
                return "EXPIRED_OTP"
                
            case .invalidEmail:
                return "INVALID_EMAIL"
                
            case .invalidOTP:
                return "INVALID_OTP"
                
            case .tooManyRequests:
                return "TOO_MANY_REQUESTS"
                
            case .invalidCaptcha:
                return "INVALID_CAPTCHA"
                
            case .invalidId:
                return "SEQURITY_QUESTION_ID_IS_INVALID"
                
            case .invalidAnswer:
                return "SEQURITY_QUESTION_ANSWER_IS_INVALID"
                
            }
        }
    }
}

enum GAOperationType {
    case hide
    case unhide
    case delete
    case trash
    case restore
    
    var eventActionText: String {
        switch self {
        case .hide:
            return "Hide"
        case .unhide:
            return "Unhide"
        case .delete:
            return "Delete"
        case .trash:
            return "Trash"
        case .restore:
            return "Restore"
        }
    }
    
    var popupEventActionText: String {
        switch self {
        case .hide:
            return "Hide Pop up"
        case .unhide:
            return "Unhide Pop up"
        case .delete:
            return "Delete Permanently Pop up"
        case .trash:
            return "Delete Pop up"
        case .restore:
            return "Restore Pop up"
        }
    }
    
    var confirmPopupEventActionText: String {
        switch self {
        case .hide:
            return "Hide Confirm Pop up"
        case .unhide:
            return "Unhide Confirm Pop up"
        case .delete:
            return "Delete Permanently Confirm Pop up"
        case .trash:
            return "Delete Confirm Pop up"
        case .restore:
            return "Restore Confirm Pop up"
        }
    }
    
    var itemsCountText: String {
        switch self {
        case .hide:
            return "countOfHiddenItems"
        case .unhide:
            return "countOfUnhiddenItems"
        case .delete:
            return "countOfDeletedItems"
        case .trash:
            return "countOfTrashedItems"
        case .restore:
            return "countOfRestoredItems"
        }
    }
    
    var checkingTypes: [GAEventLabel.FileType] {
        switch self {
        case .hide, .unhide:
            return [.photo, .video, .story]
        case .delete, .trash, .restore:
            return [.photo, .video, .story, .music, .document, .folder]
        }
    }
}
