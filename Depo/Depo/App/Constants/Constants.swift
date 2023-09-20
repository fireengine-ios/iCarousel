//
//  Constants.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

struct TextConstants {
    
    struct NotLocalized {
        static let facebookLoginCanceled = "FB Login canceled"
        static let facebookLoginFailed = "FB Login failed"
        static let instagramLoginCanceled = "Instagram Login canceled"
        static let termsOfUseLink = "termsOfUseLink"
        static let termsAndUseEtkLinkTurkcellAndGroupCompanies = "terms_and_use_etk_link_1"
        static let privacyPolicyConditions = "privacy_policy_conditions_link_1"
        static let termsAndUseEtkLinkCommercialEmailMessages = "terms_and_use_etk_link_2"
        static let mobilePaymentPermissionLink = "mobilePaymentPermissionLink";
        static let FAQ = "frequently_asked_questions"
        static let feedbackEmail = "info@mylifebox.com"
        static let termsOfUseGlobalDataPermLink1 = "global_data_permission_link"
        static let wrongVideoData = "Wrong video data"
        static let wrongImageData = "Wrong image data"
        static let permissionsPolicyLink = "ETK_KVKK_Izin_Politikasi"
        
        static let appNameLowercased: String = {
            #if LIFEDRIVE
                return "billo"
            #else
                return "lifebox"
            #endif
        }()
        private static let appNameUppercased = appNameLowercased.uppercased()
        private static let appNameCapitalized = appNameLowercased.capitalized
        
        static let appName = appNameUppercased
        static let appNameGA = appNameCapitalized
        static let appNameMailSubject = appNameCapitalized + " / "
        
        static let dataProtectedAndDeviceLocked = "Data is protected and device is locked"
        
        private init() {}
    }
    
    static func digicelCancelText(for key: String) -> String {
        return NSLocalizedString(key, tableName: "OurLocalizable", bundle: .main, value: packageDefaultCancelText, comment: "")
    }
    
    static let itroViewGoToRegisterButtonText = localized("Start using Lifebox now!")
    static let introViewGoToLoginButtonText = localized("Login")
    
    static let introTitle = localized("billo_intro_title")
    static let introSubTitle = localized("billo_intro_subtitle")
    static let introCreateAccountButton = localized("billo_intro_create_account_button")
    static let introLoginButton = localized("billo_intro_login_button")

    static let localFilesBeingProcessed = localized("localFilesBeingProcessed")
    
    static let registrationCellTitleEmail = localized("E-MAIL")
    static let registrationCellTitleGSMNumber = localized("GSM Number")
    static let registrationCellTitlePassword = localized("Password")
    static let registrationCellTitleReEnterPassword = localized("Re-Enter Password")
    static let registrationCellPlaceholderPhone = localized(" You have to fill in GSM number")
    static let registrationCellPlaceholderEmail = localized(" You have to fill in your mail")
    static let notCorrectEmail = localized("Please enter valid Email")
    static let notValidEmail = localized("Email field is invalid")
    static let registrationCellPlaceholderPassword = localized(" You have to fill in a password")
    static let registrationCellPlaceholderReFillPassword = localized(" You have to fill in a password")
    static let registrationTitleText = localized("Register to lifebox and get a 5 GB of storage for free!")
    static let registrationNextButtonText = localized("Next")
    static let registrationResendButtonText = localized("Resend")
    static let optInNavigarionTitle = localized("Verify Your Purchase")
    static let confirmPhoneOptInNavigarionTitle = localized("Confirm Your Phone")
    static let phoneVerificationMainTitleText = localized("Verify Your Phone Number")
    static let phoneVerificationInfoTitleText = localized("Enter the verification code")
    static let phoneVerificationNonValidCodeErrorText = localized("Verification code is invalid. \n Please try again.")
    static let phoneVerificationResendRequestFailedErrorText = localized("Request failed \n Please try again")
    static let loginScreenCredentialsError = localized("Login denied. Please check your credentials.")
    static let loginScreenInvalidCaptchaError = localized("This text doesn't match. Please try again.")
    static let loginScreenInvalidLoginError = localized("Please enter a valid login.")
    static let loginScreenAuthWithTurkcellError = localized("Authentication with Turkcell Password is disabled for the account")
    static let loginScreenNeedSignUpError = localized("You don't have any lifebox account. Please signup before using the application")
    static let registrationPasswordError = localized("Please set a password including nonconsecutive letters and numbers, minimum 6 maximum 16 characters.")
    static let hourBlockLoginError = localized("You have performed too many attempts. Please try again later.")
    static let registrationMailError = localized("Please check the e-mail address.")
    static let registrationPasswordNotMatchError = localized("Password fields do not match.")
    static let loginScreenServerError = localized("Temporary error occurred. Please try again later.")
    
    static let registrationEmailPopupTitle = localized("E-mail Usage Information")
    static let registrationEmailPopupMessage = localized("You are finalizing the process with %@ e-mail address. We will be using this e-mail for password operations and site notifications")
    static let authificateCaptchaRequired = localized("You have successfully registered, please log in with your credentials")
    static let captchaRequired = localized("Please enter the text below")
    static let tooManyInvalidAttempt = localized("too_many_invalid_attempt")
    static let twoFactorAuthenticationNewDeviceReason = localized("extra_auth_new_device_reason")
    static let twoFactorAuthenticationAccountSettingReason = localized("extra_auth_account_setting_reason")
    static let twoFactorAuthenticationNavigationTitle = localized("extra_auth_account_navigation_title")
    static let twoFactorAuthenticationDescribeLabel = localized("extra_auth_account_describe_label")
    static let twoFactorAuthenticationChooseTypeLabel = localized("extra_auth_account_choose_type")
    static let twoFactorAuthenticationPhoneNumberCell = localized("extra_auth_account_phone_cell")
    static let twoFactorAuthenticationEmailCell = localized("extra_auth_account_email_cell")
    
    // MARK: - Registration Error Messages
    static let invalidMailErrorText = localized("Please enter a valid email address.")
    static let invalidPhoneNumberText = localized("Please enter a valid GSM number.")
    static let invalidPasswordText = localized("Please enter your password")
    static let invalidPasswordMatchText = localized("Password fields do not match")
    static let signUpErrorPasswordLengthIsBelowLimit = localized("sing_up_error_password_length_is_below_limit")
    static let signUpErrorPasswordLengthExceeded = localized("sing_up_error_password_length_exceeded")
    static let signUpErrorSequentialCharacters = localized("sing_up_error_sequential_characters")
    static let signUpErrorSameCharacters = localized("sing_up_error_same_characters")
    static let signUpErrorUppercaseMissing = localized("sing_up_error_uppercase_missing")
    static let signUpErrorLowercaseMissing = localized("sing_up_error_lowercase_missing")
    static let signUpErrorNumberMissing = localized("sing_up_error_number_missing")
    static let signUpErrorUnauthorized = localized("sing_up_error_unauthorized")
    // MARK: -
    static let termsAndUsesTitle = localized("eula_title")
    static let termsAndUsesApplyButtonText = localized("Accept  Terms")
    static let termsAndUseTextFormat = localized("<html><body text=\"#FFFFFF\" face=\"Bookman Old Style, Book Antiqua, Garamond\" size=\"5\">%@</body></html>")
    static let termsAndUseStartUsingText = localized("Get Started")
    static let termsAndUseCheckboxText = localized("I have read and accepted terms of use")
    static let termsAndUseEtkCheckbox = localized("terms_and_use_etk_checkbox")
    static let termsAndUseEtkCheckboxHeader = localized("terms_and_use_etk_checkbox_header")
    static let termsAndUseIntroductionCheckbox = localized("terms_and_use_introduction_checkbox")
    static let privacyPolicy = localized("privacy_policy")
    static let termsAndUseEtkLinkTurkcellAndGroupCompanies = localized("terms_and_use_etk_link_turkcell_and_group_companies")
    static let privacyPolicyCondition = localized("privacy_policy_condition")
    static let privacyPolicyHeadLine = localized("privacy_policy_head_line")
    static let termsAndUseEtkLinkCommercialEmailMessages = localized("terms_and_use_etk_link_commercial_email_messages")
    static let termsAndUseCheckboxErrorText = localized("You need to confirm the User Agreement to continue.")
    static let commercialEmailMessages = localized("commercial_email_messages")
    static let termsOfUseGlobalPermScreenTitle = localized("global_permission_screen_title")
    static let termsOfUseGlobalPermHeader = localized("global_permission_header")
    static let termsOfUseGlobalDataPermCheckbox = localized("global_data_permission_agreement")
    static let termsOfUseGlobalDataPermLinkSeeDetails = localized("global_data_permission_link")
    static let etkHTMLText = localized("etk_html")
    
    static let loginTitle = localized("Login")
    static let loginTableTitle = localized("Register to lifebox and get a 5 GB of storage for free!")
    static let loginCantLoginButtonTitle = localized("I can't login")
    static let loginRememberMyCredential = localized("Remember my credentials")
    static let loginCellTitleEmail = localized("E-Mail or GSM Number")
    static let loginCellTitlePassword = localized("Password")
    static let loginCellEmailPlaceholder = localized( "You have to fill in your mail or GSM Number")
    static let loginCellPasswordPlaceholder = localized("You have to fill in a password")
    static let loginFAQButton = localized("login_faq")
    static let signUpPasswordRulesLabel = localized("sign_up_password_rules")
    static let alreadyHaveAccountTitle = localized("Already have an account?")
    
    static let autoSyncNavigationTitle = localized("Auto Sync")
    static let autoSyncFromSettingsTitle = localized("Lifebox can sync your files automatically.")
    static let autoSyncTitle = localized("Lifebox can sync your files automatically. Would you like to have this feature right now?")
    static let autoSyncCellPhotos = localized("Photos")
    static let autoSyncCellVideos = localized("Videos")
    static let autoSyncCellAutoSync = localized("Auto Sync")
    static let autoSyncCellAlbums = localized("auto_sync_album_items")
    static let autoSyncCellAlbumsDescription = localized("auto_sync_albums_description")
    static let autoSyncStartUsingLifebox = localized("Let’s start using Lifebox")
    static let autoSyncskipForNowButton = localized("Skip for now")
    static let autoSyncAlertTitle = localized("Skip setting Auto-Sync?")
    static let autoSyncAlertText = localized("You’re skipping auto-sync setting turned off. You can activate this later in preferences.")
    static let autoSyncAlertYes = localized("Skip Auto-Sync")
    static let autoSyncAlertNo = localized("Cancel")
    static let welcome1Info = localized("Welcome1Info")
    static let welcome1SubInfo = localized("Welcome1SubInfo")
    
    static let autoSyncSyncOverTitle = localized("Sync over data plan?")
    static let autoSyncSyncOverMessage = localized("Syncing files using cellular data could incur data charges")
    static let autoSyncSyncOverOn = localized("Turn-on Sync")
    
    static let registerTitle = localized("Sign Up")
    
    static let resetPasswordTitle = localized("reset_password")
    static let resetPasswordInfo = localized("to_reset_your_accounts_password_we_will_send_a_password_reset_link_to_your_account_email")
    
    static let resetPasswordSendPassword = localized("send_link")
    static let resetPasswordEmailTitle = localized("your_account_email")
    static let resetPasswordEmailPlaceholder = localized("enter_your_account_email")
    static let resetPasswordCaptchaPlaceholder = localized("enter_the_text_shown_in_the_image")
    
    static let forgotPasswordSentEmailAddres = localized("Your password is sent to your e-mail address")
    
    static let captchaPlaceholder = localized("Type the text")
    
    static let checkPhoneAlertTitle = localized("Error")
    
    static let contactConfirmDeleteTitle = localized("Are you sure you want to delete?")
    static let contactConfirmDeleteText = localized("This contact will be deleted from your contacts.")
    static let enterSecurityCode = localized("enter_security_code")
    static let enterCodeToGetCodeOnPhone = localized("enter_code_get_code_on_phone")
    static let timeIsUpForCode = localized("time_is_up_for_code")
    static let resendCode = localized("resend_code")
    static let absentContactsForBackup = localized("ubsent_contacts")
    static let absentContactsInLifebox = localized("ubsent_contacts_in_lifebox")
    static let contactBackupHistoryNavbarTitle = localized("contact_phase2_history_navbar_title")
    static let contactBackupHistoryHeader = localized("contact_phase2_history_header")
    static let contactBackupHistoryRestoreButton = localized("contact_phase2_restore_button")
    static let contactBackupHistoryDeleteButton = localized("contact_phase2_delete_button")
    static let contactBackupHistoryRestorePopUpTitle = localized("contact_phase2_restore_popup_title")
    static let contactBackupHistoryDeletePopUpTitle = localized("contact_phase2_delete_popup_title")
    static let contactBackupHistoryRestorePopUpMessage = localized("contact_phase2_restore_popup_message")
    static let contactBackupHistoryDeletePopUpMessage = localized("contact_phase2_delete_popup_message")
    static let contactBackupHistoryCellTitle = localized("contact_phase2_history_cell_title")
    static let contactBackupHistoryCellContactList = localized("contact_phase2_history_cell_Contact_List")
    static let errorAlert = localized("Error")
    static let errorAlerTitleBackupAlreadyExist = localized("Overwrite backup?")
    static let errorAlertTextNoDuplicatedContacts = localized("You have no duplicated contacts!")
    static let errorAlertTextBackupAlreadyExist = localized("You have already a backup. Do you want to overwrite the existing one?")
    static let errorAlertNopeBtnBackupAlreadyExist = localized("Nope")
    static let errorAlertYesBtnBackupAlreadyExist = localized("Yes")
    static let errorErrorToGetAlbums = localized("Failed to get albums")
    
    static let forgotPasswordErrorNotRegisteredText = localized("This e-mail address is not registered. Please try again")
    static let forgotPasswordErrorCaptchaText = localized("This text doesn't match. Please try again")
    static let forgotPasswordEmptyEmailText = localized("Please check the e-mail address")
    static let forgotPasswordErrorEmailFormatText = localized("Please enter a valid email adress")
    static let forgotPasswordErrorCaptchaFormatText = localized("Please type the text")
    
    // MARK: - DetailScreenError
    
    static let theFileIsNotSupported = localized("The file isn't supported")
    static let warning = localized("Warning")
    
    // MARK: - Turkcell Security
    
    static let turkcellSecurityWaringPasscode = localized("TurkcellSecurityPasscodeWarningText")
    static let turkcellSecurityWaringAutologin = localized("TurkcellSecurityAutologinText")
    static let passcodeEneblingwWithActivatedTurkcellSecurity = localized("PasscodeActivationWhileTurkcellActivated")
    // MARK: - Search
    

    static let search = localized("Search")
    static let searchRecentSearchTitle = localized("Recent Searches")
    static let searchSuggestionsTitle = localized("Suggestions")
    static let searchNoFilesToCreateStoryError = localized("No files to create a story")
    
    static let noFilesFoundInSearch = localized("No results found for your query.")
    
    // MARK: - Sync Contacts
    
    static let backUpMyContacts = localized("Back Up My Contacts")
    static let manageContacts = localized("Manage Contacts")
    
    // MARK: - Authification Cells
    static let showPassword = localized("Show")
    static let hidePassword = localized("Hide")
    
    
    // MARK: - button navigation name
    static let chooseTitle = localized("Choose")
    static let nextTitle = localized("Next")
    static let backTitle = localized("Back")
    
    // MARK: - home buttons title
    static let homeButtonAllFiles = localized("All Files")
    static let homeButtonCreateStory = localized("Create a Story")
    static let homeButtonFavorites = localized("Favorites")
    static let homeButtonSyncContacts = localized("Sync Contacts")
    
    // MARK: - Home page subButtons Lables
    static let takePhoto = localized("Take Photo")
    static let upload = localized("Upload")
    static let uploadFiles = localized("Upload Files")
    static let uploadMusic = localized("Upload Music")
    static let createStory = localized("Create a Story")
    static let newFolder = localized("New Folder")
    static let createAlbum = localized("Create album")
    static let uploadFromLifebox = localized("Upload from lifebox")
    static let importFromSpotifyBtn = localized("import_from_spotify_btn")
    static let importFromSpotifyTitle = localized("import_from_spotify_title")
    
    
    // MARK: - Searchbar img name
    
    static let searchIcon = localized("searchIcon")
    
    // MARK: - Navigation bar buttons titles
    
    static let cancelSelectionButtonTitle = localized("Cancel")
    
    // MARK: - More actions Collection view section titles
    
    static let viewTypeListTitle = localized("List")
    static let viewTypeGridTitle = localized("Grid")
    
    static let sortTypeAlphabeticAZTitle = localized("Name (A-Z)")
    static let sortTypeAlphabeticZATitle = localized("Name (Z-A)")
    static let sortTimeOldNewTitle = localized("Oldest")
    static let sortTimeNewOldTitle = localized("Newest")
    static let sortTimeSizeTitle = localized("Size")
    static let sortTimeSizeLargestTitle = localized("Largest")
    static let sortTimeSizeSmallestTitle = localized("Smallest")
    
    static let sortHeaderAlphabetic = localized("Alphabetically Sorted")
    static let sortHeaderTime = localized("Sorted by Time")
    static let sortHeaderSize = localized("Sorted by Size")
    
    static let fileTypeVideoTitle = localized("Video")
    static let fileTypeDocsTitle = localized("Docs")
    static let fileTypeMusicTitle = localized("Music")
    static let fileTypePhotosTitle = localized("Photos")
    static let fileTypeAlbumTitle = localized("Album")
    static let fileTypeFolderTitle = localized("Folder")
    
