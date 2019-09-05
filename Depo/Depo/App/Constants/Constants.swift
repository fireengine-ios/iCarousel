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
        static let FAQ = "frequently_asked_questions"
        static let feedbackEmail = "destek-lifebox@turkcell.com.tr"
        static let termsOfUseGlobalDataPermLink1 = "global_data_permission_link"
        
        static let appName: String = {
            #if LIFEDRIVE
            return "LIFEDRIVE"
            #else
            return "LIFEBOX"
            #endif
            }()
        
        static let GAappName: String = {
            #if LIFEDRIVE
            return "Lifedrive"
            #else
            return "Lifebox"
            #endif
        }()
    }
    
    static let itroViewGoToRegisterButtonText = NSLocalizedString("Start using Lifebox now!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let introViewGoToLoginButtonText = NSLocalizedString("I have an account, let me log in", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let localFilesBeingProcessed = NSLocalizedString("localFilesBeingProcessed", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let registrationCellTitleEmail = NSLocalizedString("E-MAIL", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationCellTitleGSMNumber = NSLocalizedString("GSM Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationCellTitlePassword = NSLocalizedString("Password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationCellTitleReEnterPassword = NSLocalizedString("Re-Enter Password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationCellPlaceholderPhone = NSLocalizedString(" You have to fill in GSM number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationCellPlaceholderEmail = NSLocalizedString(" You have to fill in your mail", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let notCorrectEmail = NSLocalizedString("Please enter valid Email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let notValidEmail = NSLocalizedString("Email field is invalid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationCellPlaceholderPassword = NSLocalizedString(" You have to fill in a password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationCellPlaceholderReFillPassword = NSLocalizedString(" You have to fill in a password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationTitleText = NSLocalizedString("Register to lifebox and get a 5 GB of storage for free!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationNextButtonText = NSLocalizedString("Next", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationResendButtonText = NSLocalizedString("Resend", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let optInNavigarionTitle = NSLocalizedString("Verify Your Purchase", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let confirmPhoneOptInNavigarionTitle = NSLocalizedString("Confirm Your Phone", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let phoneVerificationMainTitleText = NSLocalizedString("Verify Your Phone Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let phoneVerificationInfoTitleText = NSLocalizedString("Enter the verification code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let phoneVerificationNonValidCodeErrorText = NSLocalizedString("Verification code is invalid. \n Please try again.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let phoneVerificationResendRequestFailedErrorText = NSLocalizedString("Request failed \n Please try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginScreenCredentialsError = NSLocalizedString("Login denied. Please check your credentials.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginScreenInvalidCaptchaError = NSLocalizedString("This text doesn't match. Please try again.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginScreenInvalidLoginError = NSLocalizedString("Please enter a valid login.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginScreenAuthWithTurkcellError = NSLocalizedString("Authentication with Turkcell Password is disabled for the account", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginScreenNeedSignUpError = NSLocalizedString("You don't have any lifebox account. Please signup before using the application", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationPasswordError = NSLocalizedString("Please set a password including nonconsecutive letters and numbers, minimum 6 maximum 16 characters.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let hourBlockLoginError = NSLocalizedString("You have performed too many attempts. Please try again later.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationMailError = NSLocalizedString("Please check the e-mail address.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationPasswordNotMatchError = NSLocalizedString("Password fields do not match.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginScreenServerError = NSLocalizedString("Temporary error occurred. Please try again later.", tableName: "OurLocalizable", bundle: .main, comment: "")
    
    static let registrationEmailPopupTitle = NSLocalizedString("E-mail Usage Information", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let registrationEmailPopupMessage = NSLocalizedString("You are finalizing the process with %@ e-mail address. We will be using this e-mail for password operations and site notifications", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let authificateCaptchaRequired = NSLocalizedString("You have successfully registered, please log in with your credentials", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let captchaRequired = NSLocalizedString("Please enter the text below", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFactorAuthenticationNewDeviceReason = NSLocalizedString("extra_auth_new_device_reason", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFactorAuthenticationAccountSettingReason = NSLocalizedString("extra_auth_account_setting_reason", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFactorAuthenticationNavigationTitle = NSLocalizedString("extra_auth_account_navigation_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFactorAuthenticationDescribeLabel = NSLocalizedString("extra_auth_account_describe_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFactorAuthenticationChooseTypeLabel = NSLocalizedString("extra_auth_account_choose_type", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFactorAuthenticationPhoneNumberCell = NSLocalizedString("extra_auth_account_phone_cell", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFactorAuthenticationEmailCell = NSLocalizedString("extra_auth_account_email_cell", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Registration Error Messages
    static let invalidMailErrorText = NSLocalizedString("Please enter a valid email address.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let invalidPhoneNumberText = NSLocalizedString("Please enter a valid GSM number.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let invalidPasswordText = NSLocalizedString("Please enter your password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let invalidPasswordMatchText = NSLocalizedString("Password fields do not match", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    // MARK: -
    static let termsAndUsesTitile = NSLocalizedString("Sign Up", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUsesApplyButtonText = NSLocalizedString("Accept  Terms", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseTextFormat = NSLocalizedString("<html><body text=\"#FFFFFF\" face=\"Bookman Old Style, Book Antiqua, Garamond\" size=\"5\">%@</body></html>", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseStartUsingText = NSLocalizedString("Get Started", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseCheckboxText = NSLocalizedString("I have read and accepted terms of use", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseEtkCheckbox = NSLocalizedString("terms_and_use_etk_checkbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseEtkCheckboxHeader = NSLocalizedString("terms_and_use_etk_checkbox_header", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseIntroductionCheckbox = NSLocalizedString("terms_and_use_introduction_checkbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseEtkLinkTurkcellAndGroupCompanies = NSLocalizedString("terms_and_use_etk_link_turkcell_and_group_companies", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privacyPolicyCondition = NSLocalizedString("privacy_policy_condition", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privacyPolicyHeadLine = NSLocalizedString("privacy_policy_head_line", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseEtkLinkCommercialEmailMessages = NSLocalizedString("terms_and_use_etk_link_commercial_email_messages", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseWelcomeText = NSLocalizedString("Welcome to Lifebox!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseCheckboxErrorText = NSLocalizedString("You need to confirm the User Agreement to continue.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let commercialEmailMessages = NSLocalizedString("commercial_email_messages", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseGlobalPermScreenTitle = NSLocalizedString("global_permission_screen_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseGlobalPermHeader = NSLocalizedString("global_permission_header", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseGlobalDataPermCheckbox = NSLocalizedString("global_data_permission_agreement", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseGlobalDataPermLinkSeeDetails = NSLocalizedString("global_data_permission_link", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let loginTitle = NSLocalizedString("Login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginTableTitle = NSLocalizedString("Register to lifebox and get a 5 GB of storage for free!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCantLoginButtonTitle = NSLocalizedString("I can't login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginRememberMyCredential = NSLocalizedString("Remember my credentials", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCellTitleEmail = NSLocalizedString("E-Mail or GSM Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCellTitlePassword = NSLocalizedString("Password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCellEmailPlaceholder = NSLocalizedString( "You have to fill in your mail or GSM Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCellPasswordPlaceholder = NSLocalizedString("You have to fill in a password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let autoSyncNavigationTitle = NSLocalizedString("Auto Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncFromSettingsTitle = NSLocalizedString("Lifebox can sync your files automatically.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncTitle = NSLocalizedString("Lifebox can sync your files automatically. Would you like to have this feature right now?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncCellPhotos = NSLocalizedString("Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncCellVideos = NSLocalizedString("Videos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncCellAutoSync = NSLocalizedString("Auto Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncStartUsingLifebox = NSLocalizedString("Let’s start using Lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncskipForNowButton = NSLocalizedString("Skip for now", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncAlertTitle = NSLocalizedString("Skip setting Auto-Sync?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncAlertText = NSLocalizedString("You’re skipping auto-sync setting turned off. You can activate this later in preferences.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncAlertYes = NSLocalizedString("Skip Auto-Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncAlertNo = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let welcome1Info = NSLocalizedString("Welcome1Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let welcome1SubInfo = NSLocalizedString("Welcome1SubInfo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let autoSyncSyncOverTitle = NSLocalizedString("Sync over data plan?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSyncOverMessage = NSLocalizedString("Syncing files using cellular data could incur data charges", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSyncOverOn = NSLocalizedString("Turn-on Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let registerTitle = NSLocalizedString("Sign Up", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let resetPasswordTitle = NSLocalizedString("reset_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let resetPasswordSubTitle = NSLocalizedString("you_can_easily_reset_your_password_by_clicking_the_password_reset_link_that_we_will_send_to_your_account_e-mail", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let resetPasswordInfo = NSLocalizedString("to_reset_your_accounts_password_we_will_send_a_password_reset_link_to_your_account_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let resetPasswordSendPassword = NSLocalizedString("send_link", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let resetPasswordEmailTitle = NSLocalizedString("your_account_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let resetPasswordEmailPlaceholder = NSLocalizedString("enter_your_account_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let resetPasswordCaptchaPlaceholder = NSLocalizedString("enter_the_text_shown_in_the_image", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let forgotPasswordSubTitle = NSLocalizedString("If you are already a Turkcell subscriber, you can obtain your password by sending free SMS containing SIFRE to 2222.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let forgotPasswordSentEmailAddres = NSLocalizedString("Your password is sent to your e-mail address", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let captchaPlaceholder = NSLocalizedString("Type the text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let checkPhoneAlertTitle = NSLocalizedString("Error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let contactConfirmDeleteTitle = NSLocalizedString("Are you sure you want to delete?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactConfirmDeleteText = NSLocalizedString("This contact will be deleted from your contacts.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterSecurityCode = NSLocalizedString("enter_security_code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterCodeToGetCodeOnPhone = NSLocalizedString("enter_code_get_code_on_phone", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let timeIsUpForCode = NSLocalizedString("time_is_up_for_code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let resendCode = NSLocalizedString("resend_code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let errorAlert = NSLocalizedString("Error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorAlerTitleBackupAlreadyExist = NSLocalizedString("Overwrite backup?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorAlertTextNoDuplicatedContacts = NSLocalizedString("You have no duplicated contacts!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorAlertTextBackupAlreadyExist = NSLocalizedString("You have already a backup. Do you want to overwrite the existing one?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorAlertNopeBtnBackupAlreadyExist = NSLocalizedString("Nope", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorAlertYesBtnBackupAlreadyExist = NSLocalizedString("Yes", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorErrorToGetAlbums = NSLocalizedString("Failed to get albums", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let forgotPasswordErrorNotRegisteredText = NSLocalizedString("This e-mail address is not registered. Please try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let forgotPasswordErrorCaptchaText = NSLocalizedString("This text doesn't match. Please try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let forgotPasswordEmptyEmailText = NSLocalizedString("Please check the e-mail address", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let forgotPasswordErrorEmailFormatText = NSLocalizedString("Please enter a valid email adress", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let forgotPasswordErrorCaptchaFormatText = NSLocalizedString("Please type the text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - DetailScreenError
    
    static let theFileIsNotSupported = NSLocalizedString("The file isn't supported", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let warning = NSLocalizedString("Warning", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Turkcell Security
    
    static let turkcellSecurityWaringPasscode = NSLocalizedString("TurkcellSecurityPasscodeWarningText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let turkcellSecurityWaringAutologin = NSLocalizedString("TurkcellSecurityAutologinText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeEneblingwWithActivatedTurkcellSecurity = NSLocalizedString("PasscodeActivationWhileTurkcellActivated", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    // MARK: - Search
    

    static let search = NSLocalizedString("Search", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let searchRecentSearchTitle = NSLocalizedString("Recent Searches", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let searchSuggestionsTitle = NSLocalizedString("Suggestions", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let searchNoFilesToCreateStoryError = NSLocalizedString("No files to create a story", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let noFilesFoundInSearch = NSLocalizedString("No results found for your query.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Sync Contacts
    
    static let backUpMyContacts = NSLocalizedString("Back Up My Contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let manageContacts = NSLocalizedString("Manage Contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let duplicatedContacts = NSLocalizedString("Duplicated Contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Authification Cells
    static let showPassword = NSLocalizedString("Show", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let hidePassword = NSLocalizedString("Hide", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: - button navigation name
    static let chooseTitle = NSLocalizedString("Choose", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let nextTitle = NSLocalizedString("Next", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let backTitle = NSLocalizedString("Back", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - home buttons title
    static let homeButtonAllFiles = NSLocalizedString("All Files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeButtonCreateStory = NSLocalizedString("Create a Story", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeButtonFavorites = NSLocalizedString("Favorites", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeButtonSyncContacts = NSLocalizedString("Sync Contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Home page subButtons Lables
    static let takePhoto = NSLocalizedString("Take Photo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let upload = NSLocalizedString("Upload", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStory = NSLocalizedString("Create a Story", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let newFolder = NSLocalizedString("New Folder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createAlbum = NSLocalizedString("Create album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadFromLifebox = NSLocalizedString("Upload from lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let importFromSpotifyBtn = NSLocalizedString("import_from_spotify_btn", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let importFromSpotifyTitle = NSLocalizedString("import_from_spotify_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: - Searchbar img name
    
    static let searchIcon = NSLocalizedString("searchIcon", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Navigation bar buttons titles
    
    static let cancelSelectionButtonTitle = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - More actions Collection view section titles
    
    static let viewTypeListTitle = NSLocalizedString("List", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let viewTypeGridTitle = NSLocalizedString("Grid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let sortTypeAlphabeticAZTitle = NSLocalizedString("Name (A-Z)", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortTypeAlphabeticZATitle = NSLocalizedString("Name (Z-A)", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortTimeOldNewTitle = NSLocalizedString("Oldest", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortTimeNewOldTitle = NSLocalizedString("Newest", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortTimeSizeTitle = NSLocalizedString("Size", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortTimeSizeLargestTitle = NSLocalizedString("Largest", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortTimeSizeSmallestTitle = NSLocalizedString("Smallest", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let sortHeaderAlphabetic = NSLocalizedString("Alphabetically Sorted", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortHeaderTime = NSLocalizedString("Sorted by Time", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortHeaderSize = NSLocalizedString("Sorted by Size", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let fileTypeVideoTitle = NSLocalizedString("Video", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileTypeDocsTitle = NSLocalizedString("Docs", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileTypeMusicTitle = NSLocalizedString("Music", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileTypePhotosTitle = NSLocalizedString("Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileTypeAlbumTitle = NSLocalizedString("Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileTypeFolderTitle = NSLocalizedString("Folder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let selectedTypeSelectedTitle = NSLocalizedString("Select", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectedTypeSelectedAllTitle = NSLocalizedString("Select All", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - TOPBAR
    
    static let topBarVideosFilter = NSLocalizedString("Videos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let topBarPhotosFilter = NSLocalizedString("Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    // MARK: - Camera alert
    static let cameraAccessAlertTitle = NSLocalizedString("Error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let cameraAccessAlertText = NSLocalizedString("Error occurred while accessing your photos.\nPlease check your settings.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let cameraAccessAlertGoToSettings = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let cameraAccessAlertNo = NSLocalizedString("No", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Sync out of space alert
    static let syncOutOfSpaceAlertTitle = NSLocalizedString("Caution!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let syncOutOfSpaceAlertText = NSLocalizedString("You have reached your lifebox memory limit.\nLet’s have a look for upgrade options!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let upgrade = NSLocalizedString("Upgrade", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let syncOutOfSpaceAlertCancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Home page contact bacup
    static let homePageContactBacupHeader = NSLocalizedString("Contact Backup", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homePageContactBacupOldTitle = NSLocalizedString("Your last contact update was %@ months ago!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homePageContactBacupOldSubTitle = NSLocalizedString("It has been %@ months since you last updated your contacts, update now to never loose any of your contacts.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homePageContactBacupEmptyTitle = NSLocalizedString("Your contact list looks empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homePageContactBacupEmptySubTitle = NSLocalizedString("You don’t have any contacts in your profile, backup your contacts now!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homePageContactBacupButton = NSLocalizedString("Backup", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homePageContactBacupLastUpate = NSLocalizedString("Last update:", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Home Storage card
    static let homeStorageCardCloudTitle = NSLocalizedString("Your lifebox storage is almost full!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeStorageCardEmptyTitle = NSLocalizedString("Your storage is empty!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeStorageCardLocalTitle = NSLocalizedString("Your storage is almost full!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeStorageCardCloudSubTitle = NSLocalizedString("You are using %f of your disk space! It’s a great time to expand your storage.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeStorageCardEmptySubTitle = NSLocalizedString("You seem to have no uploaded files. Start uploading your memories on Lifebox!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeStorageCardLocalSubTitle = NSLocalizedString("You are using %f of your device storage. It’s a great time to freeup space on your device.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeStorageCardCloudBottomButtonTitle = NSLocalizedString("Expand My Storage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeStorageCardEmptyBottomButtonTitle = NSLocalizedString("Upload Files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeStorageCardLocalBottomButtonTitle = NSLocalizedString("Free Up Space", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Home Collage card
    static let homeCollageCardTitle = NSLocalizedString("Collage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeCollageCardSubTitle = NSLocalizedString("We have created a collage from your photos!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeCollageCardButtonSaveCollage = NSLocalizedString("Save Collage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Home Animation card
    static let homeAnimationCardTitle = NSLocalizedString("Animation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeAnimationCardSubTitle = NSLocalizedString("We have created an animation from your photos!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeAnimationCardButtonSaveCollage = NSLocalizedString("Save Animation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Home Album card
    static let homeAlbumCardTitle = NSLocalizedString("Album Card", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeAlbumCardSubTitle = NSLocalizedString("We have created an album for you.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeAlbumCardBottomButtonSaveAlbum = NSLocalizedString("Save Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeAlbumCardBottomButtonViewAlbum = NSLocalizedString("View", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Home movie card
    static let homeMovieCardTitle = NSLocalizedString("Movie", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeMovieCardSubTitle = NSLocalizedString("Did you like this story that we created for you?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeMovieCardViewButton = NSLocalizedString("View", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeMovieCardSaveButton = NSLocalizedString("Save This Story", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Home Latest Uploads card
    static let homeLatestUploadsCardTitle = NSLocalizedString("Latest Uploads", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeLatestUploadsCardSubTitle = NSLocalizedString("Your latest uploads", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeLatestUploadsCardRecentActivitiesButton = NSLocalizedString("View Recent Activities", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeLatestUploadsCardAllPhotosButtn = NSLocalizedString("View All Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Home page like filter view
    static let homeLikeFilterHeader = NSLocalizedString("Filter Card", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeLikeFilterTitle = NSLocalizedString("Did you like this filter?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeLikeFilterSubTitle = NSLocalizedString("You can apply this filter and my more to your other picures as well", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeLikeFilterSavePhotoButton = NSLocalizedString("Save this photo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let homeLikeFilterViewPhoto = NSLocalizedString("View", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Popup
    static let ok = NSLocalizedString("OK", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: All files
    static let allFilesViewNoFilesTitleText = NSLocalizedString("You don’t have any files on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let allFilesViewNoFilesButtonText = NSLocalizedString("Start adding your files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Favorites
    static let favoritesViewNoFilesTitleText = NSLocalizedString("You don’t have any favorited files on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let favoritesViewNoFilesButtonText = NSLocalizedString("Start adding your files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: PhotosVideosView
    static let photosVideosViewNoPhotoTitleText = NSLocalizedString("You don’t have anything on your photo roll.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let photosVideosViewNoPhotoButtonText = NSLocalizedString("Start adding your photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let photosVideosViewHaveNoPermissionsAllertText = NSLocalizedString("Enable photo permissions in settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let photosVideosViewMissingDatesHeaderText = NSLocalizedString("Missing Dates", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let showOnlySyncedItemsText = NSLocalizedString("Show only synced items", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: AudioView
    static let audioViewNoAudioTitleText = NSLocalizedString("You don’t have any music on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: DocumentsView
    static let documentsViewNoDocumenetsTitleText = NSLocalizedString("You don’t have any documents on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Folder
    static let folderEmptyText = NSLocalizedString("Folder is Empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let folderItemsText = NSLocalizedString("Folder Items", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: settings
    static let backPrintTitle = NSLocalizedString("Back to Lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: settings
    static let settingsViewCellLoginSettings = NSLocalizedString("Login Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellTurkcellPassword = NSLocalizedString("Turkcell Password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellTurkcellAutoLogin = NSLocalizedString("Auto-login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellTwoFactorAuth = NSLocalizedString("2_factor_auth", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")


    static let settingsViewUploadPhotoLabel = NSLocalizedString("Upload Photo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewLeaveFeedback = NSLocalizedString("Leave feedback", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let settingsViewCellBeckup = NSLocalizedString("Back-up my contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellContactsSync = NSLocalizedString("Contacts Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellImportPhotos = NSLocalizedString("Import Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellConnectedAccounts = NSLocalizedString("connected_accounts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellAutoUpload = NSLocalizedString("Auto Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellFaceAndImageGrouping = NSLocalizedString("Face & Image Grouping", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellActivityTimline = NSLocalizedString("My Activity Timeline", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellUsageInfo = NSLocalizedString("Usage Info and Packages", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellPasscode = NSLocalizedString("Lifebox %@ and Passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellHelp = NSLocalizedString("Help & Support", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellPrivacyAndTerms = NSLocalizedString("terms_and_privacy_policy", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellLogout = NSLocalizedString("Logout", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsViewCellPermissions = NSLocalizedString("Permissions", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let settingsViewLogoutCheckMessage = NSLocalizedString("Are you sure you want to exit the application?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    // MARK: FAQ
    
    static let faqViewTitle = NSLocalizedString("Help and Support", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Import photos
    static let importPhotos = NSLocalizedString("Import Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let importFromDB = NSLocalizedString("Import From Dropbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let importFromFB = NSLocalizedString("Import From Facebook", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let importFromSpotify = NSLocalizedString("import_from_spotify", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let importFromInstagram = NSLocalizedString("Import From Instagram", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let importFromCropy = NSLocalizedString("Import From Cropy", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let importFiles = NSLocalizedString("Importing files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let dropboxAuthorisationError = NSLocalizedString("Dropbox authorisation error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let dropboxLastUpdatedFile = NSLocalizedString("dropboxLastUpdatedFile", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let dropboxLastUpdatedFiles = NSLocalizedString("dropboxLastUpdatedFiles", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Terms of Use and Privacy Policy
     static let termsOfUseCell = NSLocalizedString("terms_of_use", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
     static let privacyPolicyCell = NSLocalizedString("privacy_policy", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Face Image
    static let faceImageGrouping = NSLocalizedString("Face image grouping", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceAndImageGrouping = NSLocalizedString("Face & Image Grouping", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageDone = NSLocalizedString("Done", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageAddName = NSLocalizedString("+Add a Name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageSearchAddName = NSLocalizedString("+Add Name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageCheckTheSamePerson = NSLocalizedString("Are these the same person?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageWillMergedTogether = NSLocalizedString("They will be merged together", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageNope = NSLocalizedString("Nope", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageYes = NSLocalizedString("Yes", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageThisPerson = NSLocalizedString("this person", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImagePhotos = NSLocalizedString("Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageNoPhotos = NSLocalizedString("We couldn't find anybody on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImagePlacesNoPhotos = NSLocalizedString("We couldn’t find any place on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageThingsNoPhotos = NSLocalizedString("We couldn’t find anything on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageNoPhotosButton = NSLocalizedString("Start adding your photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageWaitAlbum = NSLocalizedString("Grouping of your photos will take some time. Please wait and then check the albums.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: userProfile
    static let userProfileTitle = NSLocalizedString("Your Profile", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileNameAndSurNameSubTitle = NSLocalizedString("Name and Surname", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileName = NSLocalizedString("name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileSurname = NSLocalizedString("surname", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileEmailSubTitle = NSLocalizedString("E-Mail", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileGSMNumberSubTitle = NSLocalizedString("GSM Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileEditButton = NSLocalizedString("Edit", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileDoneButton = NSLocalizedString("Done", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let emptyEmail = NSLocalizedString("E-mail is empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let emptyEmailTitle = NSLocalizedString("E-Mail Entry", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileChangePassword = NSLocalizedString("change password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileBirthday = NSLocalizedString("birthday", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfilePassword = NSLocalizedString("Password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileDayPlaceholder = NSLocalizedString("user_profile_day_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileMonthPlaceholder = NSLocalizedString("user_profile_month_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileYearPlaceholder = NSLocalizedString("user_profile_year_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileTurkcellGSMAlert = NSLocalizedString("user_profile_turkcell_gsm_alert", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: fileInfo
    static let fileInfoFileNameTitle = NSLocalizedString("File Name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoFileInfoTitle = NSLocalizedString("File Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoFolderNameTitle = NSLocalizedString("Folder Name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoFolderInfoTitle = NSLocalizedString("Folder Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoAlbumSizeTitle = NSLocalizedString("Items", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoFileSizeTitle = NSLocalizedString("File size", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoDurationTitle = NSLocalizedString("Duration", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoUploadDateTitle = NSLocalizedString("Upload date", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoCreationDateTitle = NSLocalizedString("Creation date", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoTakenDateTitle = NSLocalizedString("Taken date", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoAlbumTitle = NSLocalizedString("Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoArtistTitle = NSLocalizedString("Artist", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoTitleTitle = NSLocalizedString("Title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoAlbumNameTitle = NSLocalizedString("Album Name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoAlbumInfoTitle = NSLocalizedString("Album Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fileInfoSave = NSLocalizedString("Save", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    //MARK: Permissions in Settings
    static let etkPermissionTitleLabel = NSLocalizedString("etk_permission_title_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let etkPermissionDescription = NSLocalizedString("etk_permission_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let globalPermissionTitleLabel = NSLocalizedString("global_permission_title_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let globalPermissionDescriptionLabel = NSLocalizedString("global_permission_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let informativeDescription = NSLocalizedString("informative_description_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: settings User info view
    static let settingsUserInfoViewUpgradeButtonText = NSLocalizedString("UPGRADE", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: BackUp contacts view
    static let settingsBackupContactsViewNewContactsText = NSLocalizedString("New Contact", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackupContactsViewDuplicatesText = NSLocalizedString("Updated", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackupContactsViewRemovedText = NSLocalizedString("Removed", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackupedText = NSLocalizedString("Backed up %d Contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackupStatusText = NSLocalizedString("You have %d numbers on your contacts backup.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsRestoredText = NSLocalizedString("Restored %d Contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpingText = NSLocalizedString("%d%% Backed up…", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsDeletingText = NSLocalizedString("%d Duplicated Contacts Deleted", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsDeleteDuplicatedAlertTitle = NSLocalizedString("Are you sure you want to delete?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsDeleteDuplicatedAlertText = NSLocalizedString("This duplicated contacts will be deleted from your contacts.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsRestoringText = NSLocalizedString("%d%% Restored…", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsAnalyzingText = NSLocalizedString("%d%% Analyzed…", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpNeverDidIt = NSLocalizedString("You can backup your contacts to lifebox. By\ndoing that you can easly access your contact\nlist from any device and anywhere.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpNewer = NSLocalizedString("You never backed up your contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpLessAMinute = NSLocalizedString("Your last back up was a few seconds ago.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpLessADay = NSLocalizedString("Your last backup was on %@", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpButtonTitle = NSLocalizedString("Back-Up", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpRestoreTitle = NSLocalizedString("Restore", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpCancelDeletingTitle = NSLocalizedString("Cancel Deleting", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpCancelAnalyzingTitle = NSLocalizedString("Cancel Analyzing", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpDeleteDuplicatedButton = NSLocalizedString("Delete Duplicated", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpDeleteContactButton = NSLocalizedString("Delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpNumberOfDuplicated = NSLocalizedString("%d same contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpTotalNumberOfDuplicatedContacts = NSLocalizedString("There are %d duplicated contacts.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpKeepButton = NSLocalizedString("Keep", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsBackUpDeleteAllButton = NSLocalizedString("Delete all", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsContactsPermissionDeniedMessage = NSLocalizedString("You need to enable access to Contacts to continue", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSettingsSelect = NSLocalizedString("Select", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSettingsOptionNever = NSLocalizedString("Never", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSettingsOptionWiFi = NSLocalizedString("Wi-Fi", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSettingsOptionWiFiAndCellular = NSLocalizedString("Wi-Fi and Cellular", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSettingsOptionDaily = NSLocalizedString("Daily", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSettingsOptionWeekly = NSLocalizedString("Weekly", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoSyncSettingsOptionMonthly = NSLocalizedString("Monthly", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let isPeriodicContactsSyncEnabledKey = NSLocalizedString("isPeriodicContactsSyncEnabledKey", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Create story Name
    static let createStorySelectAudioButton = NSLocalizedString("Continue", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Create story Photos
    static let createStoryPhotosTitle = NSLocalizedString("Create a story", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPhotosCancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPhotosContinue = NSLocalizedString("Continue", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPhotosHeaderTitle = NSLocalizedString("Please Choose 20 files at most", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPhotosMaxCountAllert = NSLocalizedString("Please choose %d files at most", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryNoSelectedPhotosError = NSLocalizedString("Sorry, but story photos should not be empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryNotCreated = NSLocalizedString("Story not created", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let failWhileAddingToAlbum = NSLocalizedString("Fail while adding to album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Create story Audio
    static let createStoryNoSelectedAudioError = NSLocalizedString("Sorry, but story audio should not be empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryAudioSelected = NSLocalizedString("Add Music", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryAudioMusics = NSLocalizedString("Musics", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryAudioYourUploads = NSLocalizedString("Your Uploads", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryAudioSelectItem = NSLocalizedString("Select", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryAudioSelectedItem = NSLocalizedString("Selected", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Create story Photo Order
    static let createStoryPhotosOrderNextButton = NSLocalizedString("Create", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStorySave = NSLocalizedString("Save", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPhotosOrderTitle = NSLocalizedString("You can change the sequence ", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Stories View
    static let storiesViewNoStoriesTitleText = NSLocalizedString("You don’t have any stories  on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let storiesViewNoStoriesButtonText = NSLocalizedString("Start creating stories", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Upload
    static let uploadFilesNextButton = NSLocalizedString("Upload", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadFilesNothingUploadError = NSLocalizedString("Nothing to upload", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: UploadFromLifeBox
    static let uploadFromLifeBoxTitle = NSLocalizedString("Upload from lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadFromLifeBoxNextButton = NSLocalizedString("Next", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadFromLifeBoxNoSelectedPhotosError = NSLocalizedString("Sorry, but photos not selected", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Select Folder
    static let selectFolderNextButton = NSLocalizedString("Select", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectFolderCancelButton = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectFolderBackButton = NSLocalizedString("Back", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectFolderTitle = NSLocalizedString("Choose a destination folder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - TabBar tab lables
    static let music = NSLocalizedString("Music", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let documents = NSLocalizedString("Documents", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarDeleteLabel = NSLocalizedString("Delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarRemoveAlbumLabel = NSLocalizedString("Remove Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarRemoveLabel = NSLocalizedString("Remove From Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarAddToAlbumLabel = NSLocalizedString("Add To Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabAlbumCoverAlbumLabel = NSLocalizedString("Make album cover", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarEditeLabel = NSLocalizedString("Edit", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarPrintLabel = NSLocalizedString("Print", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarDownloadLabel = NSLocalizedString("Download", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarSyncLabel = NSLocalizedString("Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarMoveLabel = NSLocalizedString("Move", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarShareLabel = NSLocalizedString("Share", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarInfoLabel = NSLocalizedString("Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Select Name
    static let selectNameTitleFolder = NSLocalizedString("New Folder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNameTitleAlbum = NSLocalizedString("New Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNameTitlePlayList = NSLocalizedString("New PlayList", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNameNextButtonFolder = NSLocalizedString("Create", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNameNextButtonAlbum = NSLocalizedString("Create", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNameNextButtonPlayList = NSLocalizedString("Create", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNamePlaceholderFolder = NSLocalizedString("Folder Name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNamePlaceholderAlbum = NSLocalizedString("Album Name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNamePlaceholderPlayList = NSLocalizedString("Play List Name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNameEmptyNameFolder = NSLocalizedString("Sorry, but folder name should not be empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNameEmptyNameAlbum = NSLocalizedString("Sorry, but album name should not be empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let selectNameEmptyNamePlayList = NSLocalizedString("Sorry, but play list name should not be empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Albums
    static let albumsTitle = NSLocalizedString("Albums", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadPhotos = NSLocalizedString("Upload Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let removeReadOnlyAlbumError = NSLocalizedString("Video album is automatically created, therefore cannot be deleted", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadVideoToReadOnlyAlbumError = NSLocalizedString("You cannot upload any video to auto generated video album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let haveNoAnyFiles = NSLocalizedString("You have no any files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let albumEmptyText = NSLocalizedString("Album is Empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let shareEmptyAlbumError = NSLocalizedString("You can not share empty album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Albums view
    static let albumsViewNoAlbumsTitleText = NSLocalizedString("You don’t have any albums on your Lifebox yet.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let albumsViewNoAlbumsButtonText = NSLocalizedString("Start creating albums", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: My stream
    static let myStreamAlbumsTitle = NSLocalizedString("Albums", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myStreamStoriesTitle = NSLocalizedString("My Stories", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myStreamPeopleTitle = NSLocalizedString("People", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myStreamThingsTitle = NSLocalizedString("Things", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myStreamPlacesTitle = NSLocalizedString("Places", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myStreamInstaPickTitle = NSLocalizedString("InstaPick", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Feedback View
    static let feedbackMailTextFormat = NSLocalizedString("Please do not delete the information below. The information will be used to address the problem.\n\nApplication Version: %@\nMsisdn: %@\nCarrier: %@\nDevice:%@\nDevice OS: %@\nLanguage: %@\nLanguage preference: %@\nNetwork Status: %@\nTotal Storage: %lld\nUsed Storage: %lld\nPackages: %@\n", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormEmailBody = NSLocalizedString("support_form_email_body", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let feedbackViewTitle = NSLocalizedString("Thanks for leaving a comment!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackViewSubTitle = NSLocalizedString("Feedback Form", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackViewSuggestion = NSLocalizedString("Suggestion", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackViewComplaint = NSLocalizedString("Complaint", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackViewSubjectFormat = NSLocalizedString("%@ about Lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackViewLanguageLabel = NSLocalizedString("You need to specify your language preference so that we can serve you better.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackViewSendButton = NSLocalizedString("Send", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackViewSelect = NSLocalizedString("Please select a language option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackEmailError = NSLocalizedString("Please configurate email client", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackErrorTextError = NSLocalizedString("Please type your message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feedbackErrorLanguageError = NSLocalizedString("You need to specify your language preference so that we can serve you better.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: PopUp
    static let popUpProgress = NSLocalizedString("(%ld of %ld)", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let popUpSyncing = NSLocalizedString("Syncing files over", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let popUpUploading = NSLocalizedString("Uploading files over", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let popUpDownload = NSLocalizedString("Downloading files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let popUpDeleteComplete = NSLocalizedString("Deleting is complete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let popUpDownloadComplete = NSLocalizedString("Download is complete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeAppSpacePopUpTextNormal = NSLocalizedString("There are some duplicated items both in your device and lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeAppSpacePopUpButtonTitle = NSLocalizedString("Free up space", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let networkTypeWiFi = NSLocalizedString("Wi-Fi", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobileData = NSLocalizedString("Mobile Data", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoUploaOffPopUpTitleText = NSLocalizedString("Auto Upload is off.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoUploaOffPopUpSubTitleText = NSLocalizedString("Photos and videos waiting to be synced", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoUploaOffSettings = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let waitingForWiFiPopUpTitle = NSLocalizedString("Waiting for Wi-Fi connection to auto-sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let waitingForWiFiPopUpSettingsButton = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let prepareToAutoSunc = NSLocalizedString("Auto Sync Preparation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let prepareQuickScroll = NSLocalizedString("Quick Scroll Preparation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - ActionSheet
    static let actionSheetDeleteDeviceOriginal = NSLocalizedString("Delete Device Original", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetCancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    
    static let actionSheetShare = NSLocalizedString("Share", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetInfo = NSLocalizedString("Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetEdit = NSLocalizedString("Edit", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetDelete = NSLocalizedString("Delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetMove = NSLocalizedString("Move", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetDownload = NSLocalizedString("Download", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetShareSmallSize = NSLocalizedString("Small Size", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetShareOriginalSize = NSLocalizedString("Original Size", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetShareShareViaLink = NSLocalizedString("Share Via Link", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetShareCancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetCreateStory = NSLocalizedString("Create a Story", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetCopy = NSLocalizedString("Copy", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetAddToFavorites = NSLocalizedString("Add to Favorites", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetRemove = NSLocalizedString("Remove", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetRemoveFavorites = NSLocalizedString("Remove from Favorites", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetAddToAlbum = NSLocalizedString("Add to album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetBackUp = NSLocalizedString("Back Up", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetRemoveFromAlbum = NSLocalizedString("Remove from album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetTakeAPhoto = NSLocalizedString("Take Photo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetChooseFromLib = NSLocalizedString("Choose From Library", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetChangeCover = NSLocalizedString("Change cover photo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetPhotos = NSLocalizedString("Photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetiCloudDrive = NSLocalizedString("iCloud Drive", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetLifeBox = NSLocalizedString("lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetMore = NSLocalizedString("More", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetSelect = NSLocalizedString("Select", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetSelectAll = NSLocalizedString("Select All", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetDeSelectAll = NSLocalizedString("Deselect All", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetRename = NSLocalizedString("Rename", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetDocumentDetails = NSLocalizedString("Document Details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetAddToPlaylist = NSLocalizedString("Share Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetMusicDetails = NSLocalizedString("Music Dteails", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetMakeAlbumCover = NSLocalizedString("Make album covers", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetAlbumDetails = NSLocalizedString("Album Details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetDownloadToCameraRoll = NSLocalizedString("Download to Camera Roll", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Free Up Space
    static let freeAppSpaceTitle = NSLocalizedString("There are %d duplicated photos both in your device and lifebox. Clear some space by selecting the photos that you want to delete.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeAppSpaceAlertSuccesTitle = NSLocalizedString("You have free space for %d more items.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let save = NSLocalizedString("Save", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let cropyMessage = NSLocalizedString("This edited photo will be saved as a new photo in your device gallery", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let cancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: -
    
    static let albumLikeSlidertitle = NSLocalizedString("My Stream", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let albumLikeSliderWithPerson = NSLocalizedString("Albums with %@", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    // MARK: - ActivityTimeline
    static let activityTimelineFiles = NSLocalizedString("file(s)", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let activityTimelineTitle = NSLocalizedString("My Activity Timeline", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - PullToRefresh
    static let pullToRefreshSuccess = NSLocalizedString("Success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - usageInfo
    static let myUsageStorage = NSLocalizedString("my_usage_storage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usageInfoPhotos = NSLocalizedString("%ld photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usageInfoVideos = NSLocalizedString("%ld videos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usageInfoSongs = NSLocalizedString("%ld songs", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usageInfoDocuments = NSLocalizedString("%ld documents", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usageInfoQuotaInfo = NSLocalizedString("Quota info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usageInfoDocs = NSLocalizedString("%ld docs", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usedAndLeftSpace = NSLocalizedString("used_and_left_space", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let leftSpace = NSLocalizedString("left_space", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageSpaceDetails = NSLocalizedString("package_space_details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let renewDate = NSLocalizedString("package_renew_date", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usagePercentage = NSLocalizedString("percentage_used", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let usagePercentageTwoLines = NSLocalizedString("percentage_used_two_lines", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let restorePurchasesButton = NSLocalizedString("restore_purchases", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let restorePurchasesInfo = NSLocalizedString("restore_purchases_info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let attributedRestoreWord = NSLocalizedString("attributed_restore_word", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    // MARK: - offers
    static let descriptionLabelText = NSLocalizedString("*Average figure. Total number of documents depends on the size of each document.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let offersActivateUkranian = NSLocalizedString("Special prices for lifecell subscribers! To activate lifebox 50GB for 24,99UAH/30 days send SMS with the text 50VKL, for lifebox 500GB for 52,99UAH/30days send SMS with the text 500VKL to the number 8080", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersActivateCyprus = NSLocalizedString("Platinum and lifecell customers can send LIFE, other customers can send LIFEBOX 50GB for lifebox 50GB package, LIFEBOX 500GB for lifebox 500GB package and LIFEBOX 2.5TB for lifebox 2.5TB package to 3030 to start their memberships", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let offersCancelUkranian = NSLocalizedString("To deactivate lifebox 50GB please send SMS with the text 50VYKL, for lifebox 500GB please send SMS with the text 500VYKL to the number 8080", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersCancelCyprus = NSLocalizedString("Platinum and lifecell customers can send LIFE CANCEL, other customers can send LIFEBOX CANCEL to 3030 to cancel their memberships", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersCancelMoldcell = NSLocalizedString("Hm, can’t believe you are doing this! When you decide to reactivate it, we’ll be here for you :) If you insist, sent “STOP” to 2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersCancelTurkcell = NSLocalizedString("Please text \"Iptal LIFEBOX %@\" to 2222 to cancel your subscription", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersCancelLife = NSLocalizedString("offersCancelLife", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let offersInfo = NSLocalizedString("Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersOk = NSLocalizedString("OK", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersSettings = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersPrice = NSLocalizedString("%.2f %@ / month", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersLocalizedPrice = NSLocalizedString("%@ / month", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let offersAllCancel = NSLocalizedString("You can open settings and cancel subscption.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let subscriptionGoogleText = NSLocalizedString("Google Play Store", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let subscriptionAppleText = NSLocalizedString("AppStore", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let validatePurchaseSuccessText = NSLocalizedString("Successful purchase.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let validatePurchaseInvalidText = NSLocalizedString("Invalid purchase. AppStore does not verify purchase for the given parameters.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let validatePurchaseTemporaryErrorText = NSLocalizedString("A temporary error has occurred due to technical reasons.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let validatePurchaseAlreadySubscribedText = NSLocalizedString("Subscription related with this purchase is already activated for another lifebox user. Note that using different lifebox accounts with the same Apple or Google ID might result with this situation.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let validatePurchaseRestoredText = NSLocalizedString("Shows that a response operation is done for the given receipt.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - OTP
    static let otpResendButton = NSLocalizedString("Resend", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let otpTitleText = NSLocalizedString("Enter the verification code\nsent to your number %@", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Errors
    static let errorEmptyEmail = NSLocalizedString("Indicates that the e-mail parameter is sent blank.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorEmptyPassword = NSLocalizedString("Indicates that the password parameter is sent blank.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorEmptyPhone = NSLocalizedString("Specifies that the phone number parameter is sent  blank.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorInvalidEmail = NSLocalizedString("E-mail address is in an invalid format.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorExistEmail = NSLocalizedString("This e-mail address is already registered. Please enter another e-mail address.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorVerifyEmail = NSLocalizedString("Indicates that a user with the given e-mail address already exists and login will be  allowed after e-mail address validation.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorInvalidPhone = NSLocalizedString("Phone number is in an invalid format.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorExistPhone = NSLocalizedString("This GSM Number is already registered. Please enter another GSM Number.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorInvalidPassword = NSLocalizedString("Please set a password including nonconsecutive letters and numbers, minimum 6 maximum 16 characters.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorInvalidPasswordSame = NSLocalizedString("It is not allowed that the password consists of all the same characters.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorInvalidPasswordLengthExceeded = NSLocalizedString("The password consists of more number of characters than is allowed. The length allowed is provided in the value field of the response.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorInvalidPasswordBelowLimit = NSLocalizedString("The password consists of less number of characters than is allowed. The length allowed is provided in the value field of the response.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let TOO_MANY_REQUESTS = NSLocalizedString("Too many verification code requested for this msisdn. Please try again later", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let EMAIL_IS_INVALID = NSLocalizedString("E-mail field is invalid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let EMAIL_IS_ALREADY_EXIST = NSLocalizedString("This e-mail address is already registered. Please enter another e-mail address.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let errorUnknown = NSLocalizedString("Unknown error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorServer = NSLocalizedString("Server error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorBadConnection = NSLocalizedString("Bad internet connection", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let errorFileSystemAccessDenied = NSLocalizedString("Can't get access to file system", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorNothingToDownload = NSLocalizedString("Nothing to download", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorSameDestinationFolder = NSLocalizedString("Destination folder can not be the same folder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorWorkWillIntroduced = NSLocalizedString("work_will_introduced", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let errorServerUnderMaintenance = NSLocalizedString("server_under_maintenance", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let canceledOperationTextError = NSLocalizedString("cancelled", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let networkConnectionLostTextError = NSLocalizedString("The network connection was lost.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let commonServiceError = NSLocalizedString("ServiceError", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let ACCOUNT_NOT_FOUND = NSLocalizedString("Account cannot be found", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let INVALID_PROMOCODE = NSLocalizedString("This package activation code is invalid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let PROMO_CODE_HAS_BEEN_ALREADY_ACTIVATED = NSLocalizedString("This package activation code has been used before, please try different code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let PROMO_CODE_HAS_BEEN_EXPIRED = NSLocalizedString("This package activation code has expired", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let PROMO_CODE_IS_NOT_CREATED_FOR_THIS_ACCOUNT = NSLocalizedString("This package activation code is defined for different user", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let THERE_IS_AN_ACTIVE_JOB_RUNNING = NSLocalizedString("Package activation process is in progress", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let CURRENT_JOB_IS_FINISHED_OR_CANCELLED = NSLocalizedString("This package activation code has been used before, please try different code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let PROMO_IS_NOT_ACTIVATED = NSLocalizedString("This package activation code has not been activated  yet", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let PROMO_HAS_NOT_STARTED = NSLocalizedString("This package activation code definition time has not yet begun", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let PROMO_NOT_ALLOWED_FOR_MULTIPLE_USE = NSLocalizedString("You will not be able to use the this package activation code from this campaign for the second time because you have already benefited from it", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let PROMO_IS_INACTIVE = NSLocalizedString("The package activation code is not active", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let passcode = NSLocalizedString("Passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeSettingsSetTitle = NSLocalizedString("Set a Passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeSettingsChangeTitle = NSLocalizedString("Change Passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeLifebox = NSLocalizedString("lifebox Passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeEnter = NSLocalizedString("Please enter your lifebox passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeEnterOld = NSLocalizedString("Please enter your lifebox passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeEnterNew = NSLocalizedString("Set a Passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeConfirm = NSLocalizedString("Please repeate your new lifebox passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeChanged = NSLocalizedString("Passcode is changed successfully", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeSet = NSLocalizedString("You successfully set your passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeDontMatch = NSLocalizedString("Passcodes don't match, please try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeSetTitle = NSLocalizedString("Set a Passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeBiometricsDefault = NSLocalizedString("To enter passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeBiometricsError = NSLocalizedString("Please activate %@ from your device settings to use this feature", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeEnable = NSLocalizedString("Enable", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeFaceID = NSLocalizedString("Face ID", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeTouchID = NSLocalizedString("Touch ID", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passcodeNumberOfTries = NSLocalizedString("Invalid passcode. %@ attempts left. Please try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorConnectedToNetwork = NSLocalizedString("Please check your internet connection is active and Mobile Data is ON.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorManyContactsToBackUp = NSLocalizedString("Up to 5000 contacts can be backed up.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let apply = NSLocalizedString("Apply", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let success = NSLocalizedString("Success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let promocodeTitle = NSLocalizedString("Lifebox campaign", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let promocodePlaceholder = NSLocalizedString("Enter your promo code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let promocodeError = NSLocalizedString("This package activation code is invalid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let promocodeEmpty = NSLocalizedString("Please enter your promo code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let promocodeSuccess = NSLocalizedString("Your package is successfully defined", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let promocodeInvalid = NSLocalizedString("Verification code is invalid.\nPlease try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let promocodeBlocked = NSLocalizedString("Verification code is blocked.\nPlease request a new code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Packages
    
    static let packagesIHave = NSLocalizedString("packages_i_have", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let accountDetails = NSLocalizedString("account_details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myProfile = NSLocalizedString("my_profile", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let accountType = NSLocalizedString("account_type", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let standardPlus = NSLocalizedString("standard_plus", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let standard = NSLocalizedString("standard", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let premium = NSLocalizedString("premium", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let packages = NSLocalizedString("Packages", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let purchase = NSLocalizedString("Purchase", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let packagesPolicyHeader = NSLocalizedString("PackagesPolicyHeader", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagesPolicyText = NSLocalizedString("PackagesPolicyText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseLinkText = NSLocalizedString("TermsOfUseLinkText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let deleteFilesText = NSLocalizedString("Deleting these files will remove them from cloud. You won't be able to access them once deleted", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteAlbums = NSLocalizedString("Deleting this album will remove the files from lifebox. You won't be able to access them once deleted. Are you sure you want to delete?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let removeAlbums = NSLocalizedString("Deleting this album will not remove the files from lifebox. You can access these files from Photos tab. Are you sure you want to delete?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let removeFromAlbum = NSLocalizedString("This file will be removed only from your album. You can access this file from Photos tab", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let locationServiceDisable = NSLocalizedString("Location services are disabled in your device settings. To use background sync feature of lifebox, you need to enable location services under \"Settings - Privacy - Location Services\" menu.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let loginEnterGSM = NSLocalizedString("Please enter your GSM number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginAddGSM = NSLocalizedString("Add GSM Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginGSMNumber = NSLocalizedString("GSM number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let syncFourGbVideo = NSLocalizedString("The videos larger than 4GB can not be uploaded to lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let syncNotEnoughMemory = NSLocalizedString("You have not enough memory in your device", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let cancelPurchase = NSLocalizedString("The purchase was canceled", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let inProgressPurchase = NSLocalizedString("The purchase in progress", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let renewalDate = NSLocalizedString("Renewal Date: %@", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let subscriptionEndDate = NSLocalizedString("Expiration Date: %@", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let cancelButtonTitle = NSLocalizedString("package_cancel_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageSectionTitle = NSLocalizedString("package_section_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let availableHeadNameTitle = NSLocalizedString("available_head_name_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let packagePeriodDay = NSLocalizedString("package_period_day", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagePeriodWeek = NSLocalizedString("package_period_week", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagePeriodMonth = NSLocalizedString("package_period_month", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagePeriodYear = NSLocalizedString("package_period_year", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let packageApplePrice = NSLocalizedString("package_apple_price", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageApplePrice = NSLocalizedString("face_image_apple_price", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let packageGoogleCancelText = NSLocalizedString("package_google_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageFreeOfChargeCancelText = NSLocalizedString("package_free_of_charge_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageLifeCellCancelText = NSLocalizedString("package_lifecell_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagePromoCancelText = NSLocalizedString("package_promo_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagePaycellAllAccessCancelText = NSLocalizedString("package_paycell_all_access_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagePaycellSLCMCancelText = NSLocalizedString("package_paycell_slcm_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageAlbanianCancelText = NSLocalizedString("package_albanian_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageFWICancelText = NSLocalizedString("package_FWI_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageJamaicaCancelText = NSLocalizedString("package_jamaica_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageSLCMPaycellCancelText = NSLocalizedString("package_slcm_paycell_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packageDefaultCancelText = NSLocalizedString("package_default_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let turkcellPurchasePopupTitle = NSLocalizedString("turkcell_purchase_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Navigation bar img names
    
    static let moreBtnImgName = "more"
    static let cogBtnImgName = "cog"
    static let searchBtnImgName = "search"
    static let deleteBtnImgName = "DeleteShareButton"
    
    // MARK: - Navigation bar title names
    
    static let showHideBtnTitleName = NSLocalizedString("Show & Hide", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    // MARK: - Accessibility
    static let accessibilityPlus = NSLocalizedString("Plus", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityClose = NSLocalizedString("Close", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilitySettings = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityMore = NSLocalizedString("More", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilitySearch = NSLocalizedString("Search", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityDelete = NSLocalizedString("Delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityFavorite = NSLocalizedString("Favorite", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilitySelected = NSLocalizedString("Selected", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityNotSelected = NSLocalizedString("Not selected", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityshowHide = NSLocalizedString("Show and Hide", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityDone = NSLocalizedString("Done", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityHome = NSLocalizedString("Home", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityPhotosVideos = NSLocalizedString("Photos and Videos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityMusic = NSLocalizedString("Music", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityDocuments = NSLocalizedString("Documents", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    
    static let photos = NSLocalizedString("photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let approve = NSLocalizedString("Approve", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infomationEmptyEmail = NSLocalizedString("infomationEmptyEmail", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    //Periodic contacts sync
    static let periodicContactsSync = NSLocalizedString("Contacts Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Quota PopUps
    static let fullQuotaSmallPopUpTitle = NSLocalizedString("LifeboxSmallPopUpTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaSmallPopUpSubTitle = NSLocalizedString("LifeboxSmallPopUpSubTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaSmallPopUpCheckBoxText = NSLocalizedString("LifeboxSmallPopUpCheckBoxTex", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaSmallPopUpFistButtonTitle = NSLocalizedString("LifeboxSmallPopUpFirstButtonText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaSmallPopUpSecondButtonTitle = NSLocalizedString("LifeboxSmallPopUpSecondButtonText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let lifeboxLargePopUpTitle100 = NSLocalizedString("LifeboxLargePopUpTitle100", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpTitle90 = NSLocalizedString("LifeboxLargePopUpTitle90", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpTitle80 = NSLocalizedString("LifeboxLargePopUpTitle80", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpSubTitle = NSLocalizedString("LifeboxLargePopUpSubTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpExpandButtonTitle = NSLocalizedString("LifeboxLargePopUpExpandButtonTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpSkipButtonTitle = NSLocalizedString("LifeboxLargePopUpSkipButtonTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let periodContactSyncFromSettingsTitle = NSLocalizedString("Lifebox can sync your contacts automatically.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorLogin = NSLocalizedString("error_login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploading = NSLocalizedString("uploading", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    //MARK: - Spotlight
    
    static let spotlightHomePageIconText = NSLocalizedString("We make easier to manage your memories with homepage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotlightHomePageGeneralText = NSLocalizedString("You can reach your recent activites and suggestions that are special for you from this page", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotlightMovieCardText = NSLocalizedString("Discover your first story", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotlightAlbumCard = NSLocalizedString("Discover your first album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotlightCollageCard = NSLocalizedString("Discover your first collage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotlightAnimationCard = NSLocalizedString("Discover your first animation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotlightFilterCard = NSLocalizedString("Discover your first filtered photo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")    
    static let lifeboxMemoryLimit = NSLocalizedString("You have reached your lifebox memory limit", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let periodicContactsSyncAccessAlertTitle = NSLocalizedString("Error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let periodicContactsSyncAccessAlertText = NSLocalizedString("Error occurred while accessing your contacts.\nPlease check your settings.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let periodicContactsSyncAccessAlertGoToSettings = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let periodicContactsSyncAccessAlertNo = NSLocalizedString("No", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settings = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let packagesSubtitle = NSLocalizedString("Import fearture is totally free of charge and does not affect your internet package", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sortby = NSLocalizedString("Sort By", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let successfullyPurchased = NSLocalizedString("Successfully purchased", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let invalidCaptcha = NSLocalizedString("This text doesn't match. Please try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let free = NSLocalizedString("Free", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    //MARK: - Landing
    static let landingStartUsing = NSLocalizedString("START USING", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingTitle0 = NSLocalizedString("landingTitle0", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingSubTitle0 = NSLocalizedString("landingSubTitle0", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingTitle1 = NSLocalizedString("landingTitle1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingSubTitle1 = NSLocalizedString("landingSubTitle1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingTitle2 = NSLocalizedString("landingTitle2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingSubTitle2 = NSLocalizedString("landingSubTitle2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingTitle3 = NSLocalizedString("landingTitle3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingSubTitle3 = NSLocalizedString("landingSubTitle3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingTitle4 = NSLocalizedString("landingTitle4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingSubTitle4 = NSLocalizedString("landingSubTitle4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingTitle5 = NSLocalizedString("landingTitle5", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingSubTitle5 = NSLocalizedString("landingSubTitle5", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingTitle6 = NSLocalizedString("landingTitle6", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let landingSubTitle6 = NSLocalizedString("landingSubTitle6", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let created = NSLocalizedString("created", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploaded = NSLocalizedString("uploaded", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let updated = NSLocalizedString("updated", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleted = NSLocalizedString("deleted", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let moved = NSLocalizedString("moved", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let renamed = NSLocalizedString("renamed", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let copied = NSLocalizedString("copied", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let markedAsFavourite = NSLocalizedString("marked as favourite", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorUnsupportedExtension = NSLocalizedString("download_error_unsupported_extension", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let facebookPhotoTags = NSLocalizedString("facebook_photo_tags", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let facebookTagsOn = NSLocalizedString("facebook_tags_on", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let facebookTagsOff = NSLocalizedString("facebook_tags_off", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let facebookTagsImport = NSLocalizedString("facebook_tags_import", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceTagsDescriptionPremium = NSLocalizedString("face_tags_description_premium", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let launchCampaignCardDetail = NSLocalizedString("launch_campaign_card_detail", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let launchCampaignCardTitle = NSLocalizedString("launch_campaign_card_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let launchCampaignCardMessage = NSLocalizedString("launch_campaign_card_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    //MARK: - PremiumView
    static let deleteDuplicatedTitle = NSLocalizedString("delete_duplicated_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceRecognitionTitle = NSLocalizedString("face_recognition_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let placesTitle = NSLocalizedString("places_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let thingsTitle = NSLocalizedString("things_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    //MARK: - FaceImagePremiumFooterView
    static let faceImageFooterViewMessage = NSLocalizedString("face_image_footer_view_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageFaceRecognition = NSLocalizedString("face_image_face_recognition", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImagePlaceRecognition = NSLocalizedString("face_image_place_recognition", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageThingRecognition = NSLocalizedString("face_image_thing_recognition", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    //MARK: - Premium
    static let useFollowingPremiumMembership = NSLocalizedString("use_following_premium_membership_advantages_with_only_additional_your_data_storage_package", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let month = NSLocalizedString("month", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let noDetailsMessage = NSLocalizedString("no_details_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let serverErrorMessage = NSLocalizedString("please_try_again_later", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let backUpOriginalQuality = NSLocalizedString("Back up with Original Quality", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let removeDuplicateContacts = NSLocalizedString("Remove Duplicate Contacts from Your Directory", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceRecognitionToReach = NSLocalizedString("Face Recognition to reach your loved one's memories", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let placeRecognitionToBeam = NSLocalizedString("Place Recognition to beam you up to the memories", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let objectRecognitionToRemember = NSLocalizedString("Object Recognition to remember with things you love", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let unlimitedPhotopickAnalysis = NSLocalizedString("unlimited_photopick_analysis", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let storeInHighQuality = NSLocalizedString("store_in_high_quality", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fiveAnalysis = NSLocalizedString("5_photopick_analysis", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tenAnalysis = NSLocalizedString("10_photopick_analysis", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let dataPackageForTurkcell = NSLocalizedString("data_package_for_turkcell", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteDuplicatedContacts = NSLocalizedString("delete_duplicated_contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let additionalDataAdvantage = NSLocalizedString("additional_data_advantage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let becomePremium = NSLocalizedString("Become Premium", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let becomePremiumMember = NSLocalizedString("Become Premium Member!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let leavePremiumMember = NSLocalizedString("leave_premium_membership", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let leaveMiddleMember = NSLocalizedString("leave_middle_membership", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let standardUser = NSLocalizedString("Standard User", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let midUser = NSLocalizedString("mid_user", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let premiumUser = NSLocalizedString("Premium User", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let middleUser = NSLocalizedString("middle_user", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxPremium = NSLocalizedString("lifebox Premium", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxMiddle = NSLocalizedString("lifebox_middle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxStandart = NSLocalizedString("lifebox_standart", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteDuplicatedContactsForPremiumTitle = NSLocalizedString("Delete Duplicated Contacts For PremiumTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    //MARK: - PremiumBanner
    static let premiumBannerMessage = NSLocalizedString("premium_banner_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let standardBannerMessage = NSLocalizedString("standard_banner_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let premiumBannerTitle = NSLocalizedString("premium_banner_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let standardBannerTitle = NSLocalizedString("standard_banner_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let backUpShort = NSLocalizedString("back_up_short", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let removeDuplicateShort = NSLocalizedString("remove_duplicate_short", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let placesRecognitionShort = NSLocalizedString("places_recognition_short", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceRecognitionShort = NSLocalizedString("face_recognition_short", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let objectRecognitionShort = NSLocalizedString("object_recognition_short", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let photoPickShort = NSLocalizedString("unlimited_photopick_analysis", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    //MARK: - LeavePremiumViewController
    
    static let leavePremiumPremiumDescription = NSLocalizedString("leave_premium_premium_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let leavePremiumCancelDescription = NSLocalizedString("leave_premium_cancel_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let accountDetailMiddleTitle = NSLocalizedString("account_detail_middle_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accountDetailMiddleDescription = NSLocalizedString("account_detail_middle_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let accountDetailStandartTitle = NSLocalizedString("account_detail_standart_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accountDetailStandartDescription = NSLocalizedString("account_detail_standart_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let leaveMiddleTurkcell = NSLocalizedString("leave_middle_turkcell", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let featureAppleCancelText = NSLocalizedString("feature_apple_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureSLCMCancelText = NSLocalizedString("feature_slcm_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureGoogleCancelText = NSLocalizedString("feature_google_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureFreeOfChargeCancelText = NSLocalizedString("feature_free_of_charge_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureLifeCellCancelText = NSLocalizedString("feature_lifecell_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featurePromoCancelText = NSLocalizedString("feature_promo_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureKKTCellCancelText = NSLocalizedString("feature_kktcell_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureMoldCellCancelText = NSLocalizedString("feature_moldcell_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureAlbanianCancelText = NSLocalizedString("feature_albanian_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureDigicellCancelText = NSLocalizedString("feature_digicell_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureLifeCancelText = NSLocalizedString("feature_life_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featurePaycellAllAccessCancelText = NSLocalizedString("feature_paycell_all_access_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featurePaycellSLCMCancelText = NSLocalizedString("feature_paycell_slcm_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureSLCMPaycellCancelText = NSLocalizedString("feature_slcm_paycell_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureAllAccessPaycellCancelText = NSLocalizedString("feature_all_access_paycell_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureDefaultCancelText = NSLocalizedString("feature_default_cancel_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    //MARK: - PackageInfoView
    static let myStorage = NSLocalizedString("my_storage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let seeDetails = NSLocalizedString("see_details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageGroupingDescription = NSLocalizedString("face_image_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageUpgrade = NSLocalizedString("face_image_upgrade", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceTagsDescriptionStandart = NSLocalizedString("face_tags_description_standart", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let homePagePopup = NSLocalizedString("home_page_pop_up", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let syncPopup = NSLocalizedString("sync_page_pop_up", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let descriptionAboutStandartUser = NSLocalizedString("uploded_photos_high_quality", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let yesForUpgrade = NSLocalizedString("ok_for_upgrade", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let noForUpgrade = NSLocalizedString("no_for_upgrade", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    //MARK: - InstaPick Analyze History Page
    static let analyzeHistorySeeDetails = NSLocalizedString("instapick_see_details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryTitle = NSLocalizedString("InstaPick", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryPopupTitle = NSLocalizedString("no_analyses_left_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryPopupMessage = NSLocalizedString("no_analyses_left_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryFreeText = NSLocalizedString("analyze_history_free_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryEmptyTitle = NSLocalizedString("analyze_history_empty_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryEmptySubtitle = NSLocalizedString("analyze_history_empty_subtitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryAnalyzeLeft = NSLocalizedString("analyze_history_analyze_left", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryAnalyzeCount = NSLocalizedString("analyze_history_analyze_count", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryAnalyseButton = NSLocalizedString("analyze_with_instapick", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryPhotosCount = NSLocalizedString("analyze_history_photos_count", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryStartHereTitle = NSLocalizedString("analyze_history_start_here", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryConfirmDeleteTitle = NSLocalizedString("analyze_confirm_delete_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryConfirmDeleteText = NSLocalizedString("analyze_confirm_delete_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryConfirmDeleteYes = NSLocalizedString("analyze_confirm_delete_yes", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let analyzeHistoryConfirmDeleteNo = NSLocalizedString("analyze_confirm_delete_no", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    //MARK: - InstapickUpgradePopup
    static let instapickUpgradePopupText = NSLocalizedString("instapick_upgrade_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instapickUpgradePopupButton = NSLocalizedString("instapick_upgrade_popup_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instapickUpgradePopupNoButton = NSLocalizedString("instapick_upgrade_popup_no", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    //MARK: - InstaPickThreeDors
    static let newInstaPick = NSLocalizedString("new_insta_pick", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    //MARK: - InstaPickCard
    static let instaPickUsedBeforeTitleLabel = NSLocalizedString("used_before_title_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickNoUsedBeforeTitleLabel = NSLocalizedString("no_used_before_title_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickNoAnalysisTitleLabel = NSLocalizedString("no_analysis_title_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickFreeTrialTitleLabel = NSLocalizedString("free_trial_title_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let instaPickUsedBeforeDetailLabel = NSLocalizedString("used_before_detail_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickNoUsedBeforeDetailLabel = NSLocalizedString("no_used_before_detail_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickNoAnalysisDetailLabel = NSLocalizedString("no_analysis_detail_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickFreeTrialDetailLabel = NSLocalizedString("free_trial_detail_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let instaPickButtonHasAnalysis = NSLocalizedString("instapick_button_has_analysis", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickButtonNoAnalysis = NSLocalizedString("no_analyses_left_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let analyzeWithInstapick = NSLocalizedString("analyze_with_instapick", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    //InstaPickDetailViewController
    
    static let instaPickReadyToShareLabel = NSLocalizedString("you_are_ready_to_share", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickLeftCountLabel = NSLocalizedString("instapick_analysis_left", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickUnlimitedLeftCountLabel = NSLocalizedString("instapick_unlimited_analysis", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickMoreHashtagsLabel = NSLocalizedString("engage_with_more_hastags", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickCopyHashtagsButton = NSLocalizedString("copy_hashtags_to_clipboard", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickShareButton = NSLocalizedString("share_on_social_media", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let instaPickPictureNotFoundLabel = NSLocalizedString("insta_pick_picture_not_found", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickPickedLabel = NSLocalizedString("picked", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickAnalyzingBottomText = NSLocalizedString("insta_pick_analyzing_bottom", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickAnalyzingText_0 = NSLocalizedString("insta_pick_analyzing_0", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickAnalyzingText_1 = NSLocalizedString("insta_pick_analyzing_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickAnalyzingText_2 = NSLocalizedString("insta_pick_analyzing_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickAnalyzingText_3 = NSLocalizedString("insta_pick_analyzing_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickAnalyzingText_4 = NSLocalizedString("insta_pick_analyzing_4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    //MARK: - InstaPickPopUp
    static let instaPickDontShowThisAgain = NSLocalizedString("dont_show_this_again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickAnlyze = NSLocalizedString("instapick_analyze", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickConnectedAccount = NSLocalizedString("connected_account", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickDescription = NSLocalizedString("instapick_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickConnectedWithInstagram = NSLocalizedString("connected_with_instagram", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickConnectedWithInstagramName = NSLocalizedString("connected_with_instagram_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instaPickConnectedWithoutInstagram = NSLocalizedString("continue_without_connecting", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let instapickSelectionPhotosSelected = NSLocalizedString("instapick_selection_photos_selected", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instapickSelectionAnalyzesLeftMax = NSLocalizedString("instapick_selection_analyzes_left_max", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instapickUnderConstruction = NSLocalizedString("instapick_under_construction", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instapickUnsupportedFileType = NSLocalizedString("instapick_unsupported_file_type", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instapickNoAvailableUnitsLeft = NSLocalizedString("instapick_no_available_units_left", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instapickConnectionProblemOccured = NSLocalizedString("connection_problem_occured", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loading = NSLocalizedString("loading", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let thereAreNoPhotos = NSLocalizedString("there_are_no_photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let thereAreNoAlbums = NSLocalizedString("there_are_no_albums", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let facebook = NSLocalizedString("Facebook", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let dropbox = NSLocalizedString("Dropbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instagram = NSLocalizedString("Instagram", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotify = NSLocalizedString("Spotify", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let instagramConnectedAsFormat = NSLocalizedString("connected_as_format", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotyfyLastImportFormat = NSLocalizedString("spotify_last_import", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let instagramRemoveConnectionWarning = NSLocalizedString("instagram_remove_connection_warning_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let facebookRemoveConnectionWarning = NSLocalizedString("facebook_remove_connection_warning_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let dropboxRemoveConnectionWarning = NSLocalizedString("dropbox_remove_connection_warning_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotifyRemoveConnectionWarning = NSLocalizedString("spotify_remove_connection_warning_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let instagramRemoveConnectionWarningMessage = NSLocalizedString("instagram_remove_connection_warning_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let facebookRemoveConnectionWarningMessage = NSLocalizedString("facebook_remove_connection_warning_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let dropboxRemoveConnectionWarningMessage = NSLocalizedString("dropbox_remove_connection_warning_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let spotifyRemoveConnectionWarningMessage = NSLocalizedString("spotify_remove_connection_warning_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let removeConnection = NSLocalizedString("remove_connection", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let youAreConnected = NSLocalizedString("you_are_connected", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let phoneUpdatedNeedsLogin = NSLocalizedString("phone_updated_needs_login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let oldPassword = NSLocalizedString("old_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let newPassword = NSLocalizedString("new_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let repeatPassword = NSLocalizedString("repeat_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let changePasswordCaptchaAnswerPlaceholder = NSLocalizedString("change_password_captcha_answer_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let temporaryErrorOccurredTryAgainLater = NSLocalizedString("temporary_error_occurred_try_again_later", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let oldPasswordDoesNotMatch = NSLocalizedString("old_password_does_not_match", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let newPasswordAndRepeatedPasswordDoesNotMatch = NSLocalizedString("new_password_and_repeated_password_does_not_match", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let newPasswordIsEmpty = NSLocalizedString("new_password_is_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let oldPasswordIsEmpty = NSLocalizedString("old_password_is_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let repeatPasswordIsEmpty = NSLocalizedString("repeat_password_is_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let thisTextIsEmpty = NSLocalizedString("this_text_is_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passwordChangedSuccessfully = NSLocalizedString("password_changed_successfully", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passwordChangedSuccessfullyRelogin = NSLocalizedString("password_changed_successfully_relogin", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let captchaAnswerPlaceholder = NSLocalizedString("captcha_answer_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let profilePhoneNumberTitle = NSLocalizedString("profile_phone_number_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let profilePhoneNumberPlaceholder = NSLocalizedString("profile_phone_number_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let pleaseEnterYourName = NSLocalizedString("please_enter_your_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterYourName = NSLocalizedString("enter_your_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let pleaseEnterYourSurname = NSLocalizedString("please_enter_your_surname", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterYourSurname = NSLocalizedString("enter_your_surname", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterYourEmailAddress = NSLocalizedString("enter_your_email_address", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let subject = NSLocalizedString("subject", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let pleaseEnterYourSubject = NSLocalizedString("please_enter_your_subject", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let pleaseChooseSubject = NSLocalizedString("please_choose_subject", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let yourProblem = NSLocalizedString("your_problem", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let pleaseEnterYourProblemShortly = NSLocalizedString("please_enter_your_problem_shortly", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let explainYourProblemShortly = NSLocalizedString("explain_your_problem_shortly", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let pleaseEnterMsisdnOrEmail = NSLocalizedString("please_enter_msisdn_or_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormProblemDescription = NSLocalizedString("support_form_problem_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let supportFormSubject1 = NSLocalizedString("support_form_subject_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormSubject2 = NSLocalizedString("support_form_subject_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormSubject3 = NSLocalizedString("support_form_subject_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormSubject4 = NSLocalizedString("support_form_subject_4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormSubject5 = NSLocalizedString("support_form_subject_5", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormSubject6 = NSLocalizedString("support_form_subject_6", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormSubject7 = NSLocalizedString("support_form_subject_7", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let contactUsSubject1 = NSLocalizedString("contact_us_subject_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject2 = NSLocalizedString("contact_us_subject_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject3 = NSLocalizedString("contact_us_subject_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject4 = NSLocalizedString("contact_us_subject_4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject5 = NSLocalizedString("contact_us_subject_5", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject6 = NSLocalizedString("contact_us_subject_6", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject7 = NSLocalizedString("contact_us_subject_7", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject8 = NSLocalizedString("contact_us_subject_8", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject9 = NSLocalizedString("contact_us_subject_9", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject10 = NSLocalizedString("contact_us_subject_10", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject11 = NSLocalizedString("contact_us_subject_11", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactUsSubject12 = NSLocalizedString("contact_us_subject_12", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let enterYourOldPassword = NSLocalizedString("enter_your_old_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterYourNewPassword = NSLocalizedString("enter_your_new_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterYourRepeatPassword = NSLocalizedString("enter_your_repeat_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let enterYourPassword = NSLocalizedString("enter_your_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let reenterYourPassword = NSLocalizedString("re_enter_your_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signupSupportInfo = NSLocalizedString("signup_support_info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginSupportInfo = NSLocalizedString("login_support_info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let missingInformation = NSLocalizedString("missing_information", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let pleaseEnterYourMissingAccountInformation = NSLocalizedString("please_enter_your_missing_account_information", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginEmailOrPhonePlaceholder = NSLocalizedString("login_email_or_phone_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPasswordPlaceholder = NSLocalizedString("login_password_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let loginEmailOrPhoneError = NSLocalizedString("login_email_or_phone_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPasswordError = NSLocalizedString("login_password_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let captchaIsEmpty = NSLocalizedString("captcha_is_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginUsernameNotValid = NSLocalizedString("login_username_not_valid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myProfileFAQ = NSLocalizedString("frequently_asked_questions", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let photoPickDescription = NSLocalizedString("photo_pick_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let createStoryPhotosSelected = NSLocalizedString("create_story_photos_selected", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPressAndHoldDescription = NSLocalizedString("create_story_press_and_hold_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPressAndHold = NSLocalizedString("create_story_press_and_hold", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryNameTitle = NSLocalizedString("create_story_name_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let createStoryPopUpTitle = NSLocalizedString("create_story_pop_up_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPopUpMessage = NSLocalizedString("create_story_pop_up_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPathToStory = NSLocalizedString("create_story_path_to_story", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let downloadLimitAllert = NSLocalizedString("selected_items_limit_download", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteLimitAllert = NSLocalizedString("selected_items_limit_delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginSettingsSecurityPasscodeDescription = NSLocalizedString("login_settings_security_passcode_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginSettingsSecurityAutologinDescription = NSLocalizedString("login_settings_security_autologin_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginSettingsTwoFactorAuthDescription = NSLocalizedString("login_settings_two_factor_auth_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let twoFAInvalidSessionErrorMessage = NSLocalizedString("two_fa_invalid_session_error_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFAInvalidChallengeErrorMessage = NSLocalizedString("two_fa_invalid_challenge_error_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFATooManyAttemptsErrorMessage = NSLocalizedString("two_fa_too_many_attempts_error_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFAInvalidOtpErrorMessage = NSLocalizedString("two_fa_invalid_Otp_error_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFATooManyRequestsErrorMessage = NSLocalizedString("two_fa_too_many_requests_error_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let twoFAEmailNewOTPDescription = NSLocalizedString("two_fa_email_new_otp_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFAEmailExistingOTPDescription = NSLocalizedString("two_fa_email_existing_otp_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFAPhoneNewOTPDescription = NSLocalizedString("two_fa_phone_new_otp_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let twoFAPhoneExistingOTPDescription = NSLocalizedString("two_fa_phone_existing_otp_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    //MARK: - Spotify
    
    enum Spotify {
        enum Import {
            static let navBarTitle = NSLocalizedString("spotify_import_navbar_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let importing = NSLocalizedString("spotify_importing", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let fromSpotify = NSLocalizedString("spotify_import_from", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let toLifebox = NSLocalizedString("spotify_import_to", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let description = NSLocalizedString("spotify_import_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let importInBackground = NSLocalizedString("spotify_import_in_background", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let lastImportFromSpotifyFailedError = NSLocalizedString("spotify_import_failed_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        }
        enum Playlist {
            static let importButton = NSLocalizedString("spotify_playlist_import_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let navBarTitle = NSLocalizedString("spotify_playlist_navbar_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let navBarSelectiontTitle = NSLocalizedString("spotify_playlist_navbar_selection_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let songsCount = NSLocalizedString("spotify_playlist_songs_count", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let successImport = NSLocalizedString("spotify_playlist_success_import", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let seeImported = NSLocalizedString("spotify_playlist_see_imported", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let transferingPlaylistError = NSLocalizedString("spotify_trasfering_playlist_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let noPlaylists = NSLocalizedString("spotify_no_playlists", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let noImportedPlaylists = NSLocalizedString("spotify_no_imported_playlists", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let noTracks = NSLocalizedString("spotify_no_tracks", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        }
        enum OverwritePopup {
            static let message = NSLocalizedString("spotify_overwrite_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let messageBoldFontText = NSLocalizedString("spotify_overwrite_message_bold", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let cancelButton = NSLocalizedString("spotify_overwrite_cancel_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let importButton = NSLocalizedString("spotify_overwrite_import_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        }
        enum Card {
            static let title = NSLocalizedString("spotify_card_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let importing = NSLocalizedString("spotify_card_importing", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let lastUpdate = NSLocalizedString("spotify_card_last_update", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        }
        enum DeletePopup {
            static let title = NSLocalizedString("spotify_delete_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let titleBoldFontText = NSLocalizedString("spotify_delete_title_bold", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let subtitle = NSLocalizedString("spotify_delete_subtitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let deleteButton = NSLocalizedString("spotify_delete_delete_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        }
        enum CancelImportPopup {
            static let title = NSLocalizedString("spotify_cancel_import_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let titleBoldFontText = NSLocalizedString("spotify_cancel_import_title_bold", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let subtitle = NSLocalizedString("spotify_cancel_import_subtitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let continueButton = NSLocalizedString("spotify_cancel_import_continue_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
            static let cancelButton = NSLocalizedString("spotify_cancel_import_cancel_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        }
    }
    static let confirm = NSLocalizedString("confirm", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let later = NSLocalizedString("later", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let changeEmail = NSLocalizedString("change_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let verifyEmailTopTitle = NSLocalizedString("verify_email_top_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterTheSecurityCode = NSLocalizedString("enter_the_security_code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let change = NSLocalizedString("change", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fieldsAreNotMatch = NSLocalizedString("fields_are_not_matched", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let yourEmail = NSLocalizedString("your_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let confirmYourEmail = NSLocalizedString("confirm_your_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterYourEmail = NSLocalizedString("enter_your_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let changeEmailPopUpTopTitle = NSLocalizedString("change_email_pop_up_top_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accountVerified = NSLocalizedString("account_verified", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let noAccountFound = NSLocalizedString("no_account_found", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tooManyRequests = NSLocalizedString("too_many_requests", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let invalidOTP = NSLocalizedString("invalid_otp", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let expiredOTP = NSLocalizedString("expired_otp", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tokenIsMissing = NSLocalizedString("token_is_missing", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let invalidEmail = NSLocalizedString("invalid_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let storage = NSLocalizedString("storage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let paymentTitleAppStore = NSLocalizedString("payment_title_app_store", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let paymentTitleCreditCard = NSLocalizedString("payment_title_credit_card", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let paymentTitleInvoice = NSLocalizedString("payment_title_invoice", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
}
