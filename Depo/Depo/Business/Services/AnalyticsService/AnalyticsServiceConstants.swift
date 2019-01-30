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

enum AnalyticsPackageProductParametrs {
    case itemName
    case itemID
    case price
    case itemBrand
    case itemCategory
    case itemVariant
    case index
    case quantity
    
    var text: String {
        switch self {
        case .itemName:
            return "AnalyticsParameterItemName"
        case .itemID:
            return "AnalyticsParameterItemID"
        case .price:
            return "AnalyticsParameterPrice"
        case .itemBrand:
            return "AnalyticsParameterItemBrand"
        case .itemCategory:
            return "AnalyticsParameterItemCategory"
        case .itemVariant:
            return "AnalyticsParameterItemVariant"
        case .index:
            return "AnalyticsParameterIndex"
        case .quantity:
            return "AnalyticsParameterQuantity"
        }
    }
}

enum AnalyticsPackageEcommerce {
    case items
    case itemList
    case transactionID
    case tax
    case priceValue
    case shipping
    
    var text: String {
        switch self {
        case .items:
            return "items"
        case .itemList:
            return "AnalyticsParameterItemList"
        case .transactionID:
            return "AnalyticsParameterTransactionID"
        case .tax:
            return "AnalyticsParameterTax"
        case .priceValue:
            return "AnalyticsParameterValue"
        case .shipping:
            return "AnalyticsParameterShipping"
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
    case phoneBookBackUp
    case phoneRestore
    //
    case importDropbox
    case importFacebook
    case importInstagram
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
            return "lifebox"
        case .phoneBookBackUp:
            return "Backup"
        case .phoneRestore:
            return "Restore"
        //
        case .importDropbox:
            return "Dropbox"
        case .importFacebook:
            return "Facebook"
        case .importInstagram:
            return "Instagram"
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
    case deviceId
    
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
        case .deviceId:
            return "deviceid"
        }
    }
    
}

enum GAMetrics {
    case countOfUpload //After uploading of all files in the upload queue finihes, send the count of uploaded files
    case countOfDownload //After downloading finishes, send the count of downloaded files
    var text: String {
        switch self {
        case .countOfUpload:
            return "countOfUpload"
        case .countOfDownload:
            return "countOfDownload"
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
                return "Login with Password - GSM"
            case .email:
                return "Login with Password – Email"
            case .rememberLogin:
                return "Remember Me Login"
            case .turkcellGSM:
                return "3G - LTE Login"
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
}