    static let selectedTypeSelectedTitle = localized("Select")
    static let selectedTypeSelectedAllTitle = localized("Select All")
    
    // MARK: - TOPBAR
    
    static let topBarVideosFilter = localized("Videos")
    static let topBarPhotosFilter = localized("Photos")

    // MARK: - Camera alert
    static let cameraAccessAlertTitle = localized("Error")
    static let cameraAccessAlertText = localized("Error occurred while accessing your photos.\nPlease check your settings.")
    static let cameraAccessAlertGoToSettings = localized("Settings")
    static let cameraAccessAlertNo = localized("No")
    
    // MARK: - Sync out of space alert
    static let syncOutOfSpaceAlertTitle = localized("Caution!")
    static let syncOutOfSpaceAlertText = localized("You have reached your lifebox memory limit.\nLet’s have a look for upgrade options!")
    static let upgrade = localized("Upgrade")
    static let syncOutOfSpaceAlertCancel = localized("Cancel")
    
    // MARK: Home page contact bacup
    static let homePageContactBacupHeader = localized("Contact Backup")
    static let homePageContactBacupOldTitle = localized("Your last contact update was %@ months ago!")
    static let homePageContactBacupOldSubTitle = localized("It has been %@ months since you last updated your contacts, update now to never loose any of your contacts.")
    static let homePageContactBacupEmptyTitle = localized("Your contact list looks empty")
    static let homePageContactBacupEmptySubTitle = localized("You don’t have any contacts in your profile, backup your contacts now!")
    static let homePageContactBacupButton = localized("Backup")
    static let homePageContactBacupLastUpate = localized("Last update:")
    
    
    // MARK: Home Storage card
    static let homeStorageCardCloudTitle = localized("Your lifebox storage is almost full!")
    static let homeStorageCardEmptyTitle = localized("Your storage is empty!")
    static let homeStorageCardLocalTitle = localized("Your storage is almost full!")
    static let homeStorageCardCloudSubTitle = localized("You are using %f of your disk space! It’s a great time to expand your storage.")
    static let homeStorageCardEmptySubTitle = localized("You seem to have no uploaded files. Start uploading your memories on Lifebox!")
    static let homeStorageCardLocalSubTitle = localized("You are using %f of your device storage. It’s a great time to freeup space on your device.")
    static let homeStorageCardCloudBottomButtonTitle = localized("Expand My Storage")
    static let homeStorageCardEmptyBottomButtonTitle = localized("Upload Files")
    static let homeStorageCardLocalBottomButtonTitle = localized("Free Up Space")
    
    
    // MARK: Home Collage card
    static let homeCollageCardTitle = localized("Collage")
    static let homeCollageCardSubTitle = localized("We have created a collage from your photos!")
    static let homeCollageCardButtonSaveCollage = localized("Save Collage")
    
    
    // MARK: Home Animation card
    static let homeAnimationCardTitle = localized("Animation")
    static let homeAnimationCardSubTitle = localized("We have created an animation from your photos!")
    static let homeAnimationCardButtonSaveCollage = localized("Save Animation")
    
    
    // MARK: Home Album card
    static let homeAlbumCardTitle = localized("Album Card")
    static let homeAlbumCardSubTitle = localized("We have created an album for you.")
    static let homeAlbumCardBottomButtonSaveAlbum = localized("Save Album")
    static let homeAlbumCardBottomButtonViewAlbum = localized("View")
    
    
    // MARK: Home movie card
    static let homeMovieCardTitle = localized("Movie")
    static let homeMovieCardSubTitle = localized("Did you like this story that we created for you?")
    static let homeMovieCardViewButton = localized("View")
    static let homeMovieCardSaveButton = localized("Save This Story")
    
    // MARK: Home divorce card
    static let homeDivorceCardTitle = localized("divorce_card_title")
    
    // MARK: PhotoPick Campaign card
    static let campaignCardTitle = localized("campaign_card_title")
    static let campaignCardDescriptionLabelNewUser = localized("campaign_description_label_new_user")
    static let campaignCardDescriptionLabelExperiencedUser = localized("campaign_description_label_experienced_user")
    static let campaignCardDescriptionLabelDaylyLimiReached = localized("campaign_description_label_limit_reached")
    static let campaignCardDescriptionLabelAnother = localized("campaign_description_label_another")
    static let campaignDetailButtonTitle = localized("campaign_campaign_detail_button")
    static let analyzePhotoPickButtonTitle = localized("analyze_photo_pic_detail_button")
    
    //MARK: Campaign PhotoPick
    static let campaignViewControllerShowResultButton = localized("campaign_vc_result_button")
    static let campaignViewControllerEditProfileButton = localized("campaign_vc_edit_profile_button")
    static let campaignViewControllerBecomePremium = localized("campaign_vc_become_premium_button")
    static let campaignViewControllerBottomViewTitle = localized("campaign_vc_bottom_title")
    static let campaignViewControllerBottomViewDescription = localized("campaign_vc_bottom_description")
    static let campaignTopViewTitleWithoutPhotoPick = localized("campaign_vc_top_without_title")
    static let campaignTopViewDescriptionWithoutPhotoPick = localized("campaign_vc_top_without_description")
    static let campaignTopViewTitleZeroRemainin = localized("campaign_vc_top_title_zero")
    static let campaignTopViewTitleRemainin = localized("campaign_vc_top_title_non_zero")
    static let campaignTopViewDescriptionZeroRemaining = localized("campaign_vc_top_description_zero")
    static let campaignTopViewDescriptionRemainin = localized("campaign_vc_top_description_non_zero")
    
    // MARK: Home Documents Album card
    
    static let documentsAlbumCardTitleLabel = localized("documents_album_card_title")
    static let documentsAlbumCardDescriptionLabel = localized("documents_album_card_description")
    static let documentsAlbumCardHideButton = localized("documents_album_card_hide_button")
    static let documentsAlbumCardViewButton = localized("documents_album_card_view_button")
    
    // MARK: Home Latest Uploads card
    static let homeLatestUploadsCardTitle = localized("Latest Uploads")
    static let homeLatestUploadsCardSubTitle = localized("Your latest uploads")
    static let homeLatestUploadsCardRecentActivitiesButton = localized("View Recent Activities")
    static let homeLatestUploadsCardAllPhotosButtn = localized("View All Photos")

    // MARK: Home Invitation card
    static let homeInvitationCardButtn = localized("invitation_home_card_button_title")

    // MARK: Home PhotoPrint card
    static let homePhotoPrintCardButton = localized("print_photo_home_card_button_title")

    // MARK: Home page like filter view
    static let homeLikeFilterHeader = localized("Filter Card")
    static let homeLikeFilterTitle = localized("Did you like this filter?")
    static let homeLikeFilterSubTitle = localized("You can apply this filter and my more to your other picures as well")
    static let homeLikeFilterSavePhotoButton = localized("Save this photo")
    static let homeLikeFilterViewPhoto = localized("View")
    
    // MARK: Popup
    static let ok = localized("OK")
    static let downloadDocumentErrorPopup = localized("download_document_error_popup")
    
    // MARK: All files
    static let allFilesViewNoFilesTitleText = localized("You don’t have any files on your Lifebox yet.")
    static let allFilesViewNoFilesButtonText = localized("Start adding your files")
    
    // MARK: Favorites
    static let favoritesViewNoFilesTitleText = localized("You don’t have any favorited files on your Lifebox yet.")
    static let favoritesViewNoFilesButtonText = localized("Start adding your files")
    
    // MARK: PhotosVideosView
    static let photosVideosViewNoPhotoTitleText = localized("You don’t have anything on your photo roll.")
    static let photosVideosViewNoPhotoButtonText = localized("Start adding your photos")
    static let photosVideosViewHaveNoPermissionsAllertText = localized("Enable photo permissions in settings")
    static let photosVideosViewMissingDatesHeaderText = localized("Missing Dates")
    static let showOnlySyncedItemsText = localized("Show only synced items")
    static let photosVideosAutoSyncSettings = localized("photo_video_auto_sync_settings")
    static let photosVideosEmptyNoUnsyncPhotosTitle = localized("photo_video_empty_no_unsync_photos_title")
    
    // MARK: AudioView
    static let audioViewNoAudioTitleText = localized("You don’t have any music on your Lifebox yet.")
    
    // MARK: DocumentsView
    static let documentsViewNoDocumenetsTitleText = localized("You don’t have any documents on your Lifebox yet.")
    
    // MARK: Folder
    static let folderEmptyText = localized("Folder is Empty")
    static let folderItemsText = localized("Folder Items")
    
    // MARK: settings
    static let backPrintTitle = localized("Back to Lifebox")
    
    // MARK: settings
    static let settingsViewCellLoginSettings = localized("Login Settings")
    static let settingsViewCellTurkcellPassword = localized("Turkcell Password")
    static let settingsViewCellTurkcellAutoLogin = localized("Auto-login")
    static let settingsViewCellTwoFactorAuth = localized("2_factor_auth")


    static let settingsViewUploadPhotoLabel = localized("Upload Photo")
    static let settingsViewLeaveFeedback = localized("Leave feedback")
    
    static let settingsViewCellBeckup = localized("Back-up my contacts")
    static let settingsViewCellContactsSync = localized("Contacts Sync")
    static let settingsViewCellImportPhotos = localized("Import Photos")
    static let settingsViewCellConnectedAccounts = localized("connected_accounts")
    static let settingsViewCellAutoUpload = localized("Auto Sync")
    static let settingsViewCellFaceAndImageGrouping = localized("Face & Image Grouping")
    static let settingsViewCellActivityTimline = localized("My Activity Timeline")
    static let settingsViewCellUsageInfo = localized("Usage Info and Packages")
    static let settingsViewCellPasscode = localized("Lifebox %@ and Passcode")
    static let settingsViewCellHelp = localized("Help & Support")
    static let settingsViewCellPrivacyAndTerms = localized("terms_and_privacy_policy")
    static let settingsViewCellLogout = localized("Logout")
    static let settingsViewCellPermissions = localized("Permissions")
    static let settingsViewLogoutCheckMessage = localized("Are you sure you want to exit the application?")
    static let settingsUserInfoNameSurname = localized("settings_userinfo_name_surname")
    static let settingsUserInfoEmail = localized("settings_userinfo_email")
    static let settingsUserInfoPhone = localized("settings_userinfo_phone")

    // MARK: FAQ
    
    static let faqViewTitle = localized("Help and Support")
    
    // MARK: Import photos
    static let importPhotos = localized("Import Photos")
    static let importFromDB = localized("Import From Dropbox")
    static let importFromFB = localized("Import From Facebook")
    static let importFromSpotify = localized("import_from_spotify")
    static let importFromInstagram = localized("Import From Instagram")
    static let importFromCropy = localized("Import From Cropy")
    static let importFiles = localized("Importing files")
    static let dropboxAuthorisationError = localized("Dropbox authorisation error")
    
    static let dropboxLastUpdatedFile = localized("dropboxLastUpdatedFile")
    static let dropboxLastUpdatedFiles = localized("dropboxLastUpdatedFiles")
    
    // MARK: Terms of Use and Privacy Policy
    static let termsOfUseCell = localized("terms_of_use")
    static let privacyPolicyCell = localized("privacy_policy_cell")

    // MARK: Signup Redesign
    static let signupRedesignEulaCheckbox = localized("signup_redesign_eula_checkbox_desc")
    static let signupRedesignEulaLink = localized("signup_redesign_eula_link")
    static let signupRedesignEtkCheckbox = localized("signup_redesign_etk_checkbox_desc")
    static let signupRedesignEtkLink = localized("signup_redesign_etk_link")
    static let signupRedesignEulaAcceptButton = localized("signup_redesign_eula_accept_button")
    
    // MARK: Face Image
    static let faceImageGrouping = localized("Face image grouping")
    static let faceAndImageGrouping = localized("Face & Image Grouping")
    static let faceImageDone = localized("Done")
    static let faceImageAddName = localized("+Add a Name")
    static let faceImageSearchAddName = localized("+Add Name")
    static let faceImageCheckTheSamePerson = localized("Are these the same person?")
    static let faceImageWillMergedTogether = localized("They will be merged together")
    static let faceImageNope = localized("Nope")
    static let faceImageYes = localized("Yes")
    static let faceImageThisPerson = localized("this person")
    static let faceImagePhotos = localized("Photos")
    static let faceImageNoPhotos = localized("We couldn't find anybody on your Lifebox yet.")
    static let faceImagePlacesNoPhotos = localized("We couldn’t find any place on your Lifebox yet.")
    static let faceImageThingsNoPhotos = localized("We couldn’t find anything on your Lifebox yet.")
    static let faceImageNoPhotosButton = localized("Start adding your photos")
    static let faceImageWaitAlbum = localized("Grouping of your photos will take some time. Please wait and then check the albums.")
    static let faceImageEnable =  localized("face_image_enable")
    static let faceImageEnableMessageText =  localized("face_image_enable_message_text")
    static let faceImageEnableSnackText =  localized("face_image_enable_snack_text")

    // MARK: userProfile
    static let userProfileTitle = localized("Your Profile")
    static let userProfileNameAndSurNameSubTitle = localized("Name and Surname")
    static let userProfileName = localized("name")
    static let name = localized("Name")
    static let userProfileSurname = localized("surname")
    static let userProfileEmailSubTitle = localized("E-Mail")
    static let userProfileGSMNumberSubTitle = localized("GSM Number")
    static let userProfileEditButton = localized("Edit")
    static let userProfileDoneButton = localized("Done")
    static let emptyEmail = localized("E-mail is empty")
    static let emptyEmailTitle = localized("E-Mail Entry")
    static let userProfileChangePassword = localized("change password")
    static let userProfileBirthday = localized("birthday")
    static let userProfilePassword = localized("Password")
    static let userProfileSecretQuestion =  localized("security_question")
    static let userProfileEditSecretQuestion =  localized("edit_security_question")
    static let userProfileNoSecretQuestion =  localized("no_security_question")
    static let userProfileSecretQuestionInvalidId =  localized("sequrity_question_id_is_invalid")
    static let userProfileSecretQuestionInvalidAnswer =  localized("sequrity_question_answer_is_invalid")
    static let userProfileEditSecretQuestionSuccess =  localized("edit_security_question_success")
    static let userProfileSetSecretQuestionSuccess =  localized("set_security_question_success")
    
    static let userProfileSelectQuestion =  localized("select_question")
    static let userProfileSecretQuestionAnswer =  localized("secret_answer")
    static let userProfileSecretQuestionAnswerPlaseholder =  localized("enter_secret_answer")
    static let userProfileSecretQuestionLabelPlaceHolder = localized("security_question_text_field_placeholder")
    static let userProfileSetSecretQuestionButton = localized("set_sequrity_question_button")
    
    static let userProfileDayPlaceholder = localized("user_profile_day_placeholder")
    static let userProfileMonthPlaceholder = localized("user_profile_month_placeholder")
    static let userProfileYearPlaceholder = localized("user_profile_year_placeholder")
    static let userProfileTurkcellGSMAlert = localized("user_profile_turkcell_gsm_alert")
    
    // MARK: fileInfo
    static let fileInfoFileNameTitle = localized("File Name")
    static let fileInfoFileInfoTitle = localized("File Info")
    static let fileInfoFolderNameTitle = localized("Folder Name")
    static let fileInfoFolderInfoTitle = localized("Folder Info")
    static let fileInfoAlbumSizeTitle = localized("Items")
    static let fileInfoFileSizeTitle = localized("File size")
    static let fileInfoDurationTitle = localized("Duration")
    static let fileInfoUploadDateTitle = localized("Upload date")
    static let fileInfoCreationDateTitle = localized("Creation date")
    static let fileInfoTakenDateTitle = localized("Taken date")
    static let fileInfoAlbumTitle = localized("Album")
    static let fileInfoArtistTitle = localized("Artist")
    static let fileInfoTitleTitle = localized("Title")
    static let fileInfoAlbumNameTitle = localized("Album Name")
    static let fileInfoAlbumInfoTitle = localized("Album Info")
    static let fileInfoSave = localized("Save")
    static let fileInfoPeople = localized("file_info_people")
    
    //MARK: Permissions in Settings
    static let etkPermissionTitleLabel = localized("etk_permission_title_label")
    static let etkPermissionDescription = localized("etk_permission_description")
    static let globalPermissionTitleLabel = localized("global_permission_title_label")
    static let globalPermissionDescriptionLabel = localized("global_permission_description")
    static let informativeDescription = localized("informative_description_label")
    static let mobilePaymentPermissionTitleLabel = localized("mobile_payment_title")
    static let mobilePaymentPermissionDescriptionLabel = localized("mobile_payment_description")
    static let mobilePaymentPermissionLink = localized("mobile_payment_link")
    static let mobilePaymentViewTitleLabel = localized("mobile_payment_view_title")
    static let mobilePaymentViewDescriptionLabel = localized("mobile_payment_view_description")
    static let mobilePaymentViewLinkLabel = localized("mobile_payment_view_link_text")
    static let mobilePaymentClosePopupTitleLabel = localized("mobile_payment_close_popup_title")
    static let mobilePaymentClosePopupDescriptionLabel = localized("mobile_payment_close_popup_description")
     static let mobilePaymentClosePopupDescriptionBoldRangeLabel = localized("mobile_payment_close_popup_description_bold_range")
    static let mobilePaymentOpenPopupTitleLabel = localized("mobile_payment_open_popup_title")
    static let mobilePaymentOpenPopupDescriptionLabel = localized("mobile_payment_open_popup_description")
    static let mobilePaymentOpenPopupDescriptionBoldRangeLabel = localized("mobile_payment_open_popup_description_bold_range")
    static let mobilePaymentOpenPopupContinueButton = localized("mobile_payment_open_popup_continue_button")
     static let mobilePaymentOpenPopupLaterButton = localized("mobile_payment_open_popup_later_button")
    static let mobilePaymentSuccessPopupTitle = localized("mobile_payment_success_popup_title")
     static let mobilePaymentSuccessPopupMessage = localized("mobile_payment_success_popup_message")
    
    
    // MARK: settings User info view
    static let settingsUserInfoViewUpgradeButtonText = localized("UPGRADE")
    
