//
//  Strings.swift
//  Depo
//
//  Created by Hady on 9/2/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

func localized(_ key: Strings) -> String {
    return key.localized
}

enum Strings: String, Localizable {

    // MARK: - Map
    case placesMapTitle = "places_map_title"
    case mapLocationDetailHeader = "map_location_detail_header"

    // MARK: - SignUp
    case signUpEnterVerificationCodeEmail = "signup_enter_verification_code_email"
    case signUpTooManyRequestsEmail = "signup_too_many_requests_email"
    case signUpTooManyRequestsMSISDN = "signup_too_many_requests_msisdn"
    case signUpEmailVerificationTitle = "signup_email_verification_title"
    case signUpEmailVerificationSubTitle = "signup_email_verification_subtitle"
    case signUpPhoneVerificationTitle = "signup_phone_verification_title"
    case signUpPhoneVerificationSubTitle = "signup_phone_verification_subtitle"

    // MARK: - Private Share
    case privateShareEmptyListError = "private_share_empty_list_error"

    // MARK: - Profile
    case profileRecoveryMail                        = "profile_recovery_mail"
    case profileRecoveryMailDescription             = "profile_recovery_mail_desc"
    case profileRecoveryMailHint                    = "profile_recovery_mail_hint"
    case profileRecoveryMailInfo                    = "profile_recovery_mail_info"
    case profileMailVerified                        = "profile_mail_verified"
    case profileVerifyButtonTitle                   = "profile_verify"
    case profileRecoveryEmailIsEmpty                = "profile_recovery_email_empty"
    case profileRecoveryEmailIsInvalid              = "profile_recovery_email_invalid"
    case profileRecoveryEmailIsSameWithAccountEmail = "profile_recovery_email_is_same_with_account_email"


    // MARK: - Reset Password
    case resetPasswordTitle                  = "reset_password"
    case resetPasswordCaptchaPlaceholder     = "enter_the_text_shown_in_the_image"
    case resetPasswordErrorCaptchaFormatText = "Please type the text"
    case resetPasswordErrorCaptchaText       = "This text doesn't match. Please try again"
    case resetPasswordYourAccountEmail       = "forgotMyPassword_your_account_email"
    case resetPasswordEnterYourAccountEmail  = "forgotMyPassword_enter_your_account_email"
    case resetPasswordInstructions           = "forgotMyPassword_instructions"
    case resetPasswordEnterValidEmail        = "forgotMyPassword_enter_valid_email"
    case resetPasswordButtonTitle            = "forgotMyPassword_reset_button"
    case resetPasswordChallenge1Header       = "forgotMyPassword_challange1_header"
    case resetPasswordChallenge1Body         = "forgotMyPassword_challange1_body"
    case resetPasswordChallenge2Header       = "forgotMyPassword_challange2_header"
    case resetPasswordChallenge2Body         = "forgotMyPassword_challange2_body"
    case resetPasswordPhoneNumber            = "forgotMyPassword_phone_number"
    case resetPasswordMail                   = "forgotMyPassword_mail"
    case resetPasswordRecoveryMail           = "forgotMyPassword_recovery_mail"
    case resetPasswordSecurityQuestion       = "forgotMyPassword_security_question"
    case resetPasswordContinueButton         = "forgotMyPassword_continue"
    case resetPasswordEmailPopupMessage      = "forgotMyPassword_email_popup_message"
    case resetPasswordCompleteButton         = "forgotMyPassword_password_complete"
    case resetPasswordSuccessMessage         = "forgotMyPassword_reset_success_message"
    case resetPasswordAccountNotFound        = "forgotMyPassword_account_not_found"
    case resetPasswordInvalidQuestionAnswer  = "forgotMyPassword_SQ_invalid_answer"
    case resetPasswordCantChangePassword     = "account_can_not_change_password"


