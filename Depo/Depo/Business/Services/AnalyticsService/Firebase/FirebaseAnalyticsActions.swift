//
//  FirebaseAnalyticsActions.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

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
    case uploadProcess
    case story
    case freeUpSpace
    case faceRecognition
    case profilePhoto
    case sync
    case recognition
    case contact
    case deleteContactBackups
    case startVideo ///or story
    case everyMinuteVideo
    case serviceError
    case paymentErrors
    case photopickAnalysis
    case firstAutoSync
    case settingsAutoSync
    case captcha
    case photopickShare
    case contactOperation(GAEventLabel.ContactEvent)
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
    case quotaLimitFullContactRestore
    case mobilePaymentPermission
    case mobilePaymentExplanation
    case openMobilePaymentPermission
    
    case fileOperation(GAOperationType)
    case fileOperationPopup(GAOperationType)
    case discardChanges
    case save
    case saveAsCopy
    
    case openWithWidget
    case widgetOrder
    
    case endShare
    case leaveShare
    case contactPermission
    case rename
    case createNewFolder
    case upload
    case preview
    case removeUser
    case changeRoleFromEditorToViewer
    case changeRoleFromViewerToEditor
    case duration
    case message
    case invitation
    case photoPrint

    case verificationMethod
    case verificationMethod2Challenge
    case forgotPassword
    case forgotPassword2
    case securityQuestion
    case otpSignup
    case resetPassword
    case otpResetPassword

    case deleteMyAccountStep1
    case deleteMyAccountStep2
    case deleteMyAccountStep3

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
        case .uploadProcess:
            return "Upload Process"
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
            case .deleteDuplicates:
                return "Delete Duplicate"
            case .deleteBackup:
                return "Delete Backup"
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
        case .quotaLimitFullContactRestore:
            return "Quota Limit Full Contact Restore"
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
        case .deleteContactBackups:
            return "Delete Backup"
        case .discardChanges:
            return "Discart Changes"
        case .save:
            return "Save"
        case .saveAsCopy:
            return "Save as copy"
        case .openWithWidget:
            return "Opened with Widget"
        case .widgetOrder:
            return "Widget Order"
        case .endShare:
            return "End Share"
        case .leaveShare:
            return "Leave Share"
        case .contactPermission:
            return "Contact Permission"
        case .rename:
            return "Rename"
        case .createNewFolder:
            return "Create New Folder"
        case .upload:
            return "Upload"
        case .preview:
            return "Preview"
        case .removeUser:
            return "Remove User"
        case .changeRoleFromViewerToEditor:
            return "Role Change from Viever to Editor"
        case .changeRoleFromEditorToViewer:
            return "Role Change from Editor to Viewer"
        case .duration:
            return "Duration"
        case .message:
            return "Message"
        case .invitation:
            return "Invitation"
        case .photoPrint:
            return "PhotoPrint"
        case .verificationMethod:
            return "Verification Method"
        case .verificationMethod2Challenge:
            return "Verification Method 2"
        case .forgotPassword:
            return "Forgot Password"
        case .forgotPassword2:
            return "Forgot Password 2"
        case .securityQuestion:
            return "Security Question"
        case .otpSignup:
            return "OTP - Signup"
        case .resetPassword:
            return "Reset Password"
        case .otpResetPassword:
            return "OTP – Reset Password"
        case .deleteMyAccountStep1:
            return "Delete My Account Step1"
        case .deleteMyAccountStep2:
            return "Delete My Account Step2"
        case .deleteMyAccountStep3:
            return "Delete My Account Step3"
        }
    }
}