    // MARK: BackUp contacts view
    static let settingsBackupContactsViewNewContactsText = localized("New Contact")
    static let settingsBackupContactsViewDuplicatesText = localized("Updated")
    static let settingsBackupContactsViewRemovedText = localized("Removed")
    static let settingsBackupedText = localized("Backed up %d Contacts")
    static let settingsBackupStatusText = localized("You have %d numbers on your contacts backup.")
    static let settingsRestoredText = localized("Restored %d Contacts")
    static let settingsBackUpingText = localized("%d%% Backed up…")
    static let settingsDeletingText = localized("%d Duplicated Contacts Deleted")
    static let settingsRestoringText = localized("%d%% Restored…")
    static let settingsAnalyzingText = localized("%d%% Analyzed…")
    static let settingsBackUpNeverDidIt = localized("You can backup your contacts to lifebox. By\ndoing that you can easly access your contact\nlist from any device and anywhere.")
    static let settingsBackUpNewer = localized("You never backed up your contacts")
    static let settingsBackUpLessAMinute = localized("Your last back up was a few seconds ago.")
    static let settingsBackUpLessADay = localized("Your last backup was on %@")
    static let settingsBackUpButtonTitle = localized("Back-Up")
    static let settingsBackUpRestoreTitle = localized("Restore")
    static let settingsBackUpCancelDeletingTitle = localized("Cancel Deleting")
    static let settingsBackUpCancelAnalyzingTitle = localized("Cancel Analyzing")
    static let settingsBackUpDeleteDuplicatedButton = localized("Delete Duplicated")
    static let settingsBackUpDeleteContactButton = localized("Delete")
    static let settingsContactsPermissionDeniedMessage = localized("You need to enable access to Contacts to continue")
    static let autoSyncSettingsSelect = localized("Select")
    static let autoSyncSettingsOptionNever = localized("Never")
    static let autoSyncSettingsOptionWiFi = localized("Wi-Fi")
    static let autoSyncSettingsOptionWiFiAndCellular = localized("Wi-Fi and Cellular")
    static let autoSyncSettingsOptionOff = localized("Off")
    static let autoSyncSettingsOptionDaily = localized("Daily")
    static let autoSyncSettingsOptionWeekly = localized("Weekly")
    static let autoSyncSettingsOptionMonthly = localized("Monthly")
    
    static let deleteDuplicatesTitle = localized("contact_phase2_delete_duplicates_title")
    static let deleteDuplicatesTopLabel = localized("contact_phase2_delete_duplicates_top_label")
    static let deleteDuplicatesDeleteAll = localized("contact_phase2_delete_duplicates_delete_all")
    static let deleteDuplicatesCount = localized("contact_phase2_delete_duplicates_count")
    
    static let deleteDuplicatesConfirmTitle = localized("contact_phase2_delete_duplicates_confirm_title")
    static let deleteDuplicatesConfirmMessage = localized("contact_phase2_delete_duplicates_confirm_message")
    
    static let deleteDuplicatesSuccessTitle = localized("contact_phase2_delete_duplicates_success_title")
    static let deleteDuplicatesSuccessMessage = localized("contact_phase2_delete_duplicates_success_message")
    static let deleteDuplicatesBackUpTitle = localized("contact_phase2_delete_duplicates_back_up_title")
    static let deleteDuplicatesBackUpMessage = localized("contact_phase2_delete_duplicates_back_up_message")
    static let deleteDuplicatesBackUpButton = localized("contact_phase2_delete_duplicates_back_up_button")
    
    static let deleteDuplicatesProgressTitle = localized("contact_phase2_delete_duplicates_progress_title")
    static let deleteDuplicatesProgressMessage = localized("contact_phase2_delete_duplicates_progress_message")
    
    static let backUpContactsConfirmTitle = localized("contact_phase2_back_up_contacts_confirm_title")
    static let backUpContactsConfirmMessage = localized("contact_phase2_back_up_contacts_confirm_message")
    
    static let contactListNavBarTitle = localized("contact_phase2_contact_list_navbar_title")
    static let contactListTitle = localized("contact_phase2_contact_list_title")
    static let contactListInfo = localized("contact_phase2_contact_list_info")
    static let contactListRestore = localized("contact_phase2_contact_list_restore")
    static let contactListDeleteAll = localized("contact_phase2_contact_list_delete_all")
    
    static let restoreContactsConfirmTitle = localized("contact_phase2_restore_contacts_confirm_title")
    static let restoreContactsConfirmMessage = localized("contact_phase2_restore_contacts_confirm_message")
    static let restoreContactsProgressTitle = localized("contact_phase2_restore_contacts_progress_title")
    static let restoreContactsProgressMessage = localized("contact_phase2_restore_contacts_progress_message")
    static let restoreContactsSuccessTitle = localized("contact_phase2_restore_contacts_success_title")
    static let restoreContactsSuccessMessage = localized("contact_phase2_restore_contacts_success_message")
    
    static let deleteContactsConfirmTitle = localized("contact_phase2_delete_contacts_confirm_title")
    static let deleteContactsConfirmMessage = localized("contact_phase2_delete_contacts_confirm_message")
    static let deleteAllContactsSuccessMessage = localized("contact_phase2_delete_all_contacts_success_message")
    static let deleteBackupSuccessMessage = localized("contact_phase2_delete_backup_success_message")
    
    static let contactDetailNavBarTitle = localized("contact_phase2_contact_detail_navbar_title")
    static let contactDetailSectionPhone = localized("contact_phase2_contact_detail_section_phone")
    static let contactDetailSectionEmail = localized("contact_phase2_contact_detail_section_email")
    static let contactDetailSectionAddress = localized("contact_phase2_contact_detail_section_address")
    static let contactDetailSectionBirthday = localized("contact_phase2_contact_detail_section_birthday")
    static let contactDetailSectionNotes = localized("contact_phase2_contact_detail_section_notes")
    static let contactDetailNoInfo = localized("contact_phase2_contact_detail_no_info")
    
    // MARK: Create story Name
    static let createStorySelectAudioButton = localized("Continue")
    
    // MARK: Create story Photos
    static let createStoryPhotosTitle = localized("Create a story")
    static let createStoryPhotosCancel = localized("Cancel")
    static let createStoryPhotosContinue = localized("Continue")
    static let createStoryPhotosHeaderTitle = localized("Please Choose 20 files at most")
    static let createStoryPhotosMaxCountAllert = localized("Please choose %d files at most")
    static let createStoryNoSelectedPhotosError = localized("Sorry, but story photos should not be empty")
    static let createStoryNotCreated = localized("Story not created")
    static let failWhileAddingToAlbum = localized("Fail while adding to album")
    
    // MARK: Create story Audio
    static let createStoryNoSelectedAudioError = localized("Sorry, but story audio should not be empty")
    static let createStoryAudioSelected = localized("Add Music")
    static let createStoryAudioMusics = localized("Musics")
    static let createStoryAudioYourUploads = localized("Your Uploads")
    static let createStoryAudioSelectItem = localized("Select")
    static let createStoryAudioSelectedItem = localized("Selected")
    
    // MARK: Create story Photo Order
    static let createStoryPhotosOrderNextButton = localized("Create")
    static let createStorySave = localized("Save")
    static let createStoryPhotosOrderTitle = localized("You can change the sequence ")
    
    // MARK: Stories View
    static let storiesViewNoStoriesTitleText = localized("You don’t have any stories  on your Lifebox yet.")
    static let storiesViewNoStoriesButtonText = localized("Start creating stories")
    
    // MARK: Upload
    static let uploadFilesNextButton = localized("Upload")
    static let uploadFilesNothingUploadError = localized("Nothing to upload")
    
    // MARK: UploadFromLifeBox
    static let uploadFromLifeBoxTitle = localized("Upload from lifebox")
    static let uploadFromLifeBoxNextButton = localized("Next")
    static let uploadFromLifeBoxNoSelectedPhotosError = localized("Sorry, but photos not selected")
    
    // MARK: Select Folder
    static let selectFolderNextButton = localized("Select")
    static let selectFolderCancelButton = localized("Cancel")
    static let selectFolderBackButton = localized("Back")
    static let selectFolderTitle = localized("Choose a destination folder")
    
    // MARK: - TabBar tab lables
    static let tabBarItemHomeLabel = localized("tabbar_item_home_label")
    static let tabBarItemGalleryLabel = localized("tabbar_item_gallery_label")
    static let tabBarItemContactsLabel = localized("tabbar_item_contacts_label")
    static let tabBarItemAllFilesLabel = localized("tabbar_item_all_files_label")
    
    static let music = localized("Music")
    static let documents = localized("Documents")
    static let tabBarDeleteLabel = localized("Delete")
    static let tabBarHideLabel = localized("Hide")
    static let tabBarUnhideLabel = localized("Unhide")
    static let tabBarSmashLabel = localized("Smash")
    static let tabBarRemoveAlbumLabel = localized("Remove Album")
    static let tabBarRemoveLabel = localized("Remove From Album")
    static let tabBarAddToAlbumLabel = localized("Add To Album")
    static let tabAlbumCoverAlbumLabel = localized("Make album cover")
    static let tabBarEditeLabel = localized("Edit")
    static let tabBarPrintLabel = localized("Print")
    static let tabBarDownloadLabel = localized("Download")
    static let tabBarSyncLabel = localized("Sync")
    static let tabBarMoveLabel = localized("Move")
    static let tabBarShareLabel = localized("Share")
    static let tabBarInfoLabel = localized("Info")

    //MARK: Smash Screen
    static let smashScreenTitle = localized("smash_screen_title")
    static let smashPopUpMessage = localized("smash_popup_message")
    
    // MARK: Select Name
    static let selectNameTitleFolder = localized("New Folder")
    static let selectNameTitleAlbum = localized("New Album")
    static let selectNameTitlePlayList = localized("New PlayList")
    static let selectNameNextButtonFolder = localized("Create")
    static let selectNameNextButtonAlbum = localized("Create")
    static let selectNameNextButtonPlayList = localized("Create")
    static let selectNamePlaceholderFolder = localized("Folder Name")
    static let selectNamePlaceholderAlbum = localized("Album Name")
    static let selectNamePlaceholderPlayList = localized("Play List Name")
    static let selectNameEmptyNameFolder = localized("Sorry, but folder name should not be empty")
    static let selectNameEmptyNameAlbum = localized("Sorry, but album name should not be empty")
    static let selectNameEmptyNamePlayList = localized("Sorry, but play list name should not be empty")
    
    // MARK: Albums
    static let albumsTitle = localized("Albums")
    static let uploadPhotos = localized("Upload Photos")
    static let removeReadOnlyAlbumError = localized("Video album is automatically created, therefore cannot be deleted")
    static let uploadVideoToReadOnlyAlbumError = localized("You cannot upload any video to auto generated video album")
    static let haveNoAnyFiles = localized("You have no any files")
    static let albumEmptyText = localized("Album is Empty")
    static let shareEmptyAlbumError = localized("You can not share empty album")
    
    // MARK: Albums view
    static let albumsViewNoAlbumsTitleText = localized("You don’t have any albums on your Lifebox yet.")
    static let albumsViewNoAlbumsButtonText = localized("Start creating albums")
    
    // MARK: My stream
    static let myStreamAlbumsTitle = localized("Albums")
    static let myStreamStoriesTitle = localized("My Stories")
    static let myStreamPeopleTitle = localized("People")
    static let myStreamThingsTitle = localized("Things")
    static let myStreamPlacesTitle = localized("Places")
    static let myStreamInstaPickTitle = localized("InstaPick")
    static let smartAlbumHidden = localized("smart_album_hidden")
    
    // MARK: Feedback View
    static let feedbackMailTextFormat = localized("Please do not delete the information below. The information will be used to address the problem.\n\nApplication Version: %@\nMsisdn: %@\nCarrier: %@\nDevice:%@\nDevice OS: %@\nLanguage: %@\nLanguage preference: %@\nNetwork Status: %@\nTotal Storage: %lld\nUsed Storage: %lld\nPackages: %@\n")
    static let supportFormBilloTopText = localized("billo_contactus_top_text")
    static let supportFormEmailBody = localized("support_form_email_body")
    
    static let feedbackViewTitle = localized("Thanks for leaving a comment!")
    static let feedbackViewSubTitle = localized("Feedback Form")
    static let feedbackViewSuggestion = localized("Suggestion")
    static let feedbackViewComplaint = localized("Complaint")
    static let feedbackViewSubjectFormat = localized("%@ about Lifebox")
    static let feedbackViewLanguageLabel = localized("You need to specify your language preference so that we can serve you better.")
    static let feedbackViewSendButton = localized("Send")
    static let feedbackViewSelect = localized("Please select a language option")
    static let feedbackEmailError = localized("Please configurate email client")
    static let feedbackErrorTextError = localized("Please type your message")
    static let feedbackErrorLanguageError = localized("You need to specify your language preference so that we can serve you better.")
    
    
    // MARK: PopUp
    static let popUpProgress = localized("(%ld of %ld)")
    static let popUpSyncing = localized("Syncing files over")
    static let popUpUploading = localized("Uploading files over")
    static let popUpDownload = localized("Downloading files")
    static let popUpDeleteComplete = localized("Deleting is complete")
    static let popUpHideComplete = localized("photos_hide_success_message")
    static let popUpDownloadComplete = localized("Download is complete")
    static let freeAppSpacePopUpTextNormal = localized("There are some duplicated items both in your device and lifebox")
    static let freeAppSpacePopUpButtonTitle = localized("Free up space")
    static let freeUpSpaceAlertTitle = localized("free_up_space_alert_title")
    static let freeUpSpaceNoDuplicates = localized("free_up_space_no_duplicates")
    static let freeUpSpaceInProgress = localized("free_up_space_in_progress")
    static let freeUpSpaceBigTitle = localized("free_up_space_title")
    static let networkTypeWiFi = localized("Wi-Fi")
    static let mobileData = localized("Mobile Data")
    static let autoUploaOffPopUpTitleText = localized("Auto Upload is off.")
    static let autoUploaOffPopUpSubTitleText = localized("Photos and videos waiting to be synced")
    static let autoUploaOffSettings = localized("Settings")
    static let waitingForWiFiPopUpTitle = localized("Waiting for Wi-Fi connection to auto-sync")
    static let waitingForWiFiPopUpSettingsButton = localized("Settings")
    static let prepareToAutoSunc = localized("Auto Sync Preparation")
    static let prepareQuickScroll = localized("Quick Scroll Preparation")
    static let hideSuccessPopupMessage = localized("hide_success_popup_message")
    static let hideSuccessPopupButtonTitle = localized("hide_success_popup_button_title")
    static let hideSingleAlbumSuccessPopupMessage = localized("hide_single_album_success_popup_message")
    static let hideAlbumsSuccessPopupMessage = localized("hide_albums_success_popup_message")
    static let toastMessageDeleteNotification = localized("toast_message_delete_notification")

    // MARK: - ActionSheet
    static let actionSheetDeleteDeviceOriginal = localized("Delete Device Original")
    
    static let actionSheetCancel = localized("Cancel")

    
    static let actionSheetShare = localized("Share")
    static let actionSheetInfo = localized("Info")
    static let actionSheetEdit = localized("Edit")
    static let actionSheetDelete = localized("Delete")
    static let actionSheetEmptyTrashBin = localized("empty_trash_bin")
    static let actionSheetMove = localized("Move")
    static let actionSheetDownload = localized("Download")
    static let actionSheetHide = localized("Hide")
    static let actionSheetHideSingleAlbum = localized("hide_album_action_sheet")
    static let actionSheetUnhide = localized("Unhide")
    static let actionSheetRestore = localized("restore_confirmation_popup_title")
    
    static let actionSheetShareSmallSize = localized("Small Size")
    static let actionSheetSharePrivate = localized("private_share_option")
    static let actionSheetShareOriginalSize = localized("Original Size")
    static let actionSheetShareShareViaLink = localized("Share Via Link")
    static let actionSheetShareCancel = localized("Cancel")
    
    static let actionAdd = localized("Add")
    static let actionSheetCreateStory = localized("Create a Story")
    static let actionSheetCopy = localized("Copy")
    static let actionSheetAddToFavorites = localized("Add to Favorites")
    static let actionSheetRemove = localized("Remove")
    static let actionSheetRemoveFavorites = localized("Remove from Favorites")
    static let actionSheetAddToAlbum = localized("Add to album")
    static let actionSheetBackUp = localized("Back Up")
    static let actionSheetRemoveFromAlbum = localized("Remove from album")
    
    static let actionSheetProfileDetails = localized("settings_action_sheet_profile_details")
    static let actionSheetEditProfilePhoto = localized("settings_action_sheet_edit_profile_photo")
    static let actionSheetAccountDetails = localized("settings_action_sheet_account_details")
    static let actionSheetTakeAPhoto = localized("Take Photo")
    static let actionSheetChooseFromLib = localized("Choose From Library")
    static let actionSheetChangeCover = localized("Change cover photo")
    
