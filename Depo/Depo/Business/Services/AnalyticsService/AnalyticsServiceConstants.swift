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
    ///
    case myStorage
    case changePassword
    ///
    case spotifyImport
    case spotifyImportPlaylistSelection
    case spotifyImportPlaylistDetails
    case spotifyImportProgress
    case spotifyImportResult
    case spotifyPlaylistDetails
    case spotifyPlaylists
    case spotifyAuthentification
    
    case info(FileType)
    
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
    
    var key: String {
        switch self {
        case .category:
            return "GAeventCategory"
        case .action:
            return "GAeventActions"
        case .label:
            return "GAeventLabel"
        }
    }
}

enum GAEventCantegory {
    case enhancedEcommerce
    case functions
    case videoAnalytics
    case errors
    case popUp
    
    var text: String {
        switch self {
        case .enhancedEcommerce:
            return "Enhanced E-Commerce"
        case .functions:
            return "Functions"
        case .videoAnalytics:
            return "Video Analytics"
        case .errors:
            return "Errors"
        case .popUp:
            return "POP UP"
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
        }
    }
}

enum GAEventLabel {
    enum FileType {
        case music
        case video
        case photo
        case document
        
        var text: String {
            switch self {
            case .music:
                return "Music"
            case .video:
                return "Video"
            case .photo:
                return "Photo"
            case .document:
                return "Document"
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
    
    case empty
    
    case success
    case failure
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
    //
    case login
    //
    case update
    case yes

        var text: String {
        switch self {
        case .empty:
            return ""
        case .success:
            return "Success"
        case .failure:
            return "Failure"
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
        //
        case .login:
            return "Login"
        //
        case .update:
            return "Update"
        case .yes:
            return "Yes"
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
        }
    }
    
}

enum GAMetrics {
    case countOfUpload //After uploading of all files in the upload queue finihes, send the count of uploaded files
    case countOfDownload //After downloading finishes, send the count of downloaded files
    case playlistNumber
    case trackNumber
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
        }
    }
}

enum GADementionValues {
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
}
