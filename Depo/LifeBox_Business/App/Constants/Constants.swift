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
        static let flIdentifierKey = "FastLogin"
        
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
    
    static let itroViewGoToRegisterButtonText = NSLocalizedString("Start using Lifebox now!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let introViewGoToLoginButtonText = NSLocalizedString("Login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

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
    static let tooManyInvalidAttempt = NSLocalizedString("too_many_invalid_attempt", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
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
    static let signUpErrorPasswordLengthIsBelowLimit = NSLocalizedString("sing_up_error_password_length_is_below_limit", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signUpErrorPasswordLengthExceeded = NSLocalizedString("sing_up_error_password_length_exceeded", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signUpErrorSequentialCharacters = NSLocalizedString("sing_up_error_sequential_characters", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signUpErrorSameCharacters = NSLocalizedString("sing_up_error_same_characters", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signUpErrorUppercaseMissing = NSLocalizedString("sing_up_error_uppercase_missing", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signUpErrorLowercaseMissing = NSLocalizedString("sing_up_error_lowercase_missing", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signUpErrorNumberMissing = NSLocalizedString("sing_up_error_number_missing", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signUpErrorUnauthorized = NSLocalizedString("sing_up_error_unauthorized", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    // MARK: -
    static let termsAndUsesTitle = NSLocalizedString("business_app_eula_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUsesApplyButtonText = NSLocalizedString("Accept  Terms", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseTextFormat = NSLocalizedString("<html><body text=\"#FFFFFF\" face=\"Bookman Old Style, Book Antiqua, Garamond\" size=\"5\">%@</body></html>", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseStartUsingText = NSLocalizedString("business_app_privacy_policy_start", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseCheckboxText = NSLocalizedString("business_app_eula_checkbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseEtkCheckbox = NSLocalizedString("terms_and_use_etk_checkbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseEtkCheckboxHeader = NSLocalizedString("terms_and_use_etk_checkbox_header", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseIntroductionCheckbox = NSLocalizedString("terms_and_use_introduction_checkbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privacyPolicy = NSLocalizedString("business_app_eula_privacy_policy_textbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseEtkLinkTurkcellAndGroupCompanies = NSLocalizedString("terms_and_use_etk_link_turkcell_and_group_companies", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privacyPolicyCondition = NSLocalizedString("business_app_privacy_policy_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privacyPolicyHeadLine = NSLocalizedString("privacy_policy_head_line", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseEtkLinkCommercialEmailMessages = NSLocalizedString("terms_and_use_etk_link_commercial_email_messages", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsAndUseCheckboxErrorText = NSLocalizedString("You need to confirm the User Agreement to continue.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let commercialEmailMessages = NSLocalizedString("commercial_email_messages", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseGlobalPermScreenTitle = NSLocalizedString("global_permission_screen_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseGlobalPermHeader = NSLocalizedString("global_permission_header", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseGlobalDataPermCheckbox = NSLocalizedString("global_data_permission_agreement", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseGlobalDataPermLinkSeeDetails = NSLocalizedString("global_data_permission_link", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let etkHTMLText = NSLocalizedString("etk_html", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let loginTitle = NSLocalizedString("Login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginTableTitle = NSLocalizedString("Register to lifebox and get a 5 GB of storage for free!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCantLoginButtonTitle = NSLocalizedString("I can't login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginRememberMyCredential = NSLocalizedString("Remember my credentials", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCellTitleEmail = NSLocalizedString("E-Mail or GSM Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCellTitlePassword = NSLocalizedString("Password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCellEmailPlaceholder = NSLocalizedString( "You have to fill in your mail or GSM Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginCellPasswordPlaceholder = NSLocalizedString("You have to fill in a password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginFAQButton = NSLocalizedString("login_faq", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let signUpPasswordRulesLabel = NSLocalizedString("sign_up_password_rules", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let alreadyHaveAccountTitle = NSLocalizedString("Already have an account?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let welcome1Info = NSLocalizedString("Welcome1Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let welcome1SubInfo = NSLocalizedString("Welcome1SubInfo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        
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
    
    static let enterSecurityCode = NSLocalizedString("enter_security_code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let enterCodeToGetCodeOnPhone = NSLocalizedString("enter_code_get_code_on_phone", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let timeIsUpForCode = NSLocalizedString("time_is_up_for_code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let resendCode = NSLocalizedString("resend_code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorAlert = NSLocalizedString("Error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorAlertYesBtnBackupAlreadyExist = NSLocalizedString("Yes", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
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
    static let uploadFiles = NSLocalizedString("Upload Files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadMusic = NSLocalizedString("Upload Music", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let newFolder = NSLocalizedString("New Folder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadFromLifebox = NSLocalizedString("Upload from lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
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
    
    // MARK: - Sync out of space alert
    static let syncOutOfSpaceAlertTitle = NSLocalizedString("Caution!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let syncOutOfSpaceAlertText = NSLocalizedString("You have reached your lifebox memory limit.\nLet’s have a look for upgrade options!", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let upgrade = NSLocalizedString("Upgrade", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let syncOutOfSpaceAlertCancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

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
    
    // MARK: Popup
    static let ok = NSLocalizedString("OK", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let downloadDocumentErrorPopup = NSLocalizedString("download_document_error_popup", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
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
    static let photosVideosAutoSyncSettings = NSLocalizedString("photo_video_auto_sync_settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let photosVideosEmptyNoUnsyncPhotosTitle = NSLocalizedString("photo_video_empty_no_unsync_photos_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
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
    static let settingsUserInfoNameSurname = NSLocalizedString("settings_userinfo_name_surname", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsUserInfoEmail = NSLocalizedString("settings_userinfo_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let settingsUserInfoPhone = NSLocalizedString("settings_userinfo_phone", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    // MARK: FAQ
    
    static let faqViewTitle = NSLocalizedString("Help and Support", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Terms of Use and Privacy Policy
     static let termsOfUseCell = NSLocalizedString("terms_of_use", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
     static let privacyPolicyCell = NSLocalizedString("privacy_policy_cell", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
    // MARK: Face Image
    static let faceImageDone = NSLocalizedString("Done", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageEnable =  NSLocalizedString("face_image_enable", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceImageEnableMessageText =  NSLocalizedString("face_image_enable_message_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

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
    static let userProfileSecretQuestion =  NSLocalizedString("security_question", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileEditSecretQuestion =  NSLocalizedString("edit_security_question", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileNoSecretQuestion =  NSLocalizedString("no_security_question", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileSecretQuestionInvalidId =  NSLocalizedString("sequrity_question_id_is_invalid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileSecretQuestionInvalidAnswer =  NSLocalizedString("sequrity_question_answer_is_invalid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileEditSecretQuestionSuccess =  NSLocalizedString("edit_security_question_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileSetSecretQuestionSuccess =  NSLocalizedString("set_security_question_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let userProfileSelectQuestion =  NSLocalizedString("select_question", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileSecretQuestionAnswer =  NSLocalizedString("secret_answer", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileSecretQuestionAnswerPlaseholder =  NSLocalizedString("enter_secret_answer", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileSecretQuestionLabelPlaceHolder = NSLocalizedString("security_question_text_field_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let userProfileSetSecretQuestionButton = NSLocalizedString("set_sequrity_question_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
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
    static let fileInfoPeople = NSLocalizedString("file_info_people", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    //MARK: Permissions in Settings
    static let etkPermissionTitleLabel = NSLocalizedString("etk_permission_title_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let etkPermissionDescription = NSLocalizedString("etk_permission_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let globalPermissionTitleLabel = NSLocalizedString("global_permission_title_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let globalPermissionDescriptionLabel = NSLocalizedString("global_permission_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let informativeDescription = NSLocalizedString("informative_description_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentPermissionTitleLabel = NSLocalizedString("mobile_payment_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentPermissionDescriptionLabel = NSLocalizedString("mobile_payment_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentPermissionLink = NSLocalizedString("mobile_payment_link", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentViewTitleLabel = NSLocalizedString("mobile_payment_view_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentViewDescriptionLabel = NSLocalizedString("mobile_payment_view_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentViewLinkLabel = NSLocalizedString("mobile_payment_view_link_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentClosePopupTitleLabel = NSLocalizedString("mobile_payment_close_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentClosePopupDescriptionLabel = NSLocalizedString("mobile_payment_close_popup_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
     static let mobilePaymentClosePopupDescriptionBoldRangeLabel = NSLocalizedString("mobile_payment_close_popup_description_bold_range", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentOpenPopupTitleLabel = NSLocalizedString("mobile_payment_open_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentOpenPopupDescriptionLabel = NSLocalizedString("mobile_payment_open_popup_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentOpenPopupDescriptionBoldRangeLabel = NSLocalizedString("mobile_payment_open_popup_description_bold_range", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentOpenPopupContinueButton = NSLocalizedString("mobile_payment_open_popup_continue_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
     static let mobilePaymentOpenPopupLaterButton = NSLocalizedString("mobile_payment_open_popup_later_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobilePaymentSuccessPopupTitle = NSLocalizedString("mobile_payment_success_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
     static let mobilePaymentSuccessPopupMessage = NSLocalizedString("mobile_payment_success_popup_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
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
    static let settingsContactsPermissionDeniedMessage = NSLocalizedString("You need to enable access to Contacts to continue", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Create story Photos
    static let createStoryPhotosContinue = NSLocalizedString("Continue", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let createStoryPhotosMaxCountAllert = NSLocalizedString("Please choose %d files at most", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        
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
    static let tabBarItemHomeLabel = NSLocalizedString("tabbar_item_home_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarItemGalleryLabel = NSLocalizedString("tabbar_item_gallery_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarItemContactsLabel = NSLocalizedString("tabbar_item_contacts_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarItemAllFilesLabel = NSLocalizedString("tabbar_item_all_files_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let music = NSLocalizedString("Music", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let documents = NSLocalizedString("Documents", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarDeleteLabel = NSLocalizedString("Delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarRemoveAlbumLabel = NSLocalizedString("Remove Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarRemoveLabel = NSLocalizedString("Remove From Album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabAlbumCoverAlbumLabel = NSLocalizedString("Make album cover", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarPrintLabel = NSLocalizedString("Print", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarDownloadLabel = NSLocalizedString("Download", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarSyncLabel = NSLocalizedString("Sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarMoveLabel = NSLocalizedString("Move", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarInfoLabel = NSLocalizedString("Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarShareLabel = NSLocalizedString("business_app_share_copy_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarSharePrivatelyLabel = NSLocalizedString("business_app_share_privately_option", tableName: "OurLocalizable", bundle: .main, comment: "")
    
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
    static let shareEmptyAlbumError = NSLocalizedString("You can not share empty album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
     
    // MARK: Feedback View
    static let feedbackMailTextFormat = NSLocalizedString("Please do not delete the information below. The information will be used to address the problem.\n\nApplication Version: %@\nMsisdn: %@\nCarrier: %@\nDevice:%@\nDevice OS: %@\nLanguage: %@\nLanguage preference: %@\nNetwork Status: %@\nTotal Storage: %lld\nUsed Storage: %lld\nPackages: %@\n", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let supportFormBilloTopText = NSLocalizedString("billo_contactus_top_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
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
    static let popUpHideComplete = NSLocalizedString("photos_hide_success_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let popUpDownloadComplete = NSLocalizedString("Download is complete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeAppSpacePopUpTextNormal = NSLocalizedString("There are some duplicated items both in your device and lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeAppSpacePopUpButtonTitle = NSLocalizedString("Free up space", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeUpSpaceAlertTitle = NSLocalizedString("free_up_space_alert_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeUpSpaceNoDuplicates = NSLocalizedString("free_up_space_no_duplicates", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeUpSpaceInProgress = NSLocalizedString("free_up_space_in_progress", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let networkTypeWiFi = NSLocalizedString("Wi-Fi", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let mobileData = NSLocalizedString("Mobile Data", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoUploaOffPopUpTitleText = NSLocalizedString("Auto Upload is off.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoUploaOffPopUpSubTitleText = NSLocalizedString("Photos and videos waiting to be synced", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let autoUploaOffSettings = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let waitingForWiFiPopUpTitle = NSLocalizedString("Waiting for Wi-Fi connection to auto-sync", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let waitingForWiFiPopUpSettingsButton = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let prepareQuickScroll = NSLocalizedString("Quick Scroll Preparation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    // MARK: - ActionSheet
    static let actionSheetDeleteDeviceOriginal = NSLocalizedString("Delete Device Original", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetCancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    
    static let actionSheetShare = NSLocalizedString("Share", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetInfo = NSLocalizedString("Info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetEdit = NSLocalizedString("Edit", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetDelete = NSLocalizedString("Delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetEmptyTrashBin = NSLocalizedString("empty_trash_bin", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetMove = NSLocalizedString("Move", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetDownload = NSLocalizedString("Download", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetRestore = NSLocalizedString("restore_confirmation_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetShareSmallSize = NSLocalizedString("Small Size", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetSharePrivate = NSLocalizedString("private_share_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetShareOriginalSize = NSLocalizedString("Original Size", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetShareShareViaLink = NSLocalizedString("Share Via Link", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetShareCancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetCopy = NSLocalizedString("Copy", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetAddToFavorites = NSLocalizedString("Add to Favorites", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetRemove = NSLocalizedString("Remove", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetRemoveFavorites = NSLocalizedString("Remove from Favorites", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetAddToAlbum = NSLocalizedString("Add to album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetBackUp = NSLocalizedString("Back Up", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetRemoveFromAlbum = NSLocalizedString("Remove from album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSheetProfileDetails = NSLocalizedString("settings_action_sheet_profile_details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetEditProfilePhoto = NSLocalizedString("settings_action_sheet_edit_profile_photo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSheetAccountDetails = NSLocalizedString("settings_action_sheet_account_details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
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
    static let actionSheetDownloadToCameraRoll = NSLocalizedString("Download to Camera Roll", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: Free Up Space
    static let freeAppSpaceTitle = NSLocalizedString("There are %d duplicated photos both in your device and lifebox. Clear some space by selecting the photos that you want to delete.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let freeAppSpaceAlertSuccesTitle = NSLocalizedString("You have free space for %d more items.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let save = NSLocalizedString("Save", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let cropyMessage = NSLocalizedString("This edited photo will be saved as a new photo in your device gallery", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let cancel = NSLocalizedString("Cancel", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    
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
    
    static let promocodeInvalid = NSLocalizedString("Verification code is invalid.\nPlease try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let promocodeBlocked = NSLocalizedString("Verification code is blocked.\nPlease request a new code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let accountDetails = NSLocalizedString("account_details", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myProfile = NSLocalizedString("my_profile", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let purchase = NSLocalizedString("Purchase", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let packagesPolicyHeader = NSLocalizedString("PackagesPolicyHeader", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagesPolicyText = NSLocalizedString("PackagesPolicyText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let packagesPolicyBilloText = NSLocalizedString("PackagesPolicyTextBillo", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let termsOfUseLinkText = NSLocalizedString("TermsOfUseLinkText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let feature = NSLocalizedString("Feature", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let deleteFilesText = NSLocalizedString("Deleting these files will remove them from cloud. You won't be able to access them once deleted", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteAlbums = NSLocalizedString("Deleting this album will remove the files from lifebox. You won't be able to access them once deleted. Are you sure you want to delete?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let moveToTrashAlbums = NSLocalizedString("move_to_trash_albums_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let moveToTrashAlbumsSuccess = NSLocalizedString("move_to_trash_albums_success_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let removeAlbums = NSLocalizedString("Deleting this album will not remove the files from lifebox. You can access these files from Photos tab. Are you sure you want to delete?", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let removeAlbumsSuccess = NSLocalizedString("remove_albums_success_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let removeFromAlbum = NSLocalizedString("This file will be removed only from your album. You can access this file from Photos tab", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let locationServiceDisable = NSLocalizedString("Location services are disabled in your device settings. To use background sync feature of lifebox, you need to enable location services under \"Settings - Privacy - Location Services\" menu.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        
    static let loginEnterGSM = NSLocalizedString("Please enter your GSM number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginAddGSM = NSLocalizedString("Add GSM Number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginGSMNumber = NSLocalizedString("GSM number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let syncFourGbVideo = NSLocalizedString("The videos larger than 4GB can not be uploaded to lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let syncZeroBytes = NSLocalizedString("Can't upload. File size is 0.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let syncNotEnoughMemory = NSLocalizedString("You have not enough memory in your device", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let inProgressPurchase = NSLocalizedString("The purchase in progress", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Navigation bar img names
    
    static let moreBtnImgName = "more"
    static let cogBtnImgName = "cog"
    static let searchBtnImgName = "search"
    static let deleteBtnImgName = "DeleteShareButton"
    static let giftButtonName = "campaignButton"
    
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
    static let accessibilityGift = NSLocalizedString("AccessibilityGiftButton", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let accessibilityHome = NSLocalizedString("Home", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityPhotosVideos = NSLocalizedString("Photos and Videos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityMusic = NSLocalizedString("Music", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessibilityDocuments = NSLocalizedString("Documents", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    
    static let photos = NSLocalizedString("photos", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let approve = NSLocalizedString("Approve", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infomationEmptyEmail = NSLocalizedString("infomationEmptyEmail", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    // MARK: - Quota PopUps
    static let fullQuotaSmallPopUpTitle = NSLocalizedString("LifeboxSmallPopUpTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaSmallPopUpSubTitle = NSLocalizedString("LifeboxSmallPopUpSubTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaSmallPopUpCheckBoxText = NSLocalizedString("LifeboxSmallPopUpCheckBoxTex", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaSmallPopUpFistButtonTitle = NSLocalizedString("LifeboxSmallPopUpFirstButtonText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaSmallPopUpSecondButtonTitle = NSLocalizedString("LifeboxSmallPopUpSecondButtonText", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let lifeboxLargePopUpTitle100 = NSLocalizedString("LifeboxLargePopUpTitle100", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpTitleBetween80And99 = NSLocalizedString("LifeboxLargePopUpTitleBetween80And99", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpSubTitleBeetween80And99 = NSLocalizedString("LifeboxLargePopUpSubTitleBeetween80And99", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpSubTitle100Freemium = NSLocalizedString("LifeboxLargePopUpSubTitle100Freemium", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpSubTitle100Premium = NSLocalizedString("LifeboxLargePopUpSubTitle100Premium", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpExpandButtonTitle = NSLocalizedString("LifeboxLargePopUpExpandButtonTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpSkipButtonTitle = NSLocalizedString("LifeboxLargePopUpSkipButtonTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lifeboxLargePopUpDeleteFilesButtonTitle = NSLocalizedString("LifeboxLargePopUpDeleteFilesButtonTitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "") 
    static let periodContactSyncFromSettingsTitle = NSLocalizedString("Lifebox can sync your contacts automatically.", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let errorLogin = NSLocalizedString("error_login", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploading = NSLocalizedString("uploading", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let settings = NSLocalizedString("Settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let sortby = NSLocalizedString("Sort By", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let invalidCaptcha = NSLocalizedString("This text doesn't match. Please try again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
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
    
    //MARK: - Premium
    static let contactSyncDepoErrorMessage = NSLocalizedString("dialog_contact_sync_vcf_file_upload_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactSyncDepoErrorTitle = NSLocalizedString("dialog_header_contact_sync_vcf_file_upload_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactSyncDepoErrorUpButtonText = NSLocalizedString("dialog_contact_sync_vcf_error_upper_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactSyncDepoErrorDownButtonText = NSLocalizedString("dialog_contact_sync_vcf_error_lower_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let standardUser = NSLocalizedString("Standard User", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let midUser = NSLocalizedString("mid_user", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
      
    //MARK: - PackageInfoView
    static let usage = NSLocalizedString("storage_usage_information", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myStorage = NSLocalizedString("my_storage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    //MARK: - InstapickUpgradePopup
    static let instapickUpgradePopupButton = NSLocalizedString("instapick_upgrade_popup_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

//    //MARK: - InstaPickPopUp
    static let instaPickDontShowThisAgain = NSLocalizedString("dont_show_this_again", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
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
    static let passwordInResentHistory = NSLocalizedString("password_in_resent_history", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uppercaseMissInPassword = NSLocalizedString("uppercase_miss_in_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let lowercaseMissInPassword = NSLocalizedString("lowercase_miss_in_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let numberMissInPassword = NSLocalizedString("number_miss_in_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passwordFieldIsEmpty = NSLocalizedString("password_field_is_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passwordLengthIsBelowLimit = NSLocalizedString("password_length_below_limit", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passwordLengthExceeded = NSLocalizedString("password_length_exceede", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passwordSequentialCaharacters = NSLocalizedString("password_sequential_caharacters", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let passwordSameCaharacters = NSLocalizedString("password_same_caharacters", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
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
    
    static let onLoginSupportFormSubject1 = NSLocalizedString("support_form_subject_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject2 = NSLocalizedString("support_form_subject_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject3 = NSLocalizedString("support_form_subject_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject4 = NSLocalizedString("support_form_subject_4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject5 = NSLocalizedString("support_form_subject_5", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject6 = NSLocalizedString("support_form_subject_6", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject7 = NSLocalizedString("support_form_subject_7", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let onLoginSupportFormSubject1InfoLabel = NSLocalizedString("support_form_subject_1_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject2InfoLabel = NSLocalizedString("support_form_subject_2_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject3InfoLabel = NSLocalizedString("support_form_subject_3_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject4InfoLabel = NSLocalizedString("support_form_subject_4_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject5InfoLabel = NSLocalizedString("support_form_subject_5_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject6InfoLabel = NSLocalizedString("support_form_subject_6_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject7InfoLabel = NSLocalizedString("support_form_subject_7_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let onLoginSupportFormSubject1DetailedInfoText = NSLocalizedString("support_form_subject_1_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject2DetailedInfoText = NSLocalizedString("support_form_subject_2_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject3DetailedInfoText = NSLocalizedString("support_form_subject_3_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject4DetailedInfoText = NSLocalizedString("support_form_subject_4_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject5DetailedInfoText = NSLocalizedString("support_form_subject_5_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject6DetailedInfoText = NSLocalizedString("support_form_subject_6_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onLoginSupportFormSubject7DetailedInfoText = NSLocalizedString("support_form_subject_7_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let onSignupSupportFormSubject1 = NSLocalizedString("support_form_signup_subject_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onSignupSupportFormSubject2 = NSLocalizedString("support_form_signup_subject_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onSignupSupportFormSubject3 = NSLocalizedString("support_form_signup_subject_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let onSignupSupportFormSubject1InfoLabel = NSLocalizedString("signup_support_form_subject_1_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onSignupSupportFormSubject2InfoLabel = NSLocalizedString("signup_support_form_subject_2_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onSignupSupportFormSubject3InfoLabel = NSLocalizedString("signup_support_form_subject_3_detailed_info_label", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let onSignupSupportFormSubject1DetailedInfoText = NSLocalizedString("signup_support_form_subject_1_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onSignupSupportFormSubject2DetailedInfoText = NSLocalizedString("signup_support_form_subject_2_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let onSignupSupportFormSubject3DetailedInfoText = NSLocalizedString("signup_support_form_subject_3_detailed_info_fulltext", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
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
    static let signupFAQInfo = NSLocalizedString("signup_faq_info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginFAQInfo = NSLocalizedString("login_faq_info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let missingInformation = NSLocalizedString("missing_information", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let pleaseEnterYourMissingAccountInformation = NSLocalizedString("please_enter_your_missing_account_information", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginEmailOrPhonePlaceholder = NSLocalizedString("login_email_or_phone_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPasswordPlaceholder = NSLocalizedString("login_password_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let loginEmailOrPhoneError = NSLocalizedString("login_email_or_phone_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPasswordError = NSLocalizedString("login_password_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let captchaIsEmpty = NSLocalizedString("captcha_is_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginUsernameNotValid = NSLocalizedString("login_username_not_valid", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let myProfileFAQ = NSLocalizedString("frequently_asked_questions", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
       
    static let downloadLimitAllert = NSLocalizedString("selected_items_limit_download", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteLimitAllert = NSLocalizedString("selected_items_limit_delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let hideLimitAllert = NSLocalizedString("selected_items_limit_hide", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
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
    static let credUpdateCheckTitle = NSLocalizedString("cred_update_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let credUpdateCheckCompletionMessage = NSLocalizedString("cred_completion_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

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
    static let accountStatusTitle = NSLocalizedString("account_status_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accountStatusMessage = NSLocalizedString("account_status_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")


    static let updateAddressError = NSLocalizedString("update_address_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let profileDetailAddressTitle = NSLocalizedString("profile_detail_address_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let profileDetailAddressSubtitle = NSLocalizedString("profile_detail_address_subtitle", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let profileDetailAddressPlaceholder = NSLocalizedString("profile_detail_address_placeholder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let profileDetailErrorContactCallCenter = NSLocalizedString("profile_detail_error_contact_call_center", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let instagramNotConnected = NSLocalizedString("temporary_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let hideSinglePhotoCompletionAlertMessage = NSLocalizedString("hide_single_photo_completion_alert_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    //MARK: -Carousel Pager Header
    static let carouselViewFirstPageText = NSLocalizedString("carousel_view_first_page_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let carouselViewFirstPageTitle = NSLocalizedString("carousel_view_first_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let carouselViewSecondPageText = NSLocalizedString("carousel_view_second_page_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let carouselViewSecondPageTitle = NSLocalizedString("carousel_view_second_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let carouselViewThirdPageText = NSLocalizedString("carousel_view_third_page_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let carouselViewThirdPageTitle = NSLocalizedString("carousel_view_third_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let hiddenBinEmpty = NSLocalizedString("hidden_bin_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
   
    static let deleteFromHiddenBinPopupSuccessTitle = NSLocalizedString("delete_from_hidden_bin_popup_success_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteFromHiddenBinPopupSuccessText = NSLocalizedString("delete_from_hidden_bin_popup_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let deleteConfirmationPopupText = NSLocalizedString("delete_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deletePopupSuccessText = NSLocalizedString("delete_popup_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let restoreConfirmationPopupText = NSLocalizedString("restore_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let restorePopupSuccessText = NSLocalizedString("restore_popup_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deletePopupText = NSLocalizedString("delete_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let moveToTrashHiddenAlbumsConfirmationPopupText = NSLocalizedString("move_to_trash_hidden_albums_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let deleteConfirmationPopupTitle = NSLocalizedString("delete_confirmation_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteItemsConfirmationPopupText = NSLocalizedString("delete_items_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteAlbumsConfirmationPopupText = NSLocalizedString("delete_albums_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteFoldersConfirmationPopupText = NSLocalizedString("delete_folders_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let restoreConfirmationPopupTitle = NSLocalizedString("restore_confirmation_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let restoreItemsConfirmationPopupText = NSLocalizedString("restore_items_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let restoreAlbumsConfirmationPopupText = NSLocalizedString("restore_albums_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let restoreFoldersConfirmationPopupText = NSLocalizedString("restore_folders_confirmation_popup_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let trashBinAlbumSliderTitle = NSLocalizedString("trash_bin_album_slider_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let trashBinAlbumSliderEmpty = NSLocalizedString("trash_bin_album_slider_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let trashBinEmpty = NSLocalizedString("trash_bin_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let trashBinDeleteAllConfirmTitle = NSLocalizedString("confirm_dialog_header_empty_trashbin", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let trashBinDeleteAllConfirmText = NSLocalizedString("confirm_empty_trashbin", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let trashBinDeleteAllConfirmOkButton = NSLocalizedString("confirm_empty_trashbin_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let trashBinDeleteAllComplete = NSLocalizedString("success_empty_trashbin", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let turkcellUpdateRequiredTitle = NSLocalizedString("turkcell_updater_update_required_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let turkcellUpdateRequiredMessage = NSLocalizedString("turkcell_updater_update_required_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let moveToTrashItemsSuccessText = NSLocalizedString("move_to_trash_items_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let moveToTrashAlbumsSuccessText = NSLocalizedString("move_to_trash_albums_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let moveToTrashFoldersSuccessText = NSLocalizedString("move_to_trash_folders_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        
    static let deleteItemsSuccessText = NSLocalizedString("delete_items_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteAlbumsSuccessText = NSLocalizedString("delete_albums_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteFoldersSuccessText = NSLocalizedString("delete_folders_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let restoreItemsSuccessText = NSLocalizedString("restore_items_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let restoreAlbumsSuccessText = NSLocalizedString("restore_albums_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let restoreFoldersSuccessText = NSLocalizedString("restore_folders_success_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    //MARK: - FullQuotaWarningPopUp
    static let fullQuotaWarningPopUpTitle = NSLocalizedString("full_quota_warning_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let fullQuotaWarningPopUpDescription = NSLocalizedString("full_quota_warning_popup_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let expandMyStorage = NSLocalizedString("expand_my_storage", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteFiles = NSLocalizedString("delete_files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let weRecommend = NSLocalizedString("we_recommend", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let showMore = NSLocalizedString("show_more", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let seeFeatures = NSLocalizedString("see_features", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let showLess = NSLocalizedString("show_less", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let faceRecognitionPackageDescription = NSLocalizedString("face_recognition_package_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteDublicatePackageDescription = NSLocalizedString("delete_dublicate_package_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let premiumUserPackageDescription = NSLocalizedString("premium_user_package_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let middleUserPackageDescription = NSLocalizedString("middle_user_package_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let originalCopyPackageDescription = NSLocalizedString("original_сopy_package_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let bundlePackageAddonType = NSLocalizedString("bundle_package_addon_type", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featuresOnlyAddonType = NSLocalizedString("features_only_package_addon_type", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let middleFeaturesOnlyAddonType = NSLocalizedString("features_middle_only_package_addon_type", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureHighQualityPicture = NSLocalizedString("feature_high_quality_picture", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureImageRecognition = NSLocalizedString("feature_image_recognition", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featurePhotopick = NSLocalizedString("feature_photopick", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureDeleteDuplicationContacts = NSLocalizedString("feature_delete_duplicate_contacts", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureStandardFeatures = NSLocalizedString("feature_standard_features", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let storageOnlyPackageAddonType = NSLocalizedString("storage_only_package_addon_type", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featurePackageName = NSLocalizedString("feature_package_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let middleFeaturePackageName = NSLocalizedString("middle_feature_package_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
       
    static let featureStorageOnlyAdditional1 = NSLocalizedString("feature_storage_only_additional_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let featureStorageOnlyAdditional2 = NSLocalizedString("feature_storage_only_additional_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let snackbarOk = NSLocalizedString("snackbar_ok", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarTrashBin = NSLocalizedString("snackbar_trash_bin", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarHiddenBin = NSLocalizedString("snackbar_hidden_bin", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let snackbarMessageAddedToFavorites = NSLocalizedString("added_to_favorites_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageRemovedFromFavorites = NSLocalizedString("removed_from_favorites", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageAddedToAlbum = NSLocalizedString("added_to_album", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageDownloadedFilesFormat = NSLocalizedString("downloaded_files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageEditSaved = NSLocalizedString("edit_saved", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageRemovedFromAlbum = NSLocalizedString("removed_from_album_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageFilesMoved = NSLocalizedString("files_moved", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageResetPasscodeSuccess = NSLocalizedString("success_remove_passcode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageAddedToFavoritesFromLifeBox = NSLocalizedString("added_to_favorites_from_lifebox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageImportFromInstagramStarted = NSLocalizedString("import_from_instagram_started", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageImportFromFBStarted = NSLocalizedString("import_from_facebook_started", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageHashTagsCopied = NSLocalizedString("instapick_hashtags_copied", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let snackbarMessageCreateStoryLimit = NSLocalizedString("create_story_selection_limit", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let contactSyncErrorQuotaRestore = NSLocalizedString("contact_phase2_error_quota_restore", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let contactSyncErrorQuotaBackup = NSLocalizedString("contact_phase2_error_quota_backup", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let warningPopupContactPermissionsTitle = NSLocalizedString("contact_phase2_warning_popup_contact_permissions_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let warningPopupContactPermissionsMessage = NSLocalizedString("contact_phase2_warning_popup_contact_permissions_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let warningPopupContactPermissionsStorageButton = NSLocalizedString("contact_phase2_warning_popup_contact_permissions_storage_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let warningPopupContactPermissionsDeleteButton = NSLocalizedString("contact_phase2_warning_popup_contact_permissions_delete_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let warningPopupStorageLimitTitle = NSLocalizedString("contact_phase2_warning_popup_storage_limit_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let warningPopupStorageLimitMessage = NSLocalizedString("contact_phase2_warning_popup_storage_limit_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let warningPopupStorageLimitSettingsButton = NSLocalizedString("contact_phase2_warning_popup_storage_limit_settings_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let galleryFilterAll = NSLocalizedString("gallery_filter_all", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let galleryFilterSynced = NSLocalizedString("gallery_filter_synced", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let galleryFilterUnsynced = NSLocalizedString("gallery_filter_unsynced", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let galleryFilterActionSheetAll = NSLocalizedString("gallery_filter_action_sheet_all", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let galleryFilterActionSheetSynced  = NSLocalizedString("gallery_filter_action_sheet_synced", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let galleryFilterActionSheetUnsynced = NSLocalizedString("gallery_filter_action_sheet_unsynced", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let privateShareStartPageName = NSLocalizedString("private_share_start_page_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageCloseButton = NSLocalizedString("private_share_start_page_cancel_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageShareButton = NSLocalizedString("private_share_start_page_share_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPagePeopleSelectionTitle = NSLocalizedString("private_share_start_page_people_selection_section_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageEnterUserPlaceholder = NSLocalizedString("private_share_start_page_enter_user_field", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageSuggestionsTitle = NSLocalizedString("private_share_start_page_suggestions_section", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")    
    static let privateShareStartPageSharedWithTitle = NSLocalizedString("private_share_start_page_shared_with_section", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageAddMessageTitle = NSLocalizedString("private_share_start_page_add_message_section_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageMessagePlaceholder = NSLocalizedString("private_share_start_page_add_messge_field", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageDurationTitle = NSLocalizedString("private_share_start_page_share_duration_section_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageDurationNo = NSLocalizedString("private_share_start_page_share_duration_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageDurationHour = NSLocalizedString("private_share_start_page_share_duration_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageDurationDay = NSLocalizedString("private_share_start_page_share_duration_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageDurationWeek = NSLocalizedString("private_share_start_page_share_duration_4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageDurationMonth = NSLocalizedString("private_share_start_page_share_duration_5", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageDurationYear = NSLocalizedString("private_share_start_page_share_duration_6", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageEditorButton = NSLocalizedString("private_share_start_page_role_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageViewerButton = NSLocalizedString("private_share_start_page_role_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareDetailsPageName = NSLocalizedString("private_share_details_page_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareSharedByMeTab = NSLocalizedString("private_share_shared_by_me_tab", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareSharedWithMeTab = NSLocalizedString("private_share_shared_with_me_tab", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageSuccess = NSLocalizedString("private_share_start_page_share_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareStartPageClosePopupMessage = NSLocalizedString("private_share_cancel_confirm", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let privateShareRoleSelectionTitle = NSLocalizedString("private_share_role_selection_page_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareRoleSelectionEditor = NSLocalizedString("private_share_role_selection_role_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareRoleSelectionViewer = NSLocalizedString("private_share_role_selection_role_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareValidationFailPopUpText = NSLocalizedString("private_share_msisdn_format", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let privateShareInfoMenuSectionTitle = NSLocalizedString("private_share_info_section_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareInfoMenuNumberOfPeople = NSLocalizedString("private_share_info_number_of_people", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareInfoMenuOwner = NSLocalizedString("private_share_info_role_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareInfoMenuEditor = NSLocalizedString("private_share_info_role_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareInfoMenuViewer = NSLocalizedString("private_share_info_role_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareInfoMenuVarying = NSLocalizedString("private_share_info_role_4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharePhoneValidationFailPopUpText = NSLocalizedString("private_share_msisdn_format", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareEmailValidationFailPopUpText = NSLocalizedString("private_share_email_format", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareNonTurkishMsisdnPopUpText = NSLocalizedString("private_share_non_turkish_msisdn_warning", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharedWithMeEmptyText = NSLocalizedString("private_share_shared_with_me_empty_page", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharedByMeEmptyText = NSLocalizedString("private_share_shared_by_me_empty_page", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharedInnerFolderEmptyText = NSLocalizedString("private_share_inner_folder_empty_page", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareSharedAreaEmptyText = NSLocalizedString("private_share_shared_area_empty_page", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let privateSharedEndSharingActionSuccess = NSLocalizedString("private_share_end_sharing_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharedEndSharingActionConfirmation = NSLocalizedString("private_share_end_sharing_confirm", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharedEndSharingActionTitle = NSLocalizedString("private_share_end_sharing_action_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let privateSharedLeaveSharingActionSuccess = NSLocalizedString("private_share_leave_sharing_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharedLeaveSharingActionConfirmation = NSLocalizedString("private_leave_sharing_confirm", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharedLeaveSharingActionTitle = NSLocalizedString("private_share_leave_sharing_action_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let privateShareWhoHasAccessTitle = NSLocalizedString("private_share_who_has_access_page_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareWhoHasAccessOwner = NSLocalizedString("private_share_who_has_access_role_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareWhoHasAccessEditor = NSLocalizedString("private_share_who_has_access_role_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareWhoHasAccessViewer = NSLocalizedString("private_share_who_has_access_role_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareWhoHasAccessVarying = NSLocalizedString("private_share_who_has_access_role_4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareWhoHasAccessEndShare = NSLocalizedString("private_share_who_has_access_end_share", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareWhoHasAccessPopupMessage = NSLocalizedString("private_share_end_sharing_confirm", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareEndShareSuccess = NSLocalizedString("private_share_end_sharing_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAllFilesSharedWithMe = NSLocalizedString("private_share_all_files_section_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAllFilesSeeAll = NSLocalizedString("private_share_all_files_section_1_see_all", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAllFilesMyFiles = NSLocalizedString("private_share_all_files_section_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let privateShareAccessEditor = NSLocalizedString("private_share_access_role_1", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessViewer = NSLocalizedString("private_share_access_role_2", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessRemove = NSLocalizedString("private_share_access_role_3", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessVarying = NSLocalizedString("private_share_access_role_4", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessTitle = NSLocalizedString("private_share_access_page_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessFromFolder = NSLocalizedString("private_share_access_from_folder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessExpiresDate = NSLocalizedString("private_share_expire_date", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessRoleChangeSuccess = NSLocalizedString("private_share_access_role_change_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessDeleteConfirmPopupMessage = NSLocalizedString("private_share_access_remove_confirmation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareAccessDeleteUserSuccess = NSLocalizedString("private_share_info_access_role_remove", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharePlusButtonNoAction = NSLocalizedString("private_share_plus_button_no_action", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharePreviewNotReady = NSLocalizedString("private_share_preview_not_ready", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareMoveToTrashSharedWithMeMessage = NSLocalizedString("private_share_confirm_trash_items", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareMaxNumberOfUsersMessageFormat = NSLocalizedString("private_share_start_max_number_of_users", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareMessageLimit = NSLocalizedString("private_share_long_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateSharePhoneOrMailLimit = NSLocalizedString("private_share_long_emailmsisdn", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let privateShareNumberOfItemsLimit = NSLocalizedString("private_share_max_number_of_item_limit_exceeded", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let unauthorizedUploadOperation = NSLocalizedString("business_app_upload_403", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
}

extension TextConstants {
    static let tabBarItemMyDisk = NSLocalizedString("business_app_tabbar_mydisk", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarItemSharedFiles = NSLocalizedString("business_app_tabbar_mysharings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarItemSharedArea = NSLocalizedString("business_app_tabbar_sharedarea", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let tabBarItemSettings = NSLocalizedString("tabbar_item_settings", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let actionSelect = NSLocalizedString("business_app_select_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionDownload = NSLocalizedString("business_app_download_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionDelete = NSLocalizedString("business_app_delete_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionRename = NSLocalizedString("business_app_rename_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionSharePrivately = NSLocalizedString("business_app_share_privately_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionShareCopy = NSLocalizedString("business_app_share_copy_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionStopSharing = NSLocalizedString("business_app_stop_sharing_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionLeaveSharing = NSLocalizedString("business_app_leave_sharing_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let actionInfo = NSLocalizedString("business_app_info_option", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let downloadSuccess = NSLocalizedString("business_app_download_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteSuccess = NSLocalizedString("business_app_delete_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let renameSuccess = NSLocalizedString("business_app_rename_sucess", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sharePrivatelySuccess = NSLocalizedString("business_app_share_privately_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let stopSharingSuccess = NSLocalizedString("business_app_stop_sharing_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let leaveSharingSuccess = NSLocalizedString("business_app_leave_sharing_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
    static let deleteConfirmationTitle = NSLocalizedString("business_app_delete_confirm_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let deleteConfirmationMessage = NSLocalizedString("business_app_delete_confirm_popup_detail", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let delete = NSLocalizedString("Delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    // MARK: - Camera alert
    static let galeryPermissionNotProvidedTitle = NSLocalizedString("business_app_gallery_permission_not_provided_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let galeryPermissionNotProvidedDescription = NSLocalizedString("business_app_gallery_permission_not_provided_popup_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let galeryPermissionNotProvidedAcceptButton = NSLocalizedString("business_app_gallery_permission_not_provided_popup_settings_accept", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let galeryPermissionNotProvidedRejectButton = NSLocalizedString("business_app_gallery_permission_not_provided_popup_settings_reject", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
}

// MARK: - Login page
extension TextConstants {
    static let loginPageFLButtonExplanation = NSLocalizedString("business_app_login_FL_explanation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageLoginButtonExplanation = NSLocalizedString("business_app_login_pwd_login_button_explanation", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageLoginButtonTitle = NSLocalizedString("business_app_login_pwd_login_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageForgetPasswordCloseButtonTitle = NSLocalizedString("business_app_login_forget_password_page_close_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageForgetPasswordDescriptionText = NSLocalizedString("business_app_login_forget_password_page_description", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageForgetPasswordButtonTitle = NSLocalizedString("business_app_login_forget_password_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageForgetPasswordPageTitle = NSLocalizedString("business_app_login_forget_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageRememberMeButtonTitle = NSLocalizedString("business_app_login_rememberme_checkbox", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPagePasswordFieldPlaceholder = NSLocalizedString("business_app_login_password_box_inside", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageEmailFieldPlaceholder = NSLocalizedString("business_app_login_email_box_inside", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageMainTitle = NSLocalizedString("business_app_login_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let captchaViewTextfieldPlaceholder = NSLocalizedString("business_app_login_captcha_box_inside", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageEmptyLoginFieldError = NSLocalizedString("business_app_login_email_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageInvalidLoginFieldError = NSLocalizedString("business_app_login_email_not_validated", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageEmptyPasswordFieldError = NSLocalizedString("business_app_login_password_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageEmptyCaptchaFieldError = NSLocalizedString("business_app_login_captcha_empty", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageInvalidCaptchaFieldError = NSLocalizedString("business_app_login_captcha_not_match", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageAuthenticationError30Error = NSLocalizedString("business_app_login_pwd_error_code_30", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageShowPassword = NSLocalizedString("business_app_login_show_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let loginPageHidePassword = NSLocalizedString("business_app_login_hide_password", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    
    struct PrivateShare {
        static let close_page = NSLocalizedString("business_app_private_share_close_page", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let close_page_no = NSLocalizedString("business_app_private_share_close_page_no", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let close_page_yes = NSLocalizedString("business_app_private_share_close_page_yes", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        
        static let page_title = NSLocalizedString("business_app_private_share_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let box_name = NSLocalizedString("business_app_private_share_box_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let box_inside = NSLocalizedString("business_app_private_share_box_inside", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let role_editor = NSLocalizedString("business_app_private_share_role_editor", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let role_viewer = NSLocalizedString("business_app_private_share_role_viewer", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let add_message = NSLocalizedString("business_app_private_share_add_message", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let add_message_inside = NSLocalizedString("business_app_private_share_add_message_inside", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let share_duration = NSLocalizedString("business_app_private_share_share_duration", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let share_duration_no_duration = NSLocalizedString("business_app_private_share_share_duration_no_duration", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let share_duration_1_hour = NSLocalizedString("business_app_private_share_share_duration_1_hour", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let share_duration_1_day = NSLocalizedString("business_app_private_share_share_duration_1_day", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let share_duration_1_week = NSLocalizedString("business_app_private_share_share_duration_1_week", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let share_duration_1_month = NSLocalizedString("business_app_private_share_share_duration_1_month", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let share_duration_1_year = NSLocalizedString("business_app_private_share_share_duration_1_year", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let start = NSLocalizedString("business_app_private_share_start", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let success = NSLocalizedString("business_app_private_share_success", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

        static let fail_errorcode_4115 = NSLocalizedString("business_app_private_share_fail_errorcode_4115", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let fail_errorcode_4116 = NSLocalizedString("business_app_private_share_fail_errorcode_4116", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let fail_errorcode_4118 = NSLocalizedString("business_app_private_share_fail_errorcode_4118", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let fail_errorcode_5101 = NSLocalizedString("business_app_private_share_fail_errorcode_5101", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        static let fail_errorcode_5102 = NSLocalizedString("business_app_private_share_fail_errorcode_5102", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
        
        static let shared_with_section_name = NSLocalizedString("business_app_private_share_shared_with_section_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    }
    
}

// MARK: - Info
extension TextConstants {
    static let infoPageTitleForFile = NSLocalizedString("business_app_info_page_title_for_files", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageTitleForFolder = NSLocalizedString("business_app_info_page_title_for_folders", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageItemName = NSLocalizedString("business_app_info_page_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageItemSize = NSLocalizedString("business_app_info_page_size", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageItemItems = NSLocalizedString("business_app_info_page_item", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageItemCreationDate = NSLocalizedString("business_app_info_page_creation_date", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageItemModifiedDate = NSLocalizedString("business_app_info_page_modified_date", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageItemSharingInfo = NSLocalizedString("business_app_info_page_sharing_info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageItemSharedWithNumberOfPerson = NSLocalizedString("business_app_info_page_shared_with", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageRoleOwner = NSLocalizedString("business_app_info_page_role_owner", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageRoleEditor = NSLocalizedString("business_app_info_page_role_editor", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageRoleViewer = NSLocalizedString("business_app_info_page_role_viewer", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let infoPageRoleVaries = NSLocalizedString("business_app_info_page_role_varies", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
}

// MARK: - SharedContacts
extension TextConstants {
    static let uploadProgressHederTitle = NSLocalizedString("business_app_upload_bar_uploading_text", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sharedContactsPageTitle = NSLocalizedString("business_app_whohasaccess_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sharedContactsPageRoleOwner = NSLocalizedString("business_app_whohasaccess_role_owner", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sharedContactsPageRoleEditor = NSLocalizedString("business_app_whohasaccess_role_editor", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sharedContactsPageRoleViewer = NSLocalizedString("business_app_whohasaccess_role_viewer", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let sharedContactsPageRoleVaries = NSLocalizedString("business_app_whohasaccess_role_varies", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
}

extension TextConstants {
    static let a2FAFirstPageTitle = NSLocalizedString("business_app_2FA_first_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FAFirstPageDescription = NSLocalizedString("business_app_2FA_first_page_description_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FAFirstPageDescriptionDetail = NSLocalizedString("business_app_2FA_first_page_description_detail", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FAFirstPageSendSecurityCode = NSLocalizedString("business_app_2FA_first_page_sendsecuritycode", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FAFirstPageSendSecurityCodeToPhone = NSLocalizedString("business_app_2FA_first_page_sendsecuritycode_to_phone", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FAFirstPageSendSecurityCodeToEmail = NSLocalizedString("business_app_2FA_first_page_sendsecuritycode_to_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FAFirstPageButtonSend = NSLocalizedString("business_app_2FA_first_page_send_button_name", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")

    static let a2FASecondPageTitle = NSLocalizedString("business_app_2FA_second_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FASecondPageVerifyNumber = NSLocalizedString("business_app_2FA_second_page_verify_number", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FASecondPageVerifyEmail = NSLocalizedString("business_app_2FA_second_page_verify_email", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FASecondPageInfo = NSLocalizedString("business_app_2FA_second_page_info", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let a2FASecondPageSecurityCode = NSLocalizedString("business_app_2FA_second_page_code", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
}

// MARK: - Access page
extension TextConstants {
    static let accessPageTitle = NSLocalizedString("business_app_access_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessPageRoleEditor = NSLocalizedString("business_app_access_page_role_editor", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessPageRoleViewer = NSLocalizedString("business_app_access_page_role_viewer", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessPageRoleVaries = NSLocalizedString("business_app_access_page_role_varies", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessPageDueDateTo = NSLocalizedString("business_app_access_page_expire_date", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessPageFromFolder = NSLocalizedString("business_app_access_page_from_folder", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessPageRemoveRole = NSLocalizedString("business_app_access_page_role_change_remove", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessPageRoleUpdated = NSLocalizedString("business_app_role_update", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let accessPageRoleDeleted = NSLocalizedString("business_app_role_delete", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
}

extension TextConstants {
    static let uploadSelectPageTitle = NSLocalizedString("business_app_upload_select_page_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let uploadSelectButtonTitle = NSLocalizedString("business_app_upload_select_page_upload_button", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    
}

// MARK: - FastLogin
extension TextConstants {
    static let flLoginErrorPopupTitle = NSLocalizedString("business_app_FL_error_popup_title", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let flLoginErrorTimeout = NSLocalizedString("business_app_FL_error_session_timeout", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let flLoginErorNotLoginSDK = NSLocalizedString("business_app_FL_error_not_logintologinSDK", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let flLoginElseError = NSLocalizedString("business_app_FL_else_error", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let flLoginUserNotInPool = NSLocalizedString("business_app_fast_login_pool_user_popup", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
    static let flLoginAuthFailure = NSLocalizedString("business_app_fast_login_authentication_fail_popup", tableName: "OurLocalizable", bundle: .main, value: "", comment: "")
}