    static let actionSheetPhotos = localized("Photos")
    static let actionSheetiCloudDrive = localized("iCloud Drive")
    static let actionSheetLifeBox = localized("lifebox")
    static let actionSheetMore = localized("More")
    
    static let actionSheetSelect = localized("Select")
    static let actionSheetSelectAll = localized("Select All")
    static let actionSheetDeSelectAll = localized("Deselect All")
    
    static let actionSheetRename = localized("Rename")
    
    static let actionSheetDocumentDetails = localized("Document Details")
    
    static let actionSheetAddToPlaylist = localized("Share Album")
    static let actionSheetMusicDetails = localized("Music Dteails")
    
    static let actionSheetMakeAlbumCover = localized("Make album covers")
    static let actionSheetAlbumDetails = localized("Album Details")
    static let actionSheetDownloadToCameraRoll = localized("Download to Camera Roll")
    
    // MARK: Free Up Space
    static let freeAppSpaceTitle = localized("There are %d duplicated photos both in your device and lifebox. Clear some space by selecting the photos that you want to delete.")
    static let freeAppSpaceAlertSuccesTitle = localized("You have free space for %d more items.")
    
    static let save = localized("Save")
    static let cropyMessage = localized("This edited photo will be saved as a new photo in your device gallery")
    static let cancel = localized("Cancel")
    
    
    // MARK: -
    
    static let albumLikeSlidertitle = localized("My Stream")
    static let albumLikeSliderWithPerson = localized("Albums with %@")
    // MARK: - ActivityTimeline
    static let activityTimelineFiles = localized("file(s)")
    static let activityTimelineTitle = localized("My Activity Timeline")
    
    // MARK: - PullToRefresh
    static let pullToRefreshSuccess = localized("Success")
    
    // MARK: - usageInfo
    static let myUsageStorage = localized("my_usage_storage")
    static let usageInfoPhotos = localized("%ld photos")
    static let usageInfoVideos = localized("%ld videos")
    static let usageInfoSongs = localized("%ld songs")
    static let usageInfoDocuments = localized("%ld documents")
    static let usageInfoQuotaInfo = localized("Quota info")
    static let usageInfoDocs = localized("%ld docs")
    static let usedAndLeftSpace = localized("used_and_left_space")
    static let leftSpace = localized("left_space")
    static let packageSpaceDetails = localized("package_space_details")
    static let renewDate = localized("package_renew_date")
    static let usagePercentage = localized("percentage_used")
    static let usagePercentageTwoLines = localized("percentage_used_two_lines")
    static let restorePurchasesButton = localized("restore_purchases")
    static let restorePurchasesInfo = localized("restore_purchases_info")
    static let attributedRestoreWord = localized("attributed_restore_word")

    // MARK: - offers
    static let descriptionLabelText = localized("*Average figure. Total number of documents depends on the size of each document.")
    
    static let offersActivateUkranian = localized("Special prices for lifecell subscribers! To activate lifebox 50GB for 24,99UAH/30 days send SMS with the text 50VKL, for lifebox 500GB for 52,99UAH/30days send SMS with the text 500VKL to the number 8080")
    static let offersActivateCyprus = localized("Platinum and lifecell customers can send LIFE, other customers can send LIFEBOX 50GB for lifebox 50GB package, LIFEBOX 500GB for lifebox 500GB package and LIFEBOX 2.5TB for lifebox 2.5TB package to 3030 to start their memberships")
    
    static let offersCancelUkranian = localized("To deactivate lifebox 50GB please send SMS with the text 50VYKL, for lifebox 500GB please send SMS with the text 500VYKL to the number 8080")
    static let offersCancelCyprus = localized("Platinum and lifecell customers can send LIFE CANCEL, other customers can send LIFEBOX CANCEL to 3030 to cancel their memberships")
    static let offersCancelMoldcell = localized("Hm, can’t believe you are doing this! When you decide to reactivate it, we’ll be here for you :) If you insist, sent “STOP” to 2")
    static let offersCancelTurkcell = localized("Please text \"Iptal LIFEBOX %@\" to 2222 to cancel your subscription")
    static let offersCancelLife = localized("offersCancelLife")
    
    static let offersInfo = localized("Info")
    static let offersOk = localized("OK")
    static let offersSettings = localized("Settings")
    static let offersPrice = localized("%.2f %@ / month")
    static let offersLocalizedPrice = localized("%@ / month")
    static let offersAllCancel = localized("You can open settings and cancel subscption.")

    static let subscriptionGoogleText = localized("Google Play Store")
    static let subscriptionAppleText = localized("AppStore")
    
    static let validatePurchaseSuccessText = localized("Successful purchase.")
    static let validatePurchaseInvalidText = localized("Invalid purchase. AppStore does not verify purchase for the given parameters.")
    static let validatePurchaseTemporaryErrorText = localized("A temporary error has occurred due to technical reasons.")
    static let validatePurchaseAlreadySubscribedText = localized("Subscription related with this purchase is already activated for another lifebox user. Note that using different lifebox accounts with the same Apple or Google ID might result with this situation.")
    static let validatePurchaseRestoredText = localized("Shows that a response operation is done for the given receipt.")
    
    // MARK: - OTP
    static let otpResendButton = localized("Resend")
    static let otpTitleText = localized("Enter the verification code\nsent to your number %@")
    
    // MARK: - Errors
    static let errorEmptyEmail = localized("Indicates that the e-mail parameter is sent blank.")
    static let errorEmptyPassword = localized("Indicates that the password parameter is sent blank.")
    static let errorEmptyPhone = localized("Specifies that the phone number parameter is sent  blank.")
    static let errorInvalidEmail = localized("E-mail address is in an invalid format.")
    static let errorExistEmail = localized("This e-mail address is already registered. Please enter another e-mail address.")
    static let errorVerifyEmail = localized("Indicates that a user with the given e-mail address already exists and login will be  allowed after e-mail address validation.")
    static let errorInvalidPhone = localized("Phone number is in an invalid format.")
    static let errorExistPhone = localized("This GSM Number is already registered. Please enter another GSM Number.")
    static let errorInvalidPassword = localized("Please set a password including nonconsecutive letters and numbers, minimum 6 maximum 16 characters.")
    static let errorInvalidPasswordSame = localized("It is not allowed that the password consists of all the same characters.")
    static let errorInvalidPasswordLengthExceeded = localized("The password consists of more number of characters than is allowed. The length allowed is provided in the value field of the response.")
    static let errorInvalidPasswordBelowLimit = localized("The password consists of less number of characters than is allowed. The length allowed is provided in the value field of the response.")
    
    static let TOO_MANY_REQUESTS = localized("Too many verification code requested for this msisdn. Please try again later")
    static let EMAIL_IS_INVALID = localized("E-mail field is invalid")
    static let EMAIL_IS_ALREADY_EXIST = localized("This e-mail address is already registered. Please enter another e-mail address.")
    
    static let errorUnknown = localized("Unknown error")
    static let errorServer = localized("Server error")
    static let errorBadConnection = localized("Bad internet connection")
    
    static let errorFileSystemAccessDenied = localized("Can't get access to file system")
    static let errorNothingToDownload = localized("Nothing to download")
    static let errorSameDestinationFolder = localized("Destination folder can not be the same folder")
    static let errorWorkWillIntroduced = localized("work_will_introduced")
    
    static let errorServerUnderMaintenance = localized("server_under_maintenance")
    
    static let canceledOperationTextError = localized("cancelled")
    static let networkConnectionLostTextError = localized("The network connection was lost.")
    static let commonServiceError = localized("ServiceError")
    
    static let ACCOUNT_NOT_FOUND = localized("Account cannot be found")
    static let INVALID_PROMOCODE = localized("This package activation code is invalid")
    static let PROMO_CODE_HAS_BEEN_ALREADY_ACTIVATED = localized("This package activation code has been used before, please try different code")
    static let PROMO_CODE_HAS_BEEN_EXPIRED = localized("This package activation code has expired")
    static let PROMO_CODE_IS_NOT_CREATED_FOR_THIS_ACCOUNT = localized("This package activation code is defined for different user")
    static let THERE_IS_AN_ACTIVE_JOB_RUNNING = localized("Package activation process is in progress")
    static let CURRENT_JOB_IS_FINISHED_OR_CANCELLED = localized("This package activation code has been used before, please try different code")
    static let PROMO_IS_NOT_ACTIVATED = localized("This package activation code has not been activated  yet")
    static let PROMO_HAS_NOT_STARTED = localized("This package activation code definition time has not yet begun")
    static let PROMO_NOT_ALLOWED_FOR_MULTIPLE_USE = localized("You will not be able to use the this package activation code from this campaign for the second time because you have already benefited from it")
    static let PROMO_IS_INACTIVE = localized("The package activation code is not active")
    
    static let passcode = localized("Passcode")
    static let passcodeSettingsSetTitle = localized("Set a Passcode")
    static let passcodeSettingsChangeTitle = localized("Change Passcode")
    static let passcodeLifebox = localized("lifebox Passcode")
    static let passcodeEnter = localized("Please enter your lifebox passcode")
    static let passcodeEnterOld = localized("Please enter your lifebox passcode")
    static let passcodeEnterNew = localized("Set a Passcode")
    static let passcodeConfirm = localized("Please repeate your new lifebox passcode")
    static let passcodeChanged = localized("Passcode is changed successfully")
    static let passcodeSet = localized("You successfully set your passcode")
    static let passcodeDontMatch = localized("Passcodes don't match, please try again")
    static let passcodeSetTitle = localized("Set a Passcode")
    static let passcodeBiometricsDefault = localized("To enter passcode")
    static let passcodeBiometricsError = localized("Please activate %@ from your device settings to use this feature")
    static let passcodeEnable = localized("Enable")
    static let passcodeFaceID = localized("Face ID")
    static let passcodeTouchID = localized("Touch ID")
    static let passcodeNumberOfTries = localized("Invalid passcode. %@ attempts left. Please try again")
    static let errorConnectedToNetwork = localized("Please check your internet connection is active and Mobile Data is ON.")
    static let errorManyContactsToBackUp = localized("Up to 5000 contacts can be backed up.")
    
    static let apply = localized("Apply")
    static let success = localized("Success")
    
    static let promocodeTitle = localized("Lifebox campaign")
    static let promocodePlaceholder = localized("Enter your promo code")
    static let promocodeError = localized("This package activation code is invalid")
    static let promocodeEmpty = localized("Please enter your promo code")
    static let promocodeSuccess = localized("Your package is successfully defined")
    static let promocodeInvalid = localized("Verification code is invalid.\nPlease try again")
    static let promocodeBlocked = localized("Verification code is blocked.\nPlease request a new code")
    
    // MARK: - Packages
    
    static let packagesIHave = localized("packages_i_have")

    static let accountDetails = localized("account_details")
    static let myProfile = localized("my_profile")
    
    static let accountType = localized("account_type")
    
    static let standardPlus = localized("standard_plus")
    static let standard = localized("standard")
    static let premium = localized("premium")

    static let packages = localized("Packages")
    static let purchase = localized("Purchase")
    
    static let packagesPolicyHeader = localized("PackagesPolicyHeader")
    static let packagesPolicyText = localized("PackagesPolicyText")
    static let packagesPolicyBilloText = localized("PackagesPolicyTextBillo")
    static let termsOfUseLinkText = localized("TermsOfUseLinkText")
    static let feature = localized("Feature")
    
    static let deleteFilesText = localized("Deleting these files will remove them from cloud. You won't be able to access them once deleted")
    static let deleteAlbums = localized("Deleting this album will remove the files from lifebox. You won't be able to access them once deleted. Are you sure you want to delete?")
    static let moveToTrashAlbums = localized("move_to_trash_albums_message")
    static let moveToTrashAlbumsSuccess = localized("move_to_trash_albums_success_message")
    
    static let removeAlbums = localized("Deleting this album will not remove the files from lifebox. You can access these files from Photos tab. Are you sure you want to delete?")
    static let removeAlbumsSuccess = localized("remove_albums_success_message")
    static let removeFromAlbum = localized("This file will be removed only from your album. You can access this file from Photos tab")
    
    static let locationServiceDisable = localized("Location services are disabled in your device settings. To use background sync feature of lifebox, you need to enable location services under \"Settings - Privacy - Location Services\" menu.")
    
    static let hideItemsWarningTitle = localized("confirmation_popup_title_hide")
    static let hideItemsWarningMessage = localized("confirmation_popup_message_hide")
    static let hideAlbumsWarningMessage = localized("confirmation_popup_message_hide_albums")
    static let hideSingleAlbumWarnigTitle = localized("confirmation_popup_title_hide_single_album")
    static let hideSingleAlbumWarnigMessage = localized("confirmation_popup_message_hide_single_album")
    
    static let loginEnterGSM = localized("Please enter your GSM number")
    static let loginAddGSM = localized("Add GSM Number")
    static let loginGSMNumber = localized("GSM number")
    
    static let syncFourGbVideo = localized("The videos larger than 4GB can not be uploaded to lifebox")
    static let syncZeroBytes = localized("Can't upload. File size is 0.")
    static let syncNotEnoughMemory = localized("You have not enough memory in your device")
    
    static let inProgressPurchase = localized("The purchase in progress")
    
    static let renewalDate = localized("Renewal Date: %@")
    static let subscriptionEndDate = localized("Expiration Date: %@")
    static let cancelButtonTitle = localized("package_cancel_button")
    static let packageSectionTitle = localized("package_section_title")
    static let availableHeadNameTitle = localized("available_head_name_title")
    static let offerStorePromo = localized("offer_store_promo")
    static let offerStoreAppleStore = localized("offer_store_apple_store")
    static let offerStoreGoogleStore = localized("offer_store_google_store")
    
    static let packagePeriodDay = localized("package_period_day")
    static let packagePeriodWeek = localized("package_period_week")
    static let packagePeriodXMonth = localized("package_period_x_months")
    static let packagePeriodMonth = localized("package_period_month")
    static let packagePeriodYear = localized("package_period_year")

    static let packageApplePrice = localized("package_apple_price")
    static let faceImageApplePrice = localized("face_image_apple_price")
    
    static let packageGoogleCancelText = localized("package_google_cancel_text")
    static let packageFreeOfChargeCancelText = localized("package_free_of_charge_cancel_text")
    static let packageLifeCellCancelText = localized("package_lifecell_cancel_text")
    static let packagePromoCancelText = localized("package_promo_cancel_text")
    static let packagePaycellAllAccessCancelText = localized("package_paycell_all_access_cancel_text")
    static let packagePaycellSLCMCancelText = localized("package_paycell_slcm_cancel_text")
    static let packageAlbanianCancelText = localized("package_albanian_cancel_text")
    static let packageFWICancelText = localized("package_FWI_cancel_text")
    static let packageJamaicaCancelText = localized("package_jamaica_cancel_text")
    static let packageSLCMPaycellCancelText = localized("package_slcm_paycell_cancel_text")
    static let packageDefaultCancelText = localized("package_default_cancel_text")
    
    static let turkcellPurchasePopupTitle = localized("turkcell_purchase_popup_title")
    
    // MARK: - Navigation bar img names
    
    static let moreBtnImgName = "more"
    static let cogBtnImgName = "cog"
    static let searchBtnImgName = "search"
    static let deleteBtnImgName = "DeleteShareButton"
    static let giftButtonName = "campaignButton"
    static let newAlbumBtnImgName = "newFolderButton"
    
    // MARK: - Navigation bar title names
    
    static let showHideBtnTitleName = localized("Show & Hide")

    // MARK: - Accessibility
    static let accessibilityPlus = localized("Plus")
    static let accessibilityClose = localized("Close")
    static let accessibilitySettings = localized("Settings")
    static let accessibilityMore = localized("More")
    static let accessibilitySearch = localized("Search")
    static let accessibilityDelete = localized("Delete")
    static let accessibilityFavorite = localized("Favorite")
    static let accessibilitySelected = localized("Selected")
    static let accessibilityNotSelected = localized("Not selected")
    static let accessibilityshowHide = localized("Show and Hide")
    static let accessibilityDone = localized("Done")
    static let accessibilityGift = localized("AccessibilityGiftButton")

    static let accessibilityHome = localized("Home")
    static let accessibilityPhotosVideos = localized("Photos and Videos")
    static let accessibilityMusic = localized("Music")
    static let accessibilityDocuments = localized("Documents")
    static let captchaSound = localized("play_captcha")
    static let captchaRefresh = localized("refresh_captcha")
    static let containerShared = localized("container_shared_files")
    static let containerDocument = localized("container_document")
    static let containerMusic = localized("container_music")
    static let containerFavourite = localized("container_favourite")
    static let containerTrashed = localized("container_trashed")
    static let accessibilityPlay = localized("accessibility_play")
    static let accessibilityPause = localized("accessibility_pause")

    static let photos = localized("photos")
    static let approve = localized("Approve")
    static let infomationEmptyEmail = localized("infomationEmptyEmail")
    
    //Periodic contacts sync
    static let periodicContactsSync = localized("Contacts Sync")
    
    // MARK: - Quota PopUps
    static let fullQuotaSmallPopUpTitle = localized("LifeboxSmallPopUpTitle")
    static let fullQuotaSmallPopUpSubTitle = localized("LifeboxSmallPopUpSubTitle")
    static let fullQuotaSmallPopUpCheckBoxText = localized("LifeboxSmallPopUpCheckBoxTex")
    static let fullQuotaSmallPopUpFistButtonTitle = localized("LifeboxSmallPopUpFirstButtonText")
    static let fullQuotaSmallPopUpSecondButtonTitle = localized("LifeboxSmallPopUpSecondButtonText")
    