    // MARK: - Delete Account
    case deleteAccountButton             = "DELETE_ACC_BTN"
    case deleteAccountDescription        = "DELETE_ACC_DESC"
    case deleteAccountFirstPopupTitle    = "DELETE_ACC_FIRST_POP_UP_TITLE"
    case deleteAccountFirstPopupMessage  = "DELETE_ACC_POP_UP_CONTENT_FIRST"
    case deleteAccountSecondPopupMessage = "DELETE_ACC_POP_UP_CONTENT_SECOND"
    case deleteAccountGSMInput           = "DELETE_ACC_INPUT_GSM"
    case deleteAccountPasswordInput      = "DELETE_ACC_INPUT_PASS"
    case deleteAccountPasswordError      = "DELETE_ACC_PASS_ERROR"
    case deleteAccountThirdPopupTitle    = "DELETE_ACC_THIRD_POP_UP_TITLE"
    case deleteAccountThirdPopupMessage  = "DELETE_ACC_POP_UP_CONTENT_THIRD"
    case deleteAccountFinalPopupTitle    = "DELETE_ACC_FINAL_POP_UP_TITLE"
    case deleteAccountFinalPopupMessage  = "DELETE_ACC_POP_UP_CONTENT_FINAL"
    case deleteAccountDeleteButton       = "DELETE_ACC_POP_UP_BTN_DELETE"
    case deleteAccountCancelButton       = "DELETE_ACC_POP_UP_BTN_CANCEL"
    case deleteAccountContinueButton     = "DELETE_ACC_POP_UP_BTN_CONTINUE"
    case deleteAccountConfirmButton      = "DELETE_ACC_POP_UP_BTN_CONFIRM"
    case deleteAccountCloseButton        = "DELETE_ACC_POP_UP_BTN_CLOSE"

    // MARK: - Change Album Cover
    case changeAlbumCoverSuccess  = "change_album_cover_snackbar_text"
    case changeAlbumCoverFail     = "change_album_cover_error_text"
    case changeAlbumCoverSetPhoto = "change_album_cover_set_photo"

    // MARK: - File Info
    case fileInfoLocation = "location_file_info"

    // MARK: - In-App Dark Mode
    case darkModePageTitle = "dark_mode_page_title_text"
    case darkModeTitleText = "dark_mode_title_text"
    case darkModeDarkText = "dark_mode_dark_text"
    case darkModeLightText = "dark_mode_light_text"
    case darkModeDefaultText = "dark_mode_default_text"
    
    // MARK: - Change person thumbnail
    case changePersonThumbnailSuccess = "change_album_person_snackbar_text"
    case changePersonThumbnailError = "change_album_person_error_text"
    case changePersonThumbnail = "change_person_photo"
    case changePersonThumbnailSetPhoto = "change_album_person_set_photo"
    
    // MARK: - Grace Period Banner
    case graceBannerText = "grace_banner_text"
    case gracePackageTitle = "grace_banner_title"
    case gracePackageDescription = "grace_banner_desc"
    case gracePackageExpirationDateTitle = "grace_expire_date"
    
    // MARK: - Public Share & Save & Download
    case publicShareSaveTitle = "save_to_my_lifebox"
    case publicShareDownloadTitle = "Download"
    case publicShareCancelTitle = "Cancel"
    case publicShareSaveSuccess = "save_to_my_lifebox_success"
    case publicShareSaveError = "save_to_my_lifebox_error"
    case publicShareMultiprocessError = "save_to_my_lifebox_multiprocess"
    case publicShareSameAccountError = "save_to_my_lifebox_same_account"
    case publicShareFileNotFoundError = "save_to_my_lifebox_file_not_found"
    case publicShareNotFoundPlaceholder = "save_to_my_lifebox_not_found_placeholder"
    case publicShareNoItemInFolder = "save_to_my_lifebox_folder_not_found"
    case publicShareDownloadMessage = "save_to_my_lifebox_download"
    case publicShareDownloadStorageErrorTitle =  "save_to_my_lifebox_full_storage_title"
    case publicShareDownloadStorageErrorDescription = "save_to_my_lifebox_full_storage_body"
    case publicShareDownloadErrorMessage = "An error is occurred!"

    // MARK: - Contact Restore
    case contactSyncStorageFailDescription = "contact_sync_storage_fail_desc"
    case contactSyncStorageFailContinueButton = "contact_sync_storage_fail_cont_button"
    
    // MARK: - Security Popup
    case securityPopupHeader = "security_popup_header"
    case securityPopupBody = "security_popup_body"
}
