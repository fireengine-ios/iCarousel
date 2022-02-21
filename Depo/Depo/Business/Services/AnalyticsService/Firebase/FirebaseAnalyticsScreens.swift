//
//  FirebaseAnalyticsScreens.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum AnalyticsAppScreens {
    ///authorization
    case loginScreen
    case signUpScreen
    case eula
    case forgotPassword
    case forgotPasswordV2
    case termsAndServices
    case signUpOTP
    case signUpMailOTP
    case doubleOTP
    case autosyncSettingsFirst
    case liveCollectRemember
    case identityVerification
    case identityVerification2Challenge
    case resetPassword
    case resetPasswordOTP
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
    case invitation
    case chatbot
    case invitationCampaignDetail
    ///contactSync
    case contactSyncDeleteDuplicates
    case contactSyncBackUp
    case contactSyncGeneral
    case contactSyncContactsListScreen
    case contactSyncBackupsScreen
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
    case verifyRecoveryEmailPopUp
    case changeEmailPopUp
    ///CredsUpdateCheckPopUp
    case periodicInfoScreen

    case info(FileType)
    
    case tbmatikPushNotification
    case tbmatikHomePageCard
    case tbmatikSwipePhoto(_ page: Int)
    
    case securityQuestion
    case securityQuestionSelect
    case validateSecurityQuestion
    
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
    
    case photoEditFilters
    case photoEditAdjustments
    case photoEditGif
    case photoEditSticker
    
    case sharedWithMe
    case sharedByMe
    case whoHasAccess
    case sharedAccess
    case shareInfo
    
    case saveToMyLifebox
    
    var name: String {
        switch self {
        ///authorization
        case .welcomePage(let welcomeNumber):
            return "Welcome Page -\(welcomeNumber)"
        case .loginScreen:
            return "Login"
        case .signUpScreen:
            return "Signup"
        case .eula:
            return "EULA"
        case .liveCollectRemember:
            return "Live Collect Remember"
        case .forgotPassword:
            return "Forget Password"
        case .forgotPasswordV2:
            return "Reset Password Start"
        case .termsAndServices:
            return "Eula"
        case .signUpOTP:
            return "OTP - Signup"
        case .signUpMailOTP:
            return "MailOTP - Signup"
        case .doubleOTP:
            return "OTP - DoubleOptIn"
        case .autosyncSettingsFirst:
            return "First Auto Sync Screen"
        case .autoSyncSettings:
            return "Auto Sync"
        case .invitation:
            return "Invitation"
        case .invitationCampaignDetail:
            return "Invitation Campaign Detail"
        case .chatbot:
            return "Chatbot"
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
        case .contactSyncDeleteDuplicates:
            return "Delete Duplicate"
        case .contactSyncBackUp:
            return "Contact Back Up"
        case .contactSyncGeneral:
            return "Contacts Sync"
        case .contactSyncContactsListScreen:
            return "ContactListScreen"
        case .contactSyncBackupsScreen:
            return "BackupsScreen"
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
        case .verifyRecoveryEmailPopUp:
            return "Recovery Email verification - Popup"
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
        case .validateSecurityQuestion:
            return "Security Question - Validate"
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
        case .photoEditFilters:
            return "Filter Main Screen"
        case .photoEditAdjustments:
            return "Adjust Main Screen"
        case .photoEditGif:
            return "Gif Main Screen"
        case .photoEditSticker:
            return "Sticker Main Screen"
        case .sharedWithMe:
            return "Shared with Me"
        case .sharedByMe:
            return "Shared by Me"
        case .whoHasAccess:
            return "Who has Access"
        case .sharedAccess:
            return "Access"
        case .shareInfo:
            return "Private Share Info"

        case .identityVerification:
            return "Verification Method I"
        case .identityVerification2Challenge:
            return "Verification Method 2"
        case .resetPassword:
            return "Reset Password"
        case .resetPasswordOTP:
            return "OTP – Reset Password"
        case .saveToMyLifebox:
            return "Save to My lifebox"
        }
    }
}