    static let lifeboxLargePopUpTitle100 = localized("LifeboxLargePopUpTitle100")
    static let lifeboxLargePopUpTitleBetween80And99 = localized("LifeboxLargePopUpTitleBetween80And99")
    static let lifeboxLargePopUpSubTitleBeetween80And99 = localized("LifeboxLargePopUpSubTitleBeetween80And99")
    static let lifeboxLargePopUpSubTitle100Freemium = localized("LifeboxLargePopUpSubTitle100Freemium")
    static let lifeboxLargePopUpSubTitle100Premium = localized("LifeboxLargePopUpSubTitle100Premium")
    static let lifeboxLargePopUpExpandButtonTitle = localized("LifeboxLargePopUpExpandButtonTitle")
    static let lifeboxLargePopUpSkipButtonTitle = localized("LifeboxLargePopUpSkipButtonTitle")
    static let lifeboxLargePopUpDeleteFilesButtonTitle = localized("LifeboxLargePopUpDeleteFilesButtonTitle") 
    static let periodContactSyncFromSettingsTitle = localized("Lifebox can sync your contacts automatically.")
    static let errorLogin = localized("error_login")
    static let uploading = localized("uploading")

    //MARK: - Spotlight
    
    static let spotlightHomePageIconText = localized("We make easier to manage your memories with homepage")
    static let spotlightHomePageGeneralText = localized("You can reach your recent activites and suggestions that are special for you from this page")
    static let spotlightMovieCardText = localized("Discover your first story")
    static let spotlightAlbumCard = localized("Discover your first album")
    static let spotlightCollageCard = localized("Discover your first collage")
    static let spotlightAnimationCard = localized("Discover your first animation")
    static let spotlightFilterCard = localized("Discover your first filtered photo")    
    static let lifeboxMemoryLimit = localized("You have reached your lifebox memory limit")
    static let periodicContactsSyncAccessAlertTitle = localized("Error")
    static let periodicContactsSyncAccessAlertText = localized("Error occurred while accessing your contacts.\nPlease check your settings.")
    static let periodicContactsSyncAccessAlertGoToSettings = localized("Settings")
    static let periodicContactsSyncAccessAlertNo = localized("No")
    static let settings = localized("Settings")
    
    static let packagesSubtitle = localized("Import fearture is totally free of charge and does not affect your internet package")
    static let sortby = localized("Sort By")
    static let successfullyPurchased = localized("Successfully purchased")
    static let invalidCaptcha = localized("This text doesn't match. Please try again")
    static let free = localized("Free")
    
    
    //MARK: - Landing
    static let landingStartUsing = localized("START USING")
    static let landingTitle0 = localized("landingTitle0")
    static let landingSubTitle0 = localized("landingSubTitle0")
    static let landingTitle1 = localized("landingTitle1")
    static let landingSubTitle1 = localized("landingSubTitle1")
    static let landingTitle2 = localized("landingTitle2")
    static let landingSubTitle2 = localized("landingSubTitle2")
    static let landingTitle3 = localized("landingTitle3")
    static let landingSubTitle3 = localized("landingSubTitle3")
    static let landingTitle4 = localized("landingTitle4")
    static let landingSubTitle4 = localized("landingSubTitle4")
    static let landingTitle5 = localized("landingTitle5")
    static let landingSubTitle5 = localized("landingSubTitle5")
    static let landingTitle6 = localized("landingTitle6")
    static let landingSubTitle6 = localized("landingSubTitle6")
    
    //MARK: - Landing Billo
    static let landingStartButton = localized("landing_start_button")
    static let landingBilloTitle0 = localized("landing_billo_title_0")
    static let landingBilloSubTitle0 = localized("landing_billo_subtitle_0")
    static let landingBilloTitle1 = localized("landing_billo_title_1")
    static let landingBilloSubTitle1 = localized("landing_billo_subtitle_1")
    static let landingBilloTitle2 = localized("landing_billo_title_2")
    static let landingBilloSubTitle2 = localized("landing_billo_subtitle_2")
    static let landingBilloTitle3 = localized("landing_billo_title_3")
    static let landingBilloSubTitle3 = localized("landing_billo_subtitle_3")
    static let landingBilloTitle4 = localized("landing_billo_title_4")
    static let landingBilloSubTitle4 = localized("landing_billo_subtitle_4")
    static let landingBilloTitle5 = localized("landing_billo_title_5")
    static let landingBilloSubTitle5 = localized("landing_billo_subtitle_5")
    static let landingBilloTitle6 = localized("landing_billo_title_6")
    static let landingBilloSubTitle6 = localized("landing_billo_subtitle_6")
    
    
    static let created = localized("created")
    static let uploaded = localized("uploaded")
    static let updated = localized("updated")
    static let deleted = localized("deleted")
    static let moved = localized("moved")
    static let renamed = localized("renamed")
    static let copied = localized("copied")
    static let markedAsFavourite = localized("marked as favourite")
    static let errorUnsupportedExtension = localized("download_error_unsupported_extension")
    
    static let facebookPhotoTags = localized("facebook_photo_tags")
    static let facebookTagsOn = localized("facebook_tags_on")
    static let facebookTagsOff = localized("facebook_tags_off")
    static let facebookTagsImport = localized("facebook_tags_import")
    static let faceTagsDescriptionPremium = localized("face_tags_description_premium")
    
    static let launchCampaignCardDetail = localized("launch_campaign_card_detail")
    static let launchCampaignCardTitle = localized("launch_campaign_card_title")
    static let launchCampaignCardMessage = localized("launch_campaign_card_message")

    //MARK: - PremiumView
    static let deleteDuplicatedTitle = localized("delete_duplicated_title")
    static let faceRecognitionTitle = localized("face_recognition_title")
    static let placesTitle = localized("places_title")
    static let thingsTitle = localized("things_title")
    
    //MARK: - FaceImagePremiumFooterView
    static let faceImageFooterViewMessage = localized("face_image_footer_view_message")
    static let faceImageFaceRecognition = localized("face_image_face_recognition")
    static let faceImagePlaceRecognition = localized("face_image_place_recognition")
    static let faceImageThingRecognition = localized("face_image_thing_recognition")

    //MARK: - Premium
    static let useFollowingPremiumMembership = localized("use_following_premium_membership_advantages_with_only_additional_your_data_storage_package")
    static let month = localized("month")
    static let noDetailsMessage = localized("no_details_message")
    static let serverErrorMessage = localized("please_try_again_later")
    static let contactSyncDepoErrorMessage = localized("dialog_contact_sync_vcf_file_upload_error")
    static let contactSyncDepoErrorTitle = localized("dialog_header_contact_sync_vcf_file_upload_error")
    static let contactSyncDepoErrorUpButtonText = localized("dialog_contact_sync_vcf_error_upper_button")
    static let contactSyncDepoErrorDownButtonText = localized("dialog_contact_sync_vcf_error_lower_button")
    
    static let backUpOriginalQuality = localized("Back up with Original Quality")
    static let removeDuplicateContacts = localized("Remove Duplicate Contacts from Your Directory")
    static let faceRecognitionToReach = localized("Face Recognition to reach your loved one's memories")
    static let placeRecognitionToBeam = localized("Place Recognition to beam you up to the memories")
    static let objectRecognitionToRemember = localized("Object Recognition to remember with things you love")
    static let unlimitedPhotopickAnalysis = localized("unlimited_photopick_analysis")
    static let storeInHighQuality = localized("store_in_high_quality")
    static let fiveAnalysis = localized("5_photopick_analysis")
    static let tenAnalysis = localized("10_photopick_analysis")
    static let dataPackageForTurkcell = localized("data_package_for_turkcell")
    static let deleteDuplicatedContacts = localized("delete_duplicated_contacts")
    static let additionalDataAdvantage = localized("additional_data_advantage")
    static let becomePremium = localized("Become Premium")
    static let becomePremiumMember = localized("Become Premium Member!")
    static let leavePremiumMember = localized("leave_premium_membership")
    static let leaveMiddleMember = localized("leave_middle_membership")
    static let standardUser = localized("Standard User")
    static let midUser = localized("mid_user")
    static let premiumUser = localized("Premium User")
    static let middleUser = localized("middle_user")
    static let lifeboxPremium = localized("lifebox Premium")
    static let lifeboxMiddle = localized("lifebox_middle")
    static let lifeboxStandart = localized("lifebox_standart")
    static let deleteDuplicatedContactsForPremiumTitle = localized("Delete Duplicated Contacts For PremiumTitle")
    
    //MARK: - PremiumBanner
    static let premiumBannerMessage = localized("premium_banner_message")
    static let standardBannerMessage = localized("standard_banner_message")
    static let premiumBannerTitle = localized("premium_banner_title")
    static let standardBannerTitle = localized("standard_banner_title")
    static let allPeopleBecomePremiumText = localized("all_people_become_premium_text")
    static let noPeopleBecomePremiumText = localized("no_people_become_premium_text")

    static let backUpShort = localized("back_up_short")
    static let removeDuplicateShort = localized("remove_duplicate_short")
    static let placesRecognitionShort = localized("places_recognition_short")
    static let faceRecognitionShort = localized("face_recognition_short")
    static let objectRecognitionShort = localized("object_recognition_short")
    static let photoPickShort = localized("unlimited_photopick_analysis")

    //MARK: - LeavePremiumViewController
    
    static let leavePremiumPremiumDescription = localized("leave_premium_premium_description")
    static let leavePremiumCancelDescription = localized("leave_premium_cancel_description")

    static let accountDetailMiddleTitle = localized("account_detail_middle_title")
    static let accountDetailMiddleDescription = localized("account_detail_middle_description")

    static let accountDetailStandartTitle = localized("account_detail_standart_title")
    static let accountDetailStandartDescription = localized("account_detail_standart_description")
    
    static let leaveMiddleTurkcell = localized("leave_middle_turkcell")
    
    static let featureAppleCancelText = localized("feature_apple_cancel_text")
    static let featureSLCMCancelText = localized("feature_slcm_cancel_text")
    static let featureGoogleCancelText = localized("feature_google_cancel_text")
    static let featureFreeOfChargeCancelText = localized("feature_free_of_charge_cancel_text")
    static let featureLifeCellCancelText = localized("feature_lifecell_cancel_text")
    static let featurePromoCancelText = localized("feature_promo_cancel_text")
    static let featureKKTCellCancelText = localized("feature_kktcell_cancel_text")
    static let featureMoldCellCancelText = localized("feature_moldcell_cancel_text")
    static let featureAlbanianCancelText = localized("feature_albanian_cancel_text")
    static let featureDigicellCancelText = localized("feature_digicell_cancel_text")
    static let featureLifeCancelText = localized("feature_life_cancel_text")
    static let featurePaycellAllAccessCancelText = localized("feature_paycell_all_access_cancel_text")
    static let featurePaycellSLCMCancelText = localized("feature_paycell_slcm_cancel_text")
    static let featureSLCMPaycellCancelText = localized("feature_slcm_paycell_cancel_text")
    static let featureAllAccessPaycellCancelText = localized("feature_all_access_paycell_cancel_text")
    static let featureDefaultCancelText = localized("feature_default_cancel_text")
    
    //MARK: - PackageInfoView
    static let usage = localized("storage_usage_information")
    static let myStorage = localized("my_storage")
    static let myPackages = localized("my_packages")
    static let seeDetails = localized("see_details")
    static let faceImageGroupingDescription = localized("face_image_description")
    static let faceImageUpgrade = localized("face_image_upgrade")
    static let faceTagsDescriptionStandart = localized("face_tags_description_standart")
    
    static let homePagePopup = localized("home_page_pop_up")
    static let syncPopup = localized("sync_page_pop_up")
    static let descriptionAboutStandartUser = localized("uploded_photos_high_quality")
    static let yesForUpgrade = localized("ok_for_upgrade")
    static let noForUpgrade = localized("no_for_upgrade")
    
    //MARK: - InstaPick Analyze History Page
    static let analyzeHistorySeeDetails = localized("instapick_see_details")
    static let analyzeHistoryTitle = localized("InstaPick")
    static let analyzeHistoryPopupTitle = localized("no_analyses_left_title")
    static let analyzeHistoryPopupMessage = localized("no_analyses_left_message")
    static let analyzeHistoryFreeText = localized("analyze_history_free_text")
    static let analyzeHistoryEmptyTitle = localized("analyze_history_empty_title")
    static let analyzeHistoryEmptySubtitle = localized("analyze_history_empty_subtitle")
    static let analyzeHistoryAnalyzeLeft = localized("analyze_history_analyze_left")
    static let analyzeHistoryAnalyzeCount = localized("analyze_history_analyze_count")
    static let analyzeHistoryAnalyseButton = localized("analyze_with_instapick")
    static let analyzeHistoryPhotosCount = localized("analyze_history_photos_count")
    static let analyzeHistoryStartHereTitle = localized("analyze_history_start_here")
    static let analyzeHistoryConfirmDeleteTitle = localized("analyze_confirm_delete_title")
    static let analyzeHistoryConfirmDeleteText = localized("analyze_confirm_delete_text")
    static let analyzeHistoryConfirmDeleteYes = localized("analyze_confirm_delete_yes")
    static let analyzeHistoryConfirmDeleteNo = localized("analyze_confirm_delete_no")
    static let analyzeHistoryDeleteSuccessFormat = localized("analyze_history_delete_success")
    //MARK: - InstapickUpgradePopup
    static let instapickUpgradePopupText = localized("instapick_upgrade_popup_text")
    static let instapickUpgradePopupButton = localized("instapick_upgrade_popup_button")
    static let instapickUpgradePopupNoButton = localized("instapick_upgrade_popup_no")
    //MARK: - InstaPickThreeDors
    static let newInstaPick = localized("new_insta_pick")
    //MARK: - InstaPickCard
    static let instaPickUsedBeforeTitleLabel = localized("used_before_title_label")
    static let instaPickNoUsedBeforeTitleLabel = localized("no_used_before_title_label")
    static let instaPickNoAnalysisTitleLabel = localized("no_analysis_title_label")
    static let instaPickFreeTrialTitleLabel = localized("free_trial_title_label")

    static let instaPickUsedBeforeDetailLabel = localized("used_before_detail_label")
    static let instaPickNoUsedBeforeDetailLabel = localized("no_used_before_detail_label")
    static let instaPickNoAnalysisDetailLabel = localized("no_analysis_detail_label")
    static let instaPickFreeTrialDetailLabel = localized("free_trial_detail_label")
    
    static let instaPickButtonHasAnalysis = localized("instapick_button_has_analysis")
    static let instaPickButtonNoAnalysis = localized("no_analyses_left_button")
    
    static let analyzeWithInstapick = localized("analyze_with_instapick")
    //InstaPickDetailViewController
    
    static let instaPickReadyToShareLabel = localized("you_are_ready_to_share")
    static let instaPickLeftCountLabel = localized("instapick_analysis_left")
    static let instaPickUnlimitedLeftCountLabel = localized("instapick_unlimited_analysis")
    static let instaPickMoreHashtagsLabel = localized("engage_with_more_hastags")
    static let instaPickCopyHashtagsButton = localized("copy_hashtags_to_clipboard")
    static let instaPickShareButton = localized("share_on_social_media")
    
    static let instaPickPictureNotFoundLabel = localized("insta_pick_picture_not_found")
    static let instaPickPickedLabel = localized("picked")
    static let instaPickAnalyzingBottomText = localized("insta_pick_analyzing_bottom")
    static let instaPickAnalyzingText_0 = localized("insta_pick_analyzing_0")
    static let instaPickAnalyzingText_1 = localized("insta_pick_analyzing_1")
    static let instaPickAnalyzingText_2 = localized("insta_pick_analyzing_2")
    static let instaPickAnalyzingText_3 = localized("insta_pick_analyzing_3")
    static let instaPickAnalyzingText_4 = localized("insta_pick_analyzing_4")
    //MARK: - InstaPickPopUp
    static let instaPickDontShowThisAgain = localized("dont_show_this_again")
    static let instaPickAnlyze = localized("instapick_analyze")
    static let instaPickConnectedAccount = localized("connected_account")
    static let instaPickDescription = localized("instapick_description")
    static let instaPickConnectedWithInstagram = localized("connected_with_instagram")
    static let instaPickConnectedWithInstagramName = localized("connected_with_instagram_name")
    static let instaPickConnectedWithoutInstagram = localized("continue_without_connecting")
    
    static let instapickSelectionPhotosSelected = localized("instapick_selection_photos_selected")
    static let instapickSelectionAnalyzesLeftMax = localized("instapick_selection_analyzes_left_max")
    static let instapickUnderConstruction = localized("instapick_under_construction")
    static let instapickUnsupportedFileType = localized("instapick_unsupported_file_type")
    static let instapickNoAvailableUnitsLeft = localized("instapick_no_available_units_left")
    static let instapickConnectionProblemOccured = localized("connection_problem_occured")
    static let loading = localized("loading")
    static let thereAreNoPhotos = localized("there_are_no_photos")
    static let thereAreNoAlbums = localized("there_are_no_albums")
    
    static let thereAreNoPhotosFavorites = localized("there_are_no_photos_favorites")
    static let thereAreNoPhotosAll = localized("there_are_no_photos_all")
    
    static let facebook = localized("Facebook")
    static let dropbox = localized("Dropbox")
    static let instagram = localized("Instagram")
    static let spotify = localized("Spotify")
    
    static let instagramConnectedAsFormat = localized("connected_as_format")
    static let spotyfyLastImportFormat = localized("spotify_last_import")
    
