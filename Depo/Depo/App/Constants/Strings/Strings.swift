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
    case deleteAccountButton              = "DELETE_ACC_BTN"
    case deleteAccountDescription         = "DELETE_ACC_DESC"
    case deleteAccountFirstPopupTitle     = "DELETE_ACC_FIRST_POP_UP_TITLE"
    case deleteAccountFirstPopupMessage   = "DELETE_ACC_POP_UP_CONTENT_FIRST"
    case deleteAccountSecondPopupMessage  = "DELETE_ACC_POP_UP_CONTENT_SECOND"
    case deleteAccountGSMInput            = "DELETE_ACC_INPUT_GSM"
    case deleteAccountPasswordInput       = "DELETE_ACC_INPUT_PASS"
    case deleteAccountPasswordError       = "DELETE_ACC_PASS_ERROR"
    case deleteAccountThirdPopupTitle     = "DELETE_ACC_THIRD_POP_UP_TITLE"
    case deleteAccountThirdPopupMessage   = "DELETE_ACC_POP_UP_CONTENT_THIRD"
    case deleteAccountFinalPopupTitle     = "DELETE_ACC_FINAL_POP_UP_TITLE"
    case deleteAccountFinalPopupMessage   = "DELETE_ACC_POP_UP_CONTENT_FINAL"
    case deleteAccountDeleteButton        = "DELETE_ACC_POP_UP_BTN_DELETE"
    case deleteAccountCancelButton        = "DELETE_ACC_POP_UP_BTN_CANCEL"
    case deleteAccountContinueButton      = "DELETE_ACC_POP_UP_BTN_CONTINUE"
    case deleteAccountConfirmButton       = "DELETE_ACC_POP_UP_BTN_CONFIRM"
    case deleteAccountCloseButton         = "DELETE_ACC_POP_UP_BTN_CLOSE"

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
    case securityPopupHeader                   = "security_popup_header"
    case securityPopupBody                     = "security_popup_body"
    case securityPopupWarningHeader            = "security_popup_warning_header"
    case securityPopupEmailWarning             = "security_popup_warning_body1"
    case securityPopupSecurityQuestionWarning  = "security_popup_warning_body2"
    case securityPopupWarningFooter            = "security_popup_warning_footer"
    case securtiyPopupWarningSettingsButton    = "Settings"
    case securtiyPopupWarningContinueButton    = "warning_popup_print_redirect_proceed_button"
    
    // MARK: - Apple/Google Login
    case connectWithGoogle                        = "on_boarding_btn_google_login"
    case connectWithApple                         = "on_boarding_btn_apple_login"
    case onboardingButtonOr                       = "on_boarding_or"
    case googleUserExistBody                      = "google_login_user_exists_body"
    case appleUserExistBody                       = "apple_login_user_exists_body"
    case googlePasswordRequired                   = "settings_google_password_required"
    case applePasswordRequired                    = "settings_apple_password_required"
    case settingsAppleGoogleTitle                 = "settings_google_apple_connect"
    case settingsGoogleMatch                      = "settings_google"
    case settingsAppleMatch                       = "settings_apple"
    case settingsChangePasswordGoogleWarning      = "settings_change_password_google_warning"
    case settingsChangePasswordAppleWarning       = "settings_change_password_apple_warning"
    case settingsChangePasswordAppleGoogleWarning = "settings_change_password_apple_google_warning"
    case settingsSetNewPassword                   = "settings_googe_apple_set_password"
    case settingsGoogleAppleMailMatchError        = "settings_google_apple_mail_match_error"
    case settingsGoogleAppleInvalidToken          = "googe_apple_login_invalid_token"
    case settingsGoogleAppleEmptyMailError        = "settings_google_apple_empty_mail_error"
    case externalAuthError                        = "password_change_external_auth_required_error"
    case forgotPasswordRequiredError              = "password_change_forgot_password_required_error"
    case emailDomainNotAllowed                    = "apple_login_show_mail_warning"
    
    // MARK: - KVKK Permission
    case kvkkToggleTitle   = "kvkk_toggle_desc"
    case kvkkToggleText    = "kvkk_toggle_text"
    case kvkkFirmsLink     = "kvkk_firms_link"
    case kvkkHyperlinkText = "ETK_KVKK_Izin_Politikasi"

    // MARK: - TabBarCards
    case syncing = "syncing"
    case downloading = "downloading"
    // MARK: - IAP Intro Offers
    case iapIntroOfferFreeTrial  = "iap_intro_offer_free_trial"
    case iapIntroOfferPayAsYouGo = "iap_intro_offer_pay_as_you_go"
    case iapIntroOfferPayUpFront = "iap_intro_offer_pay_up_front"
    
    // MARK: - Paycell Campaign
    case paycellCreateLink          = "title_paycell_createlink"
    case paycellLinkTitle           = "title_paycell_link"
    case paycellCampaignDetailTitle = "title_paycell_campaign"
    case paycellCampaignTitle       = "settings_item_paycell"
    case paycellEarnedTitle         = "title_paycell_total"
    case paycellEarnedSubtitle      = "title_paycell_subtitle"
    case paycellAcceptedFriends     = "title_paycell_friends"
    case paycellShareMessage        = "paycell_share_message"
    
    // MARK: - Setting Menu Items
    case notificationMenuItem       = "notification_menu_item"
    
    // MARK: - All Files
    case allFilesNoMusicButtonText    = "Start adding your music"
    case allFilesNoDocumentButtonText = "Start adding your documents"
    
    // MARK: - Facelift
    case forYouThrowbackTitle = "foryou_throwback"
    case forYouMyAlbumsTitle = "foryou_myalbums"
    case forYouAnimationsTitle = "foryou_animations"
    case forYouMyAnimationsTitle = "foryou_myanimations"
    case forYouCollagesTitle = "foryou_collages"
    case forYouMyCollagesTitle = "foryou_my_collages"
    case forYouEmptyAlbumsDesc = "foryou_no_album_warn"
    case forYouEmptyPhotopickDesc = "foryou_no_photopick_warn"
    case forYouEmptyPhotopickButton = "foryou_try_photopick"
    case forYouEmptyStoryDesc = "foryou_no_story_warn"
    case forYouSeeAll = "foryou_see_all"
    case tabBarForYouTitle = "tabbar_foryou"
    case tabBarDiscoverTitle = "tabbar_discover"
    case changePasswordInputTitle = "change_pass_mail_or_phone"
    case becomePremiumBannerDesc = "mystorage_become_premium"
    
    case trashBin = "trash_bin"
    
    case emptyGalleryNoPhoto = "empty_gallery_no_photo"
    case emptyGalleryNoVideo = "empty_gallery_no_video"
    case emptyGalleryNoSync = "empty_gallery_no_sync"
    case emptyGalleryNoUnsync = "empty_gallery_no_unsync"
    
    case subscriptionOfferCancelButton = "subscription_offer_cancel_button"
    
    case deleteAll = "Delete all"
    case selectMode = "notification_buttom_sheet_select_mode"
    case onlyUnread = "notification_buttom_sheet_only_unread"
    case onlyAlert = "notification_buttom_sheet_show_alerts"
    
    case notificationsNoNotification = "notifications_no_notification"
    
    // MARK: - Create Collage
    
    case createCollageSelectPhotoMainTitle = "create_collage_select_photo"
    case createCollagePreviewMainTitle = "create_collage_preview_main"
    case createCollageDualCollage = "create_collage_dual"
    case createCollageTripleCollage = "create_collage_triple"
    case createCollageQuadCollage = "create_collage_quad"
    case createCollageMultipleCollage = "create_collage_multiple"
    case createCollageAllCollage = "create_collage_all"
    case createCollageInfoLabel = "create_collage_info_label"
    case createCollageLabel = "create_collage"
    case createCollageInfoLabelNew = "collage_create_info"
    
    // MARK: - Only Office
    case createWord = "Create_Word"
    case createExcel = "Create_Cell"
    case createPowerPoint = "Create_Slide"
    case createDocumentPopup = "Create_Document_Popup"
    
    case officeFilterAll = "Office_Filter_All"
    case officeFilterPdf = "Office_Filter_PDF"
    case officeFilterWord = "Office_Filter_Document"
    case officeFilterCell = "Office_Filter_SpreedSheet"
    case officeFilterSlide = "Office_Filter_Presentation"
}