    static let instagramRemoveConnectionWarning = localized("instagram_remove_connection_warning_title")
    static let facebookRemoveConnectionWarning = localized("facebook_remove_connection_warning_title")
    static let dropboxRemoveConnectionWarning = localized("dropbox_remove_connection_warning_title")
    static let spotifyRemoveConnectionWarning = localized("spotify_remove_connection_warning_title")
    static let instagramRemoveConnectionWarningMessage = localized("instagram_remove_connection_warning_message")
    static let facebookRemoveConnectionWarningMessage = localized("facebook_remove_connection_warning_message")
    static let dropboxRemoveConnectionWarningMessage = localized("dropbox_remove_connection_warning_message")
    static let spotifyRemoveConnectionWarningMessage = localized("spotify_remove_connection_warning_message")
    static let removeConnection = localized("remove_connection")
    static let youAreConnected = localized("you_are_connected")
    static let phoneUpdatedNeedsLogin = localized("phone_updated_needs_login")
    
    static let oldPassword = localized("old_password")
    static let newPassword = localized("new_password")
    static let repeatPassword = localized("repeat_password")
    static let changePasswordCaptchaAnswerPlaceholder = localized("change_password_captcha_answer_placeholder")
    static let temporaryErrorOccurredTryAgainLater = localized("temporary_error_occurred_try_again_later")
    static let oldPasswordDoesNotMatch = localized("old_password_does_not_match")
    static let newPasswordAndRepeatedPasswordDoesNotMatch = localized("new_password_and_repeated_password_does_not_match")
    static let newPasswordIsEmpty = localized("new_password_is_empty")
    static let oldPasswordIsEmpty = localized("old_password_is_empty")
    static let repeatPasswordIsEmpty = localized("repeat_password_is_empty")
    static let thisTextIsEmpty = localized("this_text_is_empty")
    static let passwordChangedSuccessfully = localized("password_changed_successfully")
    static let passwordChangedSuccessfullyRelogin = localized("password_changed_successfully_relogin")
    static let passwordInResentHistory = localized("password_in_resent_history")
    static let uppercaseMissInPassword = localized("uppercase_miss_in_password")
    static let lowercaseMissInPassword = localized("lowercase_miss_in_password")
    static let numberMissInPassword = localized("number_miss_in_password")
    static let passwordFieldIsEmpty = localized("password_field_is_empty")
    static let passwordLengthIsBelowLimit = localized("password_length_below_limit")
    static let passwordLengthExceeded = localized("password_length_exceede")
    static let passwordSequentialCaharacters = localized("password_sequential_caharacters")
    static let passwordSameCaharacters = localized("password_same_caharacters")
    static let captchaAnswerPlaceholder = localized("captcha_answer_placeholder")
    static let profilePhoneNumberTitle = localized("profile_phone_number_title")
    static let profilePhoneNumberPlaceholder = localized("profile_phone_number_placeholder")
    
    static let pleaseEnterYourName = localized("please_enter_your_name")
    static let enterYourName = localized("enter_your_name")
    static let pleaseEnterYourSurname = localized("please_enter_your_surname")
    static let enterYourSurname = localized("enter_your_surname")
    static let enterYourEmailAddress = localized("enter_your_email_address")
    static let subject = localized("subject")
    static let pleaseEnterYourSubject = localized("please_enter_your_subject")
    static let pleaseChooseSubject = localized("please_choose_subject")
    static let yourProblem = localized("your_problem")
    
    static let pleaseEnterYourProblemShortly = localized("please_enter_your_problem_shortly")
    static let explainYourProblemShortly = localized("explain_your_problem_shortly")
    static let pleaseEnterMsisdnOrEmail = localized("please_enter_msisdn_or_email")
    static let supportFormProblemDescription = localized("support_form_problem_description")
    
    static let onLoginSupportFormSubject1 = localized("support_form_subject_1")
    static let onLoginSupportFormSubject2 = localized("support_form_subject_2")
    static let onLoginSupportFormSubject3 = localized("support_form_subject_3")
    static let onLoginSupportFormSubject4 = localized("support_form_subject_4")
    static let onLoginSupportFormSubject5 = localized("support_form_subject_5")
    static let onLoginSupportFormSubject6 = localized("support_form_subject_6")
    static let onLoginSupportFormSubject7 = localized("support_form_subject_7")
    
    static let onLoginSupportFormSubject1InfoLabel = localized("support_form_subject_1_detailed_info_label")
    static let onLoginSupportFormSubject2InfoLabel = localized("support_form_subject_2_detailed_info_label")
    static let onLoginSupportFormSubject3InfoLabel = localized("support_form_subject_3_detailed_info_label")
    static let onLoginSupportFormSubject4InfoLabel = localized("support_form_subject_4_detailed_info_label")
    static let onLoginSupportFormSubject5InfoLabel = localized("support_form_subject_5_detailed_info_label")
    static let onLoginSupportFormSubject6InfoLabel = localized("support_form_subject_6_detailed_info_label")
    static let onLoginSupportFormSubject7InfoLabel = localized("support_form_subject_7_detailed_info_label")
    
    static let onLoginSupportFormSubject1DetailedInfoText = localized("support_form_subject_1_detailed_info_fulltext")
    static let onLoginSupportFormSubject2DetailedInfoText = localized("support_form_subject_2_detailed_info_fulltext")
    static let onLoginSupportFormSubject3DetailedInfoText = localized("support_form_subject_3_detailed_info_fulltext")
    static let onLoginSupportFormSubject4DetailedInfoText = localized("support_form_subject_4_detailed_info_fulltext")
    static let onLoginSupportFormSubject5DetailedInfoText = localized("support_form_subject_5_detailed_info_fulltext")
    static let onLoginSupportFormSubject6DetailedInfoText = localized("support_form_subject_6_detailed_info_fulltext")
    static let onLoginSupportFormSubject7DetailedInfoText = localized("support_form_subject_7_detailed_info_fulltext")
    
    static let onSignupSupportFormSubject1 = localized("support_form_signup_subject_1")
    static let onSignupSupportFormSubject2 = localized("support_form_signup_subject_2")
    static let onSignupSupportFormSubject3 = localized("support_form_signup_subject_3")
    
    static let onSignupSupportFormSubject1InfoLabel = localized("signup_support_form_subject_1_detailed_info_label")
    static let onSignupSupportFormSubject2InfoLabel = localized("signup_support_form_subject_2_detailed_info_label")
    static let onSignupSupportFormSubject3InfoLabel = localized("signup_support_form_subject_3_detailed_info_label")

    static let onSignupSupportFormSubject1DetailedInfoText = localized("signup_support_form_subject_1_detailed_info_fulltext")
    static let onSignupSupportFormSubject2DetailedInfoText = localized("signup_support_form_subject_2_detailed_info_fulltext")
    static let onSignupSupportFormSubject3DetailedInfoText = localized("signup_support_form_subject_3_detailed_info_fulltext")
    
    static let contactUsSubject1 = localized("contact_us_subject_1")
    static let contactUsSubject2 = localized("contact_us_subject_2")
    static let contactUsSubject3 = localized("contact_us_subject_3")
    static let contactUsSubject4 = localized("contact_us_subject_4")
    static let contactUsSubject5 = localized("contact_us_subject_5")
    static let contactUsSubject6 = localized("contact_us_subject_6")
    static let contactUsSubject7 = localized("contact_us_subject_7")
    static let contactUsSubject8 = localized("contact_us_subject_8")
    static let contactUsSubject9 = localized("contact_us_subject_9")
    static let contactUsSubject10 = localized("contact_us_subject_10")
    static let contactUsSubject11 = localized("contact_us_subject_11")
    static let contactUsSubject12 = localized("contact_us_subject_12")
    
    static let enterYourOldPassword = localized("enter_your_old_password")
    static let enterYourNewPassword = localized("enter_your_new_password")
    static let enterYourRepeatPassword = localized("enter_your_repeat_password")
    
    static let enterYourPassword = localized("enter_your_password")
    static let reenterYourPassword = localized("re_enter_your_password")
    static let signupSupportInfo = localized("signup_support_info")
    static let loginSupportInfo = localized("login_support_info")
    static let signupFAQInfo = localized("signup_faq_info")
    static let loginFAQInfo = localized("login_faq_info")

    static let missingInformation = localized("missing_information")
    static let pleaseEnterYourMissingAccountInformation = localized("please_enter_your_missing_account_information")
    static let loginEmailOrPhonePlaceholder = localized("login_email_or_phone_placeholder")
    static let loginPasswordPlaceholder = localized("login_password_placeholder")
    
    static let loginEmailOrPhoneError = localized("login_email_or_phone_error")
    static let loginPasswordError = localized("login_password_error")
    
    static let captchaIsEmpty = localized("captcha_is_empty")
    static let loginUsernameNotValid = localized("login_username_not_valid")
    static let myProfileFAQ = localized("frequently_asked_questions")
    
    static let photoPickDescription = localized("photo_pick_description")
    
    static let createStoryPhotosSelected = localized("create_story_photos_selected")
    static let createStoryPressAndHoldDescription = localized("create_story_press_and_hold_description")
    static let createStoryPressAndHold = localized("create_story_press_and_hold")
    static let createStoryNameTitle = localized("create_story_name_title")
    
    static let createStoryPopUpTitle = localized("create_story_pop_up_title")
    static let createStoryPopUpMessage = localized("create_story_pop_up_message")
    static let createStoryPathToStory = localized("create_story_path_to_story")
    
    static let downloadLimitAllert = localized("selected_items_limit_download")
    static let deleteLimitAllert = localized("selected_items_limit_delete")
    static let hideLimitAllert = localized("selected_items_limit_hide")
    static let loginSettingsSecurityPasscodeDescription = localized("login_settings_security_passcode_description")
    static let loginSettingsSecurityAutologinDescription = localized("login_settings_security_autologin_description")
    static let loginSettingsTwoFactorAuthDescription = localized("login_settings_two_factor_auth_description")
    
    static let twoFAInvalidSessionErrorMessage = localized("two_fa_invalid_session_error_message")
    static let twoFAInvalidChallengeErrorMessage = localized("two_fa_invalid_challenge_error_message")
    static let twoFATooManyAttemptsErrorMessage = localized("two_fa_too_many_attempts_error_message")
    static let twoFAInvalidOtpErrorMessage = localized("two_fa_invalid_Otp_error_message")
    static let twoFATooManyRequestsErrorMessage = localized("two_fa_too_many_requests_error_message")
    
    static let twoFAEmailNewOTPDescription = localized("two_fa_email_new_otp_description")
    static let twoFAEmailExistingOTPDescription = localized("two_fa_email_existing_otp_description")
    static let twoFAPhoneNewOTPDescription = localized("two_fa_phone_new_otp_description")
    static let twoFAPhoneExistingOTPDescription = localized("two_fa_phone_existing_otp_description")

    //MARK: - Spotify
    
    enum Spotify {
        enum Import {
            static let navBarTitle = localized("spotify_import_navbar_title")
            static let importing = localized("spotify_importing")
            static let fromSpotify = localized("spotify_import_from")
            static let toLifebox = localized("spotify_import_to")
            static let description = localized("spotify_import_description")
            static let importInBackground = localized("spotify_import_in_background")
            static let lastImportFromSpotifyFailedError = localized("spotify_import_failed_error")
        }
        enum Playlist {
            static let importButton = localized("spotify_playlist_import_button")
            static let navBarTitle = localized("spotify_playlist_navbar_title")
            static let navBarSelectiontTitle = localized("spotify_playlist_navbar_selection_title")
            static let songsCount = localized("spotify_playlist_songs_count")
            static let successImport = localized("spotify_playlist_success_import")
            static let seeImported = localized("spotify_playlist_see_imported")
            static let transferingPlaylistError = localized("spotify_trasfering_playlist_error")
            static let noPlaylists = localized("spotify_no_playlists")
            static let noImportedPlaylists = localized("spotify_no_imported_playlists")
            static let noTracks = localized("spotify_no_tracks")
        }
        enum OverwritePopup {
            static let message = localized("spotify_overwrite_message")
            static let messageBoldFontText = localized("spotify_overwrite_message_bold")
            static let cancelButton = localized("spotify_overwrite_cancel_button")
            static let importButton = localized("spotify_overwrite_import_button")
        }
        enum Card {
            static let title = localized("spotify_card_title")
            static let importing = localized("spotify_card_importing")
            static let lastUpdate = localized("spotify_card_last_update")
        }
        enum DeletePopup {
            static let title = localized("spotify_delete_title")
            static let titleBoldFontText = localized("spotify_delete_title_bold")
            static let subtitle = localized("spotify_delete_subtitle")
            static let deleteButton = localized("spotify_delete_delete_button")
        }
        enum CancelImportPopup {
            static let title = localized("spotify_cancel_import_title")
            static let titleBoldFontText = localized("spotify_cancel_import_title_bold")
            static let subtitle = localized("spotify_cancel_import_subtitle")
            static let continueButton = localized("spotify_cancel_import_continue_button")
            static let cancelButton = localized("spotify_cancel_import_cancel_button")
        }
    }
    static let confirm = localized("confirm")
    static let later = localized("later")
    static let changeEmail = localized("change_email")
    static let verifyEmailTopTitle = localized("verify_email_top_title")
    static let enterTheSecurityCode = localized("enter_the_security_code")
    
    static let change = localized("change")
    static let fieldsAreNotMatch = localized("fields_are_not_matched")
    static let yourEmail = localized("your_email")
    static let confirmYourEmail = localized("confirm_your_email")
    static let enterYourEmail = localized("enter_your_email")
    static let changeEmailPopUpTopTitle = localized("change_email_pop_up_top_title")
    static let accountVerified = localized("account_verified")
    static let credUpdateCheckTitle = localized("cred_update_title")
    static let credUpdateCheckCompletionMessage = localized("cred_completion_message")

    static let noAccountFound = localized("no_account_found")
    static let tooManyRequests = localized("too_many_requests")
    static let invalidOTP = localized("invalid_otp")
    static let expiredOTP = localized("expired_otp")
    static let tokenIsMissing = localized("token_is_missing")
    static let invalidEmail = localized("invalid_email")
    
    static let storage = localized("storage")
    static let paymentTitleAppStore = localized("payment_title_app_store")
    static let paymentTitleCreditCard = localized("payment_title_credit_card")
    static let paymentTitleInvoice = localized("payment_title_invoice")
    static let accountStatusTitle = localized("account_status_title")
    static let accountStatusMessage = localized("account_status_message")
    
    static let tbMaticPhotosTitle = localized("tbmatic_photos_title")
    static let tbMaticPhotosNoPhotoText = localized("tbmatic_photos_no_photo_text")
    static let tbMaticPhotosNoPhotoBoldText = localized("tbmatic_photos_no_photo_bold_text")
    static let tbMaticPhotosSeeTimeline = localized("tbmatic_photos_see_timeline")
    static let tbMaticPhotosShare = localized("tbmatic_photos_share")
    
    static let tbMatiHomeCardTitle = localized("tbmatic_home_card_title")
    static let tbMatiHomeCardSubtitle = localized("tbmatic_home_card_subtitle")
    static let tbMatiHomeCardButtonTitle = localized("tbmatic_home_card_button_title")
    static let tbMatiHomeCardYearAgo = localized("tbmatic_home_card_year_ago")
    static let tbMatiHomeCardYearsAgo = localized("tbmatic_home_card_years_ago")
    static let tbMatiHomeCardThisYear = localized("tbmatic_home_card_this_year")

    static let campaignDetailTitle = localized("campaign_detail_title")
    static let campaignDetailMoreInfoButton = localized("campaign_detail_more_info_button")
    static let campaignDetailContestInfoTitle = localized("campaign_detail_contest_info_title")
    static let campaignDetailContestInfoTotalDraw = localized("campaign_detail_contest_info_total_draw")
    static let campaignDetailContestInfoRemainingDraw = localized("campaign_detail_contest_info_remaining_draw")
    static let campaignDetailIntroTitle = localized("campaign_detail_intro_title")
    static let campaignDetailIntroGift = localized("campaign_detail_intro_gift")
    static let campaignDetailIntroCelebration = localized("campaign_detail_intro_celebration")
    static let campaignDetailIntroNounCelebration = localized("campaign_detail_intro_noun_celebration")
    static let campaignDetailInfoTitle = localized("campaign_detail_info_title")
    static let campaignDetailInfoDescription = localized("campaign_detail_info_description")
    static let createStoryEmptyNameError = localized("create_story_empty_name_error")
    
    
    static let photopickHistoryCampaignContestTotalDraw = localized("photopick_history_campaign_contest_total_draw")
    static let photopickHistoryCampaignRemainingDraw = localized("photopick_history_campaign_contest_remaining_draw")
    
    static let updateAddressError = localized("update_address_error")
    static let profileDetailAddressTitle = localized("profile_detail_address_title")
    static let profileDetailAddressSubtitle = localized("profile_detail_address_subtitle")
    static let profileDetailAddressPlaceholder = localized("profile_detail_address_placeholder")
    static let profileDetailErrorContactCallCenter = localized("profile_detail_error_contact_call_center")
    
    static let instagramNotConnected = localized("temporary_error")

    static let hideSinglePhotoCompletionAlertMessage = localized("hide_single_photo_completion_alert_message")

    static let peopleAlbumWarningAlertTitle1 = localized("people_album_warning_alert_title_not_premium_and_no_image_grouping")
    static let peopleAlbumWarningAlertTitle2 = localized("people_album_warning_alert_title_not_premium_and_image_grouping_on")
    static let peopleAlbumWarningAlertTitle3 = localized("people_album_warning_alert_title_premium_and_no_image_grouping")

    static let peopleAlbumWarningAlertMessage1 = localized("people_album_warning_message_not_premium_and_no_image_grouping")
    static let peopleAlbumWarningAlertMessage2 = localized("people_album_warning_message_not_premium_and_image_grouping_on")
    static let peopleAlbumWarningAlertMessage3 = localized("people_album_warning_message_premium_and_no_image_grouping")

    static let peopleAlbumWarningAlertButton1 = localized("people_album_warning_button_not_premium_and_no_image_grouping")
    static let peopleAlbumWarningAlertButton2 = localized("people_album_warning_button_not_premium_and_image_grouping_on")
    static let peopleAlbumWarningAlertButton3 = localized("people_album_warning_button_premium_and_no_image_grouping")

    static let hideSuccessedAlertPeopleAlbumTitle = localized("hide_successed_alert_people_album_title")
    static let hideSuccessedAlertPeopleAlbumDescription = localized("hide_successed_alert_people_album_description")
    static let hideSuccessedAlertDoNotShowAgain = localized("hide_successed_alert_do_not_show_this_message")
    static let hideSuccessedAlertViewPeopleAlbum = localized("hide_successed_alert_view_people_album")
    static let hideSuccessedAlertWithPeopleAlbumTitle = localized("hide_successed_alert_with_people_album_title")
    static let hideSuccessedAlertTitle = localized("hide_successed_alert_title")
    
    static let smashSuccessedAlertTitle = localized("smash_successed_alert_title")
    static let smashSuccessedAlertSecondTitle = localized("smash_successed_alert_second_title")
    static let smashSuccessedAlertDescription = localized("smash_successed_alert_description")
    static let smashSuccessedAlertShareButton = localized("smash_successed_alert_share")
    static let smashSuccessedSimpleAlertTitle = localized("smash_successed_simple_alert_title")
    static let smashSuccessedSimpleAlertDescription = localized("smash_successed_simple_alert_description")

    //MARK: -Carousel Pager Header
    static let carouselViewFirstPageText = localized("carousel_view_first_page_text")
    static let carouselViewFirstPageTitle = localized("carousel_view_first_page_title")
    static let carouselViewSecondPageText = localized("carousel_view_second_page_text")
    static let carouselViewSecondPageTitle = localized("carousel_view_second_page_title")
    static let carouselViewThirdPageText = localized("carousel_view_third_page_text")
    static let carouselViewThirdPageTitle = localized("carousel_view_third_page_title")

    static let hiddenBinAlbumSliderTitle = localized("hidden_bin_album_slider_title")
    static let hiddenBinAlbumSliderEmpty = localized("hidden_bin_album_slider_empty")
    static let hiddenBinEmpty = localized("hidden_bin_empty")
    static let hiddenBinNavBarTitle = localized("hidden_bin_navbar_title")
    static let unhidePopupText = localized("unhide_popup_text")
    static let unhidePopupSuccessText = localized("unhide_popup_success_text")
    
    static let deleteFromHiddenBinPopupSuccessTitle = localized("delete_from_hidden_bin_popup_success_title")
    static let deleteFromHiddenBinPopupSuccessText = localized("delete_from_hidden_bin_popup_success_text")
    
    static let deleteConfirmationPopupText = localized("delete_confirmation_popup_text")
    static let deletePopupSuccessText = localized("delete_popup_success_text")
    
    static let restoreConfirmationPopupText = localized("restore_confirmation_popup_text")
    static let restorePopupSuccessText = localized("restore_popup_success_text")
    static let unhideItemsPopupText = localized("unhide_items_popup_text")
    static let unhideAlbumsPopupText = localized("unhide_albums_popup_text")
    static let deletePopupText = localized("delete_popup_text")
    static let unhidePopupSuccessTitle = localized("unhide_popup_success_title")
    
    static let moveToTrashHiddenAlbumsConfirmationPopupText = localized("move_to_trash_hidden_albums_confirmation_popup_text")

    static let deleteConfirmationPopupTitle = localized("delete_confirmation_popup_title")
    static let deleteItemsConfirmationPopupText = localized("delete_items_confirmation_popup_text")
    static let deleteAlbumsConfirmationPopupText = localized("delete_albums_confirmation_popup_text")
    static let deleteFoldersConfirmationPopupText = localized("delete_folders_confirmation_popup_text")
    
    static let restoreConfirmationPopupTitle = localized("restore_confirmation_popup_title")
    static let restoreItemsConfirmationPopupText = localized("restore_items_confirmation_popup_text")
    static let restoreAlbumsConfirmationPopupText = localized("restore_albums_confirmation_popup_text")
    static let restoreFoldersConfirmationPopupText = localized("restore_folders_confirmation_popup_text")

    static let trashBinAlbumSliderTitle = localized("trash_bin_album_slider_title")
    static let trashBinAlbumSliderEmpty = localized("trash_bin_album_slider_empty")
    static let trashBinEmpty = localized("trash_bin_empty")
    static let trashBinDeleteAllConfirmTitle = localized("confirm_dialog_header_empty_trashbin")
    static let trashBinDeleteAllConfirmText = localized("confirm_empty_trashbin")
    static let trashBinDeleteAllConfirmOkButton = localized("confirm_empty_trashbin_button")
    static let trashBinDeleteAllComplete = localized("success_empty_trashbin")
    static let turkcellUpdateRequiredTitle = localized("turkcell_updater_update_required_title")
    static let turkcellUpdateRequiredMessage = localized("turkcell_updater_update_required_message")
    
    static let moveToTrashItemsSuccessText = localized("move_to_trash_items_success_text")
    static let moveToTrashAlbumsSuccessText = localized("move_to_trash_albums_success_text")
    static let moveToTrashFoldersSuccessText = localized("move_to_trash_folders_success_text")
    
    static let unhideItemsSuccessText = localized("unhide_items_success_text")
    static let unhideAlbumsSuccessText = localized("unhide_albums_success_text")
    static let unhideFoldersSuccessText = localized("unhide_folders_success_text")
    
    static let deleteItemsSuccessText = localized("delete_items_success_text")
    static let deleteAlbumsSuccessText = localized("delete_albums_success_text")
    static let deleteFoldersSuccessText = localized("delete_folders_success_text")
    
    static let restoreItemsSuccessText = localized("restore_items_success_text")
    static let restoreAlbumsSuccessText = localized("restore_albums_success_text")
    static let restoreFoldersSuccessText = localized("restore_folders_success_text")
    
    //MARK: - FullQuotaWarningPopUp
    static let fullQuotaWarningPopUpTitle = localized("full_quota_warning_popup_title")
    static let fullQuotaWarningPopUpDescription = localized("full_quota_warning_popup_description")
    static let expandMyStorage = localized("expand_my_storage")
    static let deleteFiles = localized("delete_files")
    
    static let weRecommend = localized("we_recommend")
    static let showMore = localized("show_more")
    static let seeFeatures = localized("see_features")
    static let showLess = localized("show_less")
    static let faceRecognitionPackageDescription = localized("face_recognition_package_description")
    static let deleteDublicatePackageDescription = localized("delete_dublicate_package_description")
    static let premiumUserPackageDescription = localized("premium_user_package_description")
    static let middleUserPackageDescription = localized("middle_user_package_description")
    static let originalCopyPackageDescription = localized("original_сopy_package_description")
    static let bundlePackageAddonType = localized("bundle_package_addon_type")
    static let featuresOnlyAddonType = localized("features_only_package_addon_type")
    static let middleFeaturesOnlyAddonType = localized("features_middle_only_package_addon_type")
    static let featureHighQualityPicture = localized("feature_high_quality_picture")
    static let featureImageRecognition = localized("feature_image_recognition")
    static let featurePhotopick = localized("feature_photopick")
    static let featureDeleteDuplicationContacts = localized("feature_delete_duplicate_contacts")
    static let featureStandardFeatures = localized("feature_standard_features")
    static let storageOnlyPackageAddonType = localized("storage_only_package_addon_type")
    static let featurePackageName = localized("feature_package_name")
    static let middleFeaturePackageName = localized("middle_feature_package_name")
    
    static let becomePremiumNavBarTitle = localized("become_premium_navbar_title")
    static let becomePremiumHeaderDefaultTitle = localized("become_premium_header_default_title")
    static let becomePremiumHeaderDefaultSubtitle = localized("become_premium_header_default_subtitle")
    static let becomePremiumHeaderPeopleTitle = localized("become_premium_header_people_title")
    static let becomePremiumHeaderPeopleSubtitle = localized("become_premium_header_people_subtitle")
    static let becomePremiumHeaderPlacesTitle = localized("become_premium_header_places_title")
    static let becomePremiumHeaderPlacesSubtitle = localized("become_premium_header_places_subtitle")
    static let becomePremiumHeaderThingsTitle = localized("become_premium_header_things_title")
    static let becomePremiumHeaderThingsSubtitle = localized("become_premium_header_things_subtitle")
    static let becomePremiumHeaderContactSyncTitle = localized("become_premium_header_contact_sync_title")
    static let becomePremiumHeaderContactSyncSubtitle = localized("become_premium_header_contact_sync_subtitle")
    static let becomePremiumOrText = localized("become_premium_or_text")
    static let becomePremiumSeeAllPackages = localized("become_premium_see_all_packages")
    
    static let contactSyncConfirmPremiumPopupTitle = localized("contact_sync_confirm_premium_popup_title")
    static let contactSyncConfirmPremiumPopupText = localized("contact_sync_confirm_premium_popup_text")
    
    static let myPackagesDescription = localized("my_packages_description")
    
    static let featureStorageOnlyAdditional1 = localized("feature_storage_only_additional_1")
    static let featureStorageOnlyAdditional2 = localized("feature_storage_only_additional_2")

    static let snackbarOk = localized("snackbar_ok")
    static let snackbarTrashBin = localized("snackbar_trash_bin")
    static let snackbarHiddenBin = localized("snackbar_hidden_bin")
    
    static let snackbarMessageAddedToFavorites = localized("added_to_favorites_message")
    static let snackbarMessageRemovedFromFavorites = localized("removed_from_favorites")
    static let snackbarMessageAddedToAlbum = localized("added_to_album")
    static let snackbarMessageDownloadedFilesFormat = localized("downloaded_files")
    static let snackbarMessageEditSaved = localized("edit_saved")
    static let snackbarMessageRemovedFromAlbum = localized("removed_from_album_success")
    static let snackbarMessageFilesMoved = localized("files_moved")
    static let snackbarMessageResetPasscodeSuccess = localized("success_remove_passcode")
    static let snackbarMessageAddedToFavoritesFromLifeBox = localized("added_to_favorites_from_lifebox")
    static let snackbarMessageImportFromInstagramStarted = localized("import_from_instagram_started")
    static let snackbarMessageImportFromFBStarted = localized("import_from_facebook_started")
    static let snackbarMessageHashTagsCopied = localized("instapick_hashtags_copied")
    static let snackbarMessageCreateStoryLimit = localized("create_story_selection_limit")
    
    static let contactSyncBackupTitle = localized("contact_phase2_backup_contacts_title")
    static let contactSyncBackupMessage = localized("contact_phase2_backup_contacts_message")
    static let contactSyncBackupButton = localized("contact_phase2_backup_contacts_button")
    static let contactSyncSmallCardShowBackupMessage = localized("contact_phase2_small_card_backup_message")
    static let contactSyncSmallCardShowBackupButton = localized("contact_phase2_small_card_backup_button")
    static let contactSyncSmallCardDeleteDuplicatesMessage = localized("contact_phase2_small_card_duplicates_message")
    static let contactSyncSmallCardDeleteDuplicatesButton = localized("contact_phase2_small_card_duplicates_button")
    static let contactSyncBigCardBackupMessage = localized("contact_phase2_big_card_backup_message")
    static let contactSyncBigCardContacts = localized("contact_phase2_big_card_contacts")
    static let contactSyncBigCardSeeContactsButton = localized("contact_phase2_big_card_see_contacts_button")
    static let contactSyncBigCardAutobackupFormat = localized("contact_phase2_big_card_autobackup_format")
    static let contactSyncBackupProgressTitle = localized("contact_phase2_backup_progress_title")
    static let contactSyncBackupProgressMessage = localized("contact_phase2_backup_progress_message")
    static let contactSyncCancelAnalyzeButton = localized("contact_phase2_cancel_analyze_button")
    static let contactSyncAnalyzeProgressMessage = localized("contact_phase2_analyze_progress_message")
    
    static let contactSyncErrorRemoteServer1101 = localized("contact_phase2_error_RemoteServer1101")
    static let contactSyncErrorRemoteServer2000 = localized("contact_phase2_error_RemoteServer2000")
    static let contactSyncErrorRemoteServer3000 = localized("contact_phase2_error_RemoteServer3000")
    static let contactSyncErrorRemoteServer4000 = localized("contact_phase2_error_RemoteServer4000")
    static let contactSyncErrorNetwork = localized("contact_phase2_error_network")
    static let contactSyncErrorIternal = localized("contact_phase2_error_iternal")
    static let contactSyncErrorQuotaRestore = localized("contact_phase2_error_quota_restore")
    static let contactSyncErrorQuotaBackup = localized("contact_phase2_error_quota_backup")
    
    static let contactSyncBackupSuccessCardTitle = localized("contact_phase2_delete_backup_success_card_title")
    static let contactSyncBackupSuccessCardMessage = localized("contact_phase2_delete_backup_success_card_message")
    static let contactBackupSuccessNavbarTitle = localized("contact_phase2_contact_backup_success_navbar_title")
    static let contactBackupSuccessTitle = localized("contact_phase2_contact_backup_success_title")
    static let contactBackupSuccessMessage = localized("contact_phase2_contact_backup_success_message")
    static let contactSyncErrorMessage = localized("contact_phase2_error_message")
    
    static let warningPopupContactPermissionsTitle = localized("contact_phase2_warning_popup_contact_permissions_title")
    static let warningPopupContactPermissionsMessage = localized("contact_phase2_warning_popup_contact_permissions_message")
    static let warningPopupContactPermissionsStorageButton = localized("contact_phase2_warning_popup_contact_permissions_storage_button")
    static let warningPopupContactPermissionsDeleteButton = localized("contact_phase2_warning_popup_contact_permissions_delete_button")
    
    static let warningPopupStorageLimitTitle = localized("contact_phase2_warning_popup_storage_limit_title")
    static let warningPopupStorageLimitMessage = localized("contact_phase2_warning_popup_storage_limit_message")
    static let warningPopupStorageLimitSettingsButton = localized("contact_phase2_warning_popup_storage_limit_settings_button")
    
    static let contactSyncErrorRestoreTitle = localized("contact_phase2_error_restore_title")
    static let contactSyncErrorBackupTitle = localized("contact_phase2_error_backup_title")
    static let contactSyncErrorDeleteTitle = localized("contact_phase2_error_delete_title")
    
    static let galleryFilterAll = localized("gallery_filter_all")
    static let galleryFilterSynced = localized("gallery_filter_synced")
    static let galleryFilterUnsynced = localized("gallery_filter_unsynced")
    static let galleryFilterActionSheetAll = localized("gallery_filter_action_sheet_all")
    static let galleryFilterActionSheetSynced  = localized("gallery_filter_action_sheet_synced")
    static let galleryFilterActionSheetUnsynced = localized("gallery_filter_action_sheet_unsynced")
    static let contactBackupResultNavBarTitle = localized("contact_phase2_result_backup_nav_bar_title")
    static let contactRestoreResultNavBarTitle = localized("contact_phase2_result_restore_nav_bar_title")
    static let contactDeleteBackUpResultNavBarTitle = localized("contact_phase2_result_delete_backup_nav_bar_title")
    static let contactDeleteDuplicatesResultNavBarTitle = localized("contact_phase2_result_delete_duplicates_nav_bar_title")
    static let contactDeleteAllContactsResultNavBarTitle = localized("contact_phase2_result_delete_all_contacts_nav_bar_title")
    
    static let photoEditNavBarSave = localized("photo_edit_navbar_save")
    static let photoEditSaveAsCopy = localized("photo_edit_save_as_copy")
    static let photoEditResetToOriginal = localized("photo_edit_reset_to_original")
    
    static let photoEditTabBarFilters = localized("photo_edit_tabbar_filters")
    static let photoEditTabBarAdjustments = localized("photo_edit_tabbar_adjustments")
    
    static let photoEditCloseAlertTitle = localized("photo_edit_close_alert_title")
    static let photoEditCloseAlertMessage = localized("photo_edit_close_alert_message")
    static let photoEditCloseAlertLeftButton = localized("photo_edit_close_alert_left_button")
    static let photoEditCloseAlertRightButton = localized("photo_edit_close_alert_right_button")
    
    static let photoEditModifyAlertTitle = localized("photo_edit_modify_alert_title")
    static let photoEditModifyAlertMessage = localized("photo_edit_modify_alert_message")
    static let photoEditModifyAlertLeftButton = localized("photo_edit_modify_alert_left_button")
    static let photoEditModifyAlertRightButton = localized("photo_edit_modify_alert_right_button")
    
    static let photoEditSaveAsCopyAlertTitle = localized("photo_edit_save_as_copy_alert_title")
    static let photoEditSaveAsCopyAlertMessage = localized("photo_edit_save_as_copy_alert_message")
    static let photoEditSaveAsCopyAlertLeftButton = localized("photo_edit_save_as_copy_alert_left_button")
    static let photoEditSaveAsCopyAlertRightButton = localized("photo_edit_save_as_copy_alert_right_button")
    
    static let photoEditModifySnackbarMessage = localized("photo_edit_modify_success_snackbar_message")
    static let photoEditSaveAsCopySnackbarMessage = localized("photo_edit_save_as_copy_success_snackbar_message")
    static let photoEditSaveImageErrorMessage = localized("photo_edit_save_image_error_message")
    
    static let photoEditFilterOriginal = localized("photo_edit_filter_original")
    static let photoEditFilterClarendon = localized("photo_edit_filter_clarendon")
    static let photoEditFilterMetropolis = localized("photo_edit_filter_metropolis")
    static let photoEditFilterLime = localized("photo_edit_filter_lime")
    static let photoEditFilterAdele = localized("photo_edit_filter_adele")
    static let photoEditFilterAmazon = localized("photo_edit_filter_amazon")
    static let photoEditFilterApril = localized("photo_edit_filter_april")
    static let photoEditFilterAudrey = localized("photo_edit_filter_audrey")
    static let photoEditFilterAweStruck = localized("photo_edit_filter_aweStruck")
    static let photoEditFilterBluemess = localized("photo_edit_filter_bluemess")
    static let photoEditFilterCruz = localized("photo_edit_filter_cruz")
    static let photoEditFilterHaan = localized("photo_edit_filter_haan")
    static let photoEditFilterMars = localized("photo_edit_filter_mars")
    static let photoEditFilteroOldMan = localized("photo_edit_filter_oldMan")
    static let photoEditFilterRise = localized("photo_edit_filter_rise")
    static let photoEditFilterStarlit = localized("photo_edit_filter_starlit")
    static let photoEditFilterWhisper = localized("photo_edit_filter_whisper")
    
    static let photoEditAdjust = localized("photo_edit_adjust")
    static let photoEditLight = localized("photo_edit_light")
    static let photoEditColor = localized("photo_edit_color")
    static let photoEditEffect = localized("photo_edit_effect")
    static let photoEditHSL = localized("photo_edit_hsl")

    static let photoEditAdjustmentBrightness = localized("photo_edit_adjustment_brightness")
    static let photoEditAdjustmentContrast = localized("photo_edit_adjustment_contrast")
    static let photoEditAdjustmentExposure = localized("photo_edit_adjustment_exposure")
    static let photoEditAdjustmentHighlights = localized("photo_edit_adjustment_highlights")
    static let photoEditAdjustmentShadows = localized("photo_edit_adjustment_shadows")
    static let photoEditAdjustmentTemperature = localized("photo_edit_adjustment_temperature")
    static let photoEditAdjustmentTint = localized("photo_edit_adjustment_tint")
    static let photoEditAdjustmentSaturation = localized("photo_edit_adjustment_saturation")
    static let photoEditAdjustmentGamma = localized("photo_edit_adjustment_gamma")
    static let photoEditAdjustmentHue = localized("photo_edit_adjustment_hue")
    static let photoEditAdjustmentIntensity = localized("photo_edit_adjustment_intensity")
    static let photoEditAdjustmentAngle = localized("photo_edit_adjustment_angle")
    static let photoEditAdjustmentSharpness = localized("photo_edit_adjustment_sharpness")
    static let photoEditAdjustmentBlur = localized("photo_edit_adjustment_blur")
    static let photoEditAdjustmentVignette = localized("photo_edit_adjustment_vignette")
    
    static let photoEditRatioFree = localized("photo_edit_ratio_free")
    static let photoEditRatioOriginal = localized("photo_edit_ratio_original")
    
    //HomeWidget Rule 0
    static let widgetRule0SmallDetail = localized("widget_rule_0_small_detail")
    static let widgetRule0SmallButton = localized("widget_rule_0_small_button")
    static let widgetRule0MediumDetail = localized("widget_rule_0_medium_detail")
    static let widgetRule0MediumButton = localized("widget_rule_0_medium_button")
    
    //HomeWidget Rule 1
    static let widgetRule1SmallTitle = localized("widget_rule_1_small_title")
    static let widgetRule1SmallDetail = localized("widget_rule_1_small_detail")
    static let widgetRule1SmallButton = localized("widget_rule_1_small_button")
    
    static let widgetRule1MediumTitle = localized("widget_rule_1_medium_title")
    static let widgetRule1MediumDetail = localized("widget_rule_1_medium_detail")
    static let widgetRule1MediumButton = localized("widget_rule_1_medium_button")
    
    //HomeWidget Rule 2
    static let widgetRule2SmallTitle = localized("widget_rule_2_small_title")
    static let widgetRule2SmallDetail = localized("widget_rule_2_small_detail")
    static let widgetRule2SmallButton = localized("widget_rule_2_small_button")
    
    static let widgetRule2MediumTitle = localized("widget_rule_2_medium_title")
    static let widgetRule2MediumDetail = localized("widget_rule_2_medium_detail")
    static let widgetRule2MediumButton = localized("widget_rule_2_medium_button")
    
    //HomeWidget Rule 3.1
    
    static let widgetRule31SmallButton = localized("widget_rule_3_1_small_button")
    static let widgetRule31SmallDetail = localized("widget_rule_3_1_small_detail")
    static let widgetRule31MediumButton = localized("widget_rule_3_1_medium_button")
    static let widgetRule31MediumDetail = localized("widget_rule_3_1_medium_detail")
    
    //HomeWidget Rule 3.2
    
    static let widgetRule32SmallButton = localized("widget_rule_3_2_small_button")
    static let widgetRule32SmallDetail = localized("widget_rule_3_2_small_detail")
    static let widgetRule32MediumButton = localized("widget_rule_3_2_medium_button")
    static let widgetRule32MediumDetail = localized("widget_rule_3_2_medium_detail")
    
    //HomeWidget Rule 4.1
    static let widgetRule41SmallButton = localized("widget_rule_4_1_small_button")
    static let widgetRule41SmallDetail = localized("widget_rule_4_1_small_detail")
    static let widgetRule41MediumButton = localized("widget_rule_4_1_medium_button")
    static let widgetRule41MediumDetail = localized("widget_rule_4_1_medium_detail")

    //HomeWidget Rule 4.2
    static let widgetRule42SmallButton = localized("widget_rule_4_2_small_button")
    static let widgetRule42SmallDetail = localized("widget_rule_4_2_small_detail")
    static let widgetRule42MediumButton = localized("widget_rule_4_2_medium_button")
    static let widgetRule42MediumDetail = localized("widget_rule_4_2_medium_detail")
    
    //HomeWidget Rule 5
    
    static let widgetRule5SmallDetail = localized("widget_rule_5_small_detail")
    static let widgetRule5SmallButton = localized("widget_rule_5_small_button")
    
    static let widgetRule5MediumTitle = localized("widget_rule_5_medium_title")
    static let widgetRule5MediumDetail = localized("widget_rule_5_medium_detail")
    static let widgetRule5MediumButton = localized("widget_rule_5_medium_button")
    
    //HomeWidget Rule 6
    static let widgetRule6SmallDetail = localized("widget_rule_6_small_detail")
    static let widgetRule6SmallDetailPlural = localized("widget_rule_6_small_detail_plural")
    static let widgetRule6SmallButton = localized("widget_rule_6_small_button")
    
    static let widgetRule6MediumDetail = localized("widget_rule_6_medium_detail")
    static let widgetRule6MediumDetailPlural = localized("widget_rule_6_medium_detail_plural")
    static let widgetRule6MediumButton = localized("widget_rule_6_medium_button")
    
    //HomeWidget Rule 7.1
    static let widgetRule71SmallDetail = localized("widget_rule_7_1_small_detail")
    static let widgetRule71SmallButton = localized("widget_rule_7_1_small_button")
    
    static let widgetRule71MediumDetail = localized("widget_rule_7_1_medium_detail")
    static let widgetRule71MediumButton = localized("widget_rule_7_1_medium_button")
    
    //HomeWidget Rule 7.2
    static let widgetRule72SmallDetail = localized("widget_rule_7_2_small_detail")
    static let widgetRule72SmallButton = localized("widget_rule_7_2_small_button")
    
    static let widgetRule72MediumTitle = localized("widget_rule_7_2_medium_title")
    static let widgetRule72MediumDetail = localized("widget_rule_7_2_medium_detail")
    static let widgetRule72MediumButton = localized("widget_rule_7_2_medium_button")
    
    //HomeWidget Rule 7.3
    static let widgetRule73SmallDetail = localized("widget_rule_7_3_small_detail")
    static let widgetRule73SmallButton = localized("widget_rule_7_3_small_button")
    
    static let widgetRule73MediumDetail = localized("widget_rule_7_3_medium_detail")
    static let widgetRule73MediumButton = localized("widget_rule_7_3_medium_button")
    
    //HomeWidget Rule 7.4
    static let widgetRule74SmallDetail = localized("widget_rule_7_4_small_detail")
    static let widgetRule74SmallButton = localized("widget_rule_7_4_small_button")
    
    static let widgetRule74MediumDetail = localized("widget_rule_7_4_medium_detail")
    static let widgetRule74MediumButton = localized("widget_rule_7_4_medium_button")
    
    static let widgetDisplayName = localized("widget_display_name")
    static let widgetDescription = localized("widget_description")
    
    static let funGif = localized("fun_gif")
    static let funSticker = localized("fun_sticker")
    
    static let funCloseAlertTitle = localized("fun_close_alert_title")
    static let funCloseAlertMessage = localized("fun_close_alert_message")
    static let funCloseAlertLeftButton = localized("fun_close_alert_left_button")
    static let funCloseAlertRightButton = localized("fun_close_alert_right_button")
    
    static let privateShareStartPageName = localized("private_share_start_page_name")
    static let privateShareStartPageCloseButton = localized("private_share_start_page_cancel_button")
    static let privateShareStartPageShareButton = localized("private_share_start_page_share_button")
    static let privateShareStartPagePeopleSelectionTitle = localized("private_share_start_page_people_selection_section_name")
    static let privateShareStartPageEnterUserPlaceholder = localized("private_share_start_page_enter_user_field")
    static let privateShareStartPageSuggestionsTitle = localized("private_share_start_page_suggestions_section")    
    static let privateShareStartPageSharedWithTitle = localized("private_share_start_page_shared_with_section")
    static let privateShareStartPageAddMessageTitle = localized("private_share_start_page_add_message_section_name")
    static let privateShareStartPageMessagePlaceholder = localized("private_share_start_page_add_messge_field")
    static let privateShareStartPageDurationTitle = localized("private_share_start_page_share_duration_section_name")
    static let privateShareStartPageDurationNo = localized("private_share_start_page_share_duration_1")
    static let privateShareStartPageDurationHour = localized("private_share_start_page_share_duration_2")
    static let privateShareStartPageDurationDay = localized("private_share_start_page_share_duration_3")
    static let privateShareStartPageDurationWeek = localized("private_share_start_page_share_duration_4")
    static let privateShareStartPageDurationMonth = localized("private_share_start_page_share_duration_5")
    static let privateShareStartPageDurationYear = localized("private_share_start_page_share_duration_6")
    static let privateShareStartPageEditorButton = localized("private_share_start_page_role_1")
    static let privateShareStartPageViewerButton = localized("private_share_start_page_role_2")
    static let privateShareDetailsPageName = localized("private_share_details_page_name")
    static let privateShareSharedByMeTab = localized("private_share_shared_by_me_tab")
    static let privateShareSharedWithMeTab = localized("private_share_shared_with_me_tab")
    static let privateShareStartPageSuccess = localized("private_share_start_page_share_success")
    static let privateShareStartPageClosePopupMessage = localized("private_share_cancel_confirm")
    
    static let privateShareRoleSelectionTitle = localized("private_share_role_selection_page_name")
    static let privateShareRoleSelectionEditor = localized("private_share_role_selection_role_1")
    static let privateShareRoleSelectionViewer = localized("private_share_role_selection_role_2")
    static let privateShareValidationFailPopUpText = localized("private_share_msisdn_format")
    
    static let privateShareInfoMenuSectionTitle = localized("private_share_info_section_name")
    static let privateShareInfoMenuNumberOfPeople = localized("private_share_info_number_of_people")
    static let privateShareInfoMenuOwner = localized("private_share_info_role_1")
    static let privateShareInfoMenuEditor = localized("private_share_info_role_2")
    static let privateShareInfoMenuViewer = localized("private_share_info_role_3")
    static let privateShareInfoMenuVarying = localized("private_share_info_role_4")
    static let privateSharePhoneValidationFailPopUpText = localized("private_share_msisdn_format")
    static let privateShareEmailValidationFailPopUpText = localized("private_share_email_format")
    static let privateShareNonTurkishMsisdnPopUpText = localized("private_share_non_turkish_msisdn_warning")
    static let privateSharedWithMeEmptyText = localized("private_share_shared_with_me_empty_page")
    static let privateSharedByMeEmptyText = localized("private_share_shared_by_me_empty_page")
    static let privateSharedInnerFolderEmptyText = localized("private_share_inner_folder_empty_page")
    
    static let privateSharedEndSharingActionSuccess = localized("private_share_end_sharing_success")
    static let privateSharedEndSharingActionConfirmation = localized("private_share_end_sharing_confirm")
    static let privateSharedEndSharingActionTitle = localized("private_share_end_sharing_action_title")
    
    static let privateSharedLeaveSharingActionSuccess = localized("private_share_leave_sharing_success")
    static let privateSharedLeaveSharingActionConfirmation = localized("private_leave_sharing_confirm")
    static let privateSharedLeaveSharingActionTitle = localized("private_share_leave_sharing_action_title")
    
    static let privateShareWhoHasAccessTitle = localized("private_share_who_has_access_page_name")
    static let privateShareWhoHasAccessOwner = localized("private_share_who_has_access_role_1")
    static let privateShareWhoHasAccessEditor = localized("private_share_who_has_access_role_2")
    static let privateShareWhoHasAccessViewer = localized("private_share_who_has_access_role_3")
    static let privateShareWhoHasAccessVarying = localized("private_share_who_has_access_role_4")
    static let privateShareWhoHasAccessEndShare = localized("private_share_who_has_access_end_share")
    static let privateShareWhoHasAccessPopupMessage = localized("private_share_end_sharing_confirm")
    static let privateShareEndShareSuccess = localized("private_share_end_sharing_success")
    static let privateShareAllFilesSharedWithMe = localized("private_share_all_files_section_1")
    static let privateShareAllFilesSeeAll = localized("private_share_all_files_section_1_see_all")
    static let privateShareAllFilesMyFiles = localized("private_share_all_files_section_2")

    static let privateShareAccessEditor = localized("private_share_access_role_1")
    static let privateShareAccessViewer = localized("private_share_access_role_2")
    static let privateShareAccessRemove = localized("private_share_access_role_3")
    static let privateShareAccessVarying = localized("private_share_access_role_4")
    static let privateShareAccessTitle = localized("private_share_access_page_name")
    static let privateShareAccessFromFolder = localized("private_share_access_from_folder")
    static let privateShareAccessExpiresDate = localized("private_share_expire_date")
    static let privateShareAccessRoleChangeSuccess = localized("private_share_access_role_change_success")
    static let privateShareAccessDeleteConfirmPopupMessage = localized("private_share_access_remove_confirmation")
    static let privateShareAccessDeleteUserSuccess = localized("private_share_info_access_role_remove")
    static let privateSharePlusButtonNoAction = localized("private_share_plus_button_no_action")
    static let privateSharePreviewNotReady = localized("private_share_preview_not_ready")
    static let privateShareMoveToTrashSharedWithMeMessage = localized("private_share_confirm_trash_items")
    static let privateShareMaxNumberOfUsersMessageFormat = localized("private_share_start_max_number_of_users")
    static let privateShareMessageLimit = localized("private_share_long_message")
    static let privateSharePhoneOrMailLimit = localized("private_share_long_emailmsisdn")
    static let privateShareNumberOfItemsLimit = localized("private_share_max_number_of_item_limit_exceeded")
    static let settingsItemInvitation = localized("settings_item_invitation")
    static let titleInvitationCampaign = localized("title_invitation_campaign")
    static let titleInvitationLink = localized("title_invitation_link")
    static let titleInvitationFriends = localized("title_invitation_friends")
    static let titleInvitationPackages = localized("title_invitation_packages")
    static let invitationSnackbarCopy = localized("invitation_snackbar_copy")
    static let invitationShare = localized("invitation_share")
    static let invitationShareMessage = localized("invitation_share_message")
    static let invitationFriends = localized("invitation_friends")
    static let invitationSnackbarCopyExceed = localized("invitation_snackbar_copy_exceed")
    static let invitationSnackbarShareExceed = localized("invitation_snackbar_share_exceed")
    static let chatbotMenuTitle = localized("chatbot_menu_title")

    // MARK: - Print redirection warning
    static let warningPopupPrintRedirectTitle = localized("warning_popup_print_redirect_title")
    static let warningPopupPrintRedirectMessage = localized("warning_popup_print_redirect_message")
    static let warningPopupPrintRedirectProceedButton = localized("warning_popup_print_redirect_proceed_button")
    static let warningPopupPrintRedirectCancelButton = localized("warning_popup_print_redirect_cancel_button")

    // MARK: - Password validation rules
    static let passwordCharacterLimitRule = localized("signup_password_rule_character_limit")
    static let passwordCapitalizationAndNumberRule = localized("signup_password_rule_upper_lower_numeric")
    static let passwordSequentialRule = localized("signup_password_rule_sequential_characters")

    // MARK: - Photo/Video File Description
    static let photosVideosFileDescriptionTitle = localized("photo_video_detail_file_description")
}
