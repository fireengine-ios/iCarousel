//
//  Constants.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

struct TextConstants {
    static let itroViewGoToRegisterButtonText = "Start using Lifebox now!"
    static let introViewGoToLoginButtonText = "I have an account, let me log in"
    
    static let registrationCellTitleEmail = NSLocalizedString("EmailTitle", comment: "")
    static let registrationCellTitleGSMNumber = "GSM Number"
    static let registrationCellTitlePassword = "Password"//NSLocalizedString("PasswordPlaceholder", comment: "")
    static let registrationCellTitleReEnterPassword = "Re-Enter Password"
    static let registrationCellPlaceholderEmail = " You have to fill in your mail"
    static let notCorrectEmail = "Please enter valid Email"
    static let registrationCellPlaceholderPassword = " You have to fill in a password"
    static let registrationCellPlaceholderReFillPassword = " You have to fill in a password"
    static let registrationTitleText = "Register to lifebox and get a 5 GB of storage for free!"
    static let registrationNextButtonText = "Next"
    static let registrationResendButtonText = "Resend"
    static let optInNavigarionTitle = "Verify Your Purchase"
    static let phoneVereficationMainTitleText = "Verify Your Phone Number"
    static let mailVereficationMainTitleText = "Verify Your Email"
    static let phoneVereficationInfoTitleText = "Enter the verification code"
    static let phoneVereficationNonValidCodeErrorText = "Verification code is invalid. \n Please try again."
    static let phoneVereficationResendRequestFailedErrorText = "Request failed \n Please try again"
    static let loginScreenCredentialsError = "Login denied. Please check your credentials."
    static let loginScreenNoLoginError = "Please check the GSM number"
    static let loginScreenNoPasswordError = "Please enter your password"
    static let loginScreenNoInternetError = "Please check your internet connection."
    static let registrationPasswordError = "Please set a password including nonconsecutive letters and numbers, minimum 6 maximum 16 characters."
    static let hourBlockLoginError = "You have performed too many attempts. Please try again 1 hour later."
    static let registrationMailError = "Please check the e-mail address."
    static let registrationPasswordNotMatchError = "Password fields do not match."
    
    //MARK: - Registration Error Messages
    static let invalidMailErrorText = NSLocalizedString("EmailFormatErrorMessage", comment: "")
    static let invalidPhoneNumberText = NSLocalizedString("MsisdnFormatErrorMessage", comment: "")
    static let invalidPasswordText = NSLocalizedString("PassFormatErrorMessage", comment: "")
    static let invalidPasswordMatchText = NSLocalizedString("PassMismatchErrorMessage", comment: "")
    //MARK: -
    static let termsAndUsesTitile = "Sign Up"
    static let termsAndUsesApplyButtonText = "Accept  Terms"
    static let termsAndUseTextFormat = "<html><body text=\"#FFFFFF\" face=\"Bookman Old Style, Book Antiqua, Garamond\" size=\"5\">%@</body></html>"
    
    static let loginTitle = NSLocalizedString("Login", comment: "")
    static let loginTableTitle = "Register to lifebox and get a 5 GB of storage for free!"
    static let loginCantLoginButtonTitle = "I can't login"
    static let loginRememberMyCredential = "Remember my credentials"
    static let loginCellTitleEmail = "E-Mail or GSM Number"
    static let loginCellTitlePassword = "Password"//NSLocalizedString("PasswordPlaceholder", comment: "")
    static let loginCellEmailPlaceholder = ""
    static let loginCellPasswordPlaceholder = ""
    
    static let autoSyncNavigationTitle = "Auto Sync"
    static let autoSyncTitle = "Lifebox can sync your files automatically. Would you like to have this feature right now?"
    static let autoSyncCellWiFiTile = NSLocalizedString("Wifi", comment: "")
    static let autoSyncCellWiFiSubTitle = "When syncing via Wi-Fi, your photos and videos are uploaded by default."
    static let autoSyncCellMobileDataTitle = "Mobile Data"
    static let autoSyncCellMobileDataSubTitle = "Select the items to sync with mobile data."
    static let autoSyncCellPhotos = NSLocalizedString("Photos&Videos", comment: "")
    static let autoSyncCellVideos = "Videos"
    static let autoSyncStartUsingLifebox = "Let’s start using Lifebox"
    static let autoSyncskipForNowButton = "Skip for now"
    static let autoSyncAlertTitle = "Skip setting Auto-Sync?"
    static let autoSyncAlertText = "You’re skipping auto-sync setting turned off. You can activate this later in preferences."
    static let autoSyncAlertYes = "Skip Auto-Sync"
    static let autoSyncAlertNo = "Cancel"
    static let autoSyncSaveButton = "Save"
    
    static let registerTitle = "Sign Up"
    
    static let forgotPasswordTitle = "Forgot My Password"
    static let forgotPasswordSubTitle = "If you are already a Turkcell subscriber, you can retrieve your password by sending SMS to 2222"//"If you registered with your Turkcell Number you can just send SIFRE LIFEBOX to 2222 to recieve a new password or enter your mail below."
    static let forgotPasswordSendPassword = "Send password reset link"
    static let forgotPasswordCellTitle = NSLocalizedString("EmailTitle", comment: "")
    
    static let captchaPlaceholder = "Type the text"
    
    static let checkPhoneResendCodeButtonText = NSLocalizedString("ResendButton", comment: "")
    static let checkPhoneNextButtonText = "Next"
    
    static let checkPhoneAlertTitle = "Error"
    static let checkPhoneAlertFormedText = "Verification code is invalid. Please try again."
    
    static let serverResponceError = "Wrong type of answer"
    
    static let errorAlert = "Error"
    static let errorAlerTitleBackupAlreadyExist = "Overwrite backup?"
    static let errorAlertTextBackupAlreadyExist = "You have already a backup. Do you want to overwrite the existing one?"
    static let errorAlertNopeBtnBackupAlreadyExist = "Nope"
    static let errorAlertYesBtnBackupAlreadyExist = "Yes"
    
    //MARK: - mail update
    static let updaitMailMaybeLater = "Maybe later"
    
    // MARK: - DetailScreenError 
    
    static let theFileIsNotSupported = "The file isn't supported"
    static let warning = "Warning"
    
    // MARK: - Search
    
    static let search = "Search"
    
    static let noFilesFoundInSearch = "No results found for your query."
    
    // MARK: - Sync Contacts
    
    static let backUpMyContacts = "Back Up My Contacts"
    
    // MARK: - Authification Cells
    static let showPassword = "Show"
    static let hidePassword = "Hide"
    
    
    // MARK: - button navigation name
    static let chooseTitle = "Choose"
    static let nextTitle = "Next"
    static let backTitle = "Back"
    
    // MARK: - home buttons title
    static let homeButtonAllFiles = "All Files"
    static let homeButtonCreateStory = "Create a Story"
    static let homeButtonFavorites = "Favorites"
    static let homeButtonSyncContacts = "Sync Contacts"

    //MARK: - Home page subButtons Lables
    static let takePhoto = "Take Photo"
    static let upload = "Upload"
    static let createStory = "Create a Story"
    static let newFolder = "New Folder"
    static let createAlbum = "Create album"
    static let uploadFromLifebox = "Upload from lifebox"
    
    //MARK: - Navigation bar img names

    static let moreBtnImgName = "more"
    static let cogBtnImgName = "cog"
    static let searchBtnImgName = "search"
    static let deleteBtnImgName = "DeleteShareButton"
    
    // MARK: - Searchbar img name
    
    static let searchIcon = "searchIcon"
    
    //MARK: - Navigation bar buttons titles
    
    static let cancelSelectionButtonTitle = "Cancel"
    
    //MARK: - More actions Collection view section titles
    
    static let syncTypeTitle = "Sync Type"
    static let viewTypeTitle = "View Type"
    static let sortTypeTitle = "Sort Type"
    static let fileTypeTitle = "File Type"
    static let selectionTypeTitle = "Selection Type"
    
    
    static let viewTypeListTitle = "List"
    static let viewTypeGridTitle = "Grid"
    
    static let sortTypeAlphabeticAZTitle = "Name (A-Z)"
    static let sortTypeAlphabeticZATitle = "Name (Z-A)"
    static let sortTimeOldNewTitle = "Oldest"
    static let sortTimeNewOldTitle = "Newest"
    static let sortTimeSizeTitle = "Size"
    static let sortTimeSizeLargestTitle = "Largest"
    static let sortTimeSizeSmallestTitle = "Smallest"
    
    static let sortHeaderAlphabetic = "Alphabetically Sorted"
    static let sortHeaderTime = "Sorted by Time"
    static let sortHeaderSize = "Sorted by Size"
    
    static let fileTypeVideoTitle = "Video"
    static let fileTypeDocsTitle = "Docs"
    static let fileTypeMusicTitle = "Music"
    static let fileTypePhotosTitle = "Photos"
    static let fileTypeAlbumTitle = "Album"
    static let fileTypeFolderTitle = "Folder"
    
    static let selectedTypeSelectedTitle = "Select"
    static let selectedTypeSelectedAllTitle = "Select All"

    //MARK: - TOPBAR 
    
    static let topBarVideosFilter = "Videos"
    static let topBarPhotosFilter = "Photos"
    
    //MARK: Home page Welcome
    static let homeWelcomTextBig = "Welcome! Let’s get you started!"
    static let homeWelcomTextSmall = "You can start using your smart box with our suggestions. When you’re done you can swipe to dismiss the card -including this one too. Nothing is lost! You can access everything you see here through the app. "

    //MARK: - Camera alert
    static let cameraAccessAlertTitle = "Caution!"
    static let cameraAccessAlertText = "You can't take photos with disabled camera. Please turn the camera on in settings."
    static let cameraAccessAlertGoToSettings = "Settings"
    static let cameraAccessAlertNo = "No"
    //MARK: Home page wiFiSync view
    static let homeWiFiTitleText = "Waiting for Wi-Fi to auto sync 14 items"
    static let homeWiFiSyncButtonTitle = "Sync with Data Plan Now"
    
    //MARK: Home page completeProfile view
    static let homeCompleteProfileSubTitleBig = "Your profile looks empty"
    static let homeCompleteProfileSubTitleSmall = "You don’t have a profile picture, let’s upload a pretty photo!"
    static let homeCompleteProfileUploadButton = "Upload"
    static let homeCompleteProfileTakeAPhoto = "Take a Photo"
    
    
    //MARK: Home page like filter view
    static let homeLikeFilterTitle = "Did you like this filter?"
    static let homeLikeFilterSubTitle = "You can apply this filter and my more to your other picures as well"
    static let homeLikeFilterSavePhotoButton = "Save this photo"
    static let homeLikeFilterChangeFilterButton = "Change filter"
    
    //MARK: Home page expande storrage view
    static let homeExpandeStorageBigTitle = "Your storage is almost full!"
    static let homeExpandeStorageSmallTitle = "You are using %85 of your disk space! It’s a great time to expand your storage."
    static let homeExpandeStorageButton = "Expand My Storage"
    
    //MARK: Home page uploaded images view
    static let homeUploadedImagesTitle = "You’ve uploaded %@ two days ago!"
    static let homeUploadedPhotosTitle = "%d Photos"
    static let homeUploadedImagesViewAllStreams = "View All My Stream"
    static let homeUploadedImagesViewAllPictures = "View All Pictures"
    
    //MARK: Popup 
    static let ok = "Ok"
    
    //MARK: PhotosVideosView
    static let photosVideosViewNoPhotoTitleText = "You don’t have anything on your photo roll."
    static let photosVideosViewNoPhotoButtonText = "Start adding your photos"
    static let photosVideosViewHaveNoPermissionsAllertText = "Enable photo permissions in settings"
    
    //MARK:PhotoVideoDetail
    static let photosVideosDetailViewShareButton = "Share"
    static let photosVideosDetailViewInfoButton = "info"
    static let photosVideosDetailViewEditButton = "Edit"
    static let photosVideosDetailViewMoveButton = "Move"
    static let photosVideosDetailViewDeleteButton = "Delete"
    
    //MARK: AudioView
    static let audioViewNoAudioTitleText = "You don’t have any music on your Lifebox yet."
    static let audioViewNoAudioButtonText = "Start adding your music"

    //MARK: settings
    static let backPrintTitle = "Back to Lifebox"

    //MARK: settings
    
    static let settingsViewUploadPhotoLabel = "Upload Photo"
    static let settingsViewLeaveFeedback = "Leave feedback"
    
    static let settingsViewCellBeckup = "Back-up my contacts"
    static let settingsViewCellImportPhotos = "Import Photos"
    static let settingsViewCellAutoUpload = "Auto Sync"
    static let settingsViewCellActivityTimline = "My Activity Timeline"
    static let settingsViewCellRecentlyDeletedFiles = "Recently Deleted Files"
    static let settingsViewCellUsageInfo = "Usage Info and Packages"
    static let settingsViewCellPasscode = "Lifebox Touch ID and Passcode"
    static let settingsViewCellHelp = "Help & Support"
    static let settingsViewCellLogout = "Logout"
    static let settingsViewCellTurkcellPasscode = "Turkcell Passcode"
    static let settingsViewCellTurkcellAutoLogin = "Auto-login"
    static let settingsViewLogoutCheckMessage = "Are you sure you want to exit the application?"
    
    //MARK: Import photos
    static let importPhotos = "Import Photos"
    static let importFromDB = "Import From Dropbox"
    static let importFromFB = "Import From Facebook"
    static let importFromInstagram = "Import From Instagram"
    static let importFromCropy = "Import From Cropy"

    //MARK: userProfile
    static let userProfileNameAndSurNameSubTitle = "Name and Surname"
    static let userProfileEmailSubTitle = "E-Mail"
    static let userProfileGSMNumberSubTitle = "GSM Number"
    static let userProfileBottomLabelText1 = "I’d like hear about news and promotions about lifebox occasionally."
    static let userProfileBottomLabelText2 = "We promise, we won’t sent you spam."
    static let userProfileWhantToChangePasswordButton = "I want to change my password"
    static let userProfileEditButton = "Edit"
    static let userProfileDoneButton = "Done"
    static let userProfileDataNotСhanged = "Data did not changed"
    static let userProfileDataNotCorrect = "Data is not correct"

    //MARK: fileInfo
    static let fileInfoFileNameTitle = "File Name"
    static let fileInfoInfoTitle = "File Info"
    static let fileInfoFolderSizeTitle = "Folder size"
    static let fileInfoAlbumSizeTitle = "Items"
    static let fileInfoFileSizeTitle = "File size"
    static let fileInfoDurationTitle = "Duration"
    static let fileInfoDateModifiedTitle = "Date modified"
    static let fileInfoUploadDateTitle = "Upload date"
    static let fileInfoTakenDateTitle = "Taken date"
    static let fileInfoAlbumTitle = "Album"
    static let fileInfoArtistTitle = "Artist"
    static let fileInfoTitleTitle = "Title"
    static let fileInfoAlbumNameTitle = "Album Name"
    static let fileInfoAlbumInfoTitle = "Album Info"
    static let fileInfoSave = "Save"
    
    //MARK: settings User info view
    static let settingsUserInfoViewUpgradeButtonText = "UPGRADE"
    static let settingsUserInfoViewQuota = "%@ of %@ has remained"
    
    //MARK: Bacup contacts view
    static let settingsBackupContactsViewTitle = "Back Up My Contacts"
    static let settingsBackupContactsViewNewContactsText = "New Contact"
    static let settingsBackupContactsViewDuplicatesText = "Updated"
    static let settingsBackupContactsViewRemovedText = "Removed"
    static let settingsBackupedText = "Backed up %d Contacts"
    static let settingsRestoredText = "Restored up %d Contacts"
    static let settingsBacupingText = "%d%% Backed up…"
    static let settingsRestoringText = "%d%% Restored up…"
    static let settingsBacupNeverDidIt = "You can backup your contacts to lifebox. By\ndoing that you can easly access your contact\nlist from any device and anywhere."
    static let settingsBacupNewer = "You never backed up your contacts"
    static let settingsBacupLessAMinute = "Your last back up was a few seconds ago."
    static let settingsBacupLessADay = "Your last back was on %@"
    static let settingsBacupButtonTitle = "Back-Up"
    static let settingsBacupRestoreTitle = "Restore"
    static let settingsBacupClearBacupTitle = "Clear Bacup"
    static let settingsBacupCancelBacupTitle = "Cancel Bacup"
    
    //MARK: ActionsMenuAction
    static let actionsMenuActionMove = "Move"
    static let actionsMenuActionRemoveFromAlbum = "Remove from album"
    static let actionsMenuActionAddToFavorites = "Add to favorites"
    static let actionsMenuActionDeleteDeviceOriginal = "Delete device original"
    static let actionsMenuActionCopy = "Copy"
    static let actionsMenuActionDocumentDetail = "Document Details"
    
    //MARK: Create folder
    static let createFolderTitleText = "New Folder"
    static let createFolderPlaceholderText = "Folder Name"
    static let createFolderCreateButton = "Create"
    static let createFolderEmptyFolderNameAlert = "Sorry, but folder name should not be empty"
    static let createFolderEmptyFolderButtonText = "Ok"
    
    //MARK: Create story Name
    static let createStoryNameTitle = "Create a Name"
    static let createStoryNamePlaceholder = "Name"
    static let createStoryNameSave = "SAVE"
    static let createStoryEmptyTextError = "Sorry, but story name should not be empty"
    static let createStorySelectAudioButton = "Continue"
    
    //MARK: Create story Photos
    static let createStoryPhotosTitle = "Photo selection"
    static let createStoryPhotosNext = "Next"
    static let createStoryPhotosMaxCountAllert = "Please choose %d files at most"
    static let createStoryPhotosMaxCountAllertOK = "Ok"
    static let createStoryNoSelectedPhotosError = "Sorry, but story photos should not be empty"
    static let createStoryCreated = "Story created"
    static let createStoryNotCreated = "Story not created"
    static let failWhileAddingToAlbum = "Fail while adding to album"
    
    //MARK: Create story Audio
    static let createStoryNoSelectedAudioError = "Sorry, but story audio should not be empty"
    static let createStoryAudioSelected = "Add Music"

    
    //MARK: Create story Photo Order
    static let createStoryPhotosOrderNextButton = "Create"
    static let createStorySave = "Save"
    static let createStoryPhotosOrderTitle = "You can change the sequence "
    
    //MARK: Upload 
    static let uploadFilesNextButton = "Upload"
    static let uploadFilesSingleHeader = "Item Selected"
    static let uploadFilesMultipleHeader = "Items Selected"
    static let uploadFilesNothingUploadError = "Nothing to upload"
    static let uploadFilesNothingUploadOk = "Ok"
    static let uploadSuccessful = "Upload was successful"
    static let uploadFailed = "Upload failed"
    
    //MARK: UploadFromLifeBox
    static let uploadFromLifeBoxTitle = "Upload from lifebox"
    static let uploadFromLifeBoxNextButton = "Next"
    static let uploadFromLifeBoxNoSelectedPhotosError = "Sorry, but photos not selected"
    static let uploadFromLifeBoxEmptyFolderButtonText = "Ok"
    static let failWhileuploadFromLifeBoxCopy = "Fail while uploading from LifeBox"
    
    
    //MARK: Select Folder
    static let selectFolderNextButton = "Select"
    static let selectFolderCancelButton = "Cancel"
    static let selectFolderBackButton = "Back"
    static let selectFolderEmptySelectionError = "Need to select folder"
    static let selectFolderEmptySelectionErrorOK = "Ok"
    static let selectFolderTitle = "Choose a destination folder"

     //MARK: - TabBar tab lables
    static let home = "Home"
    static let photoAndVideo = "Photos & Videos"
    static let music = "Music"
    static let documents = "Documents"
    static let tabBarDeleteLabel = "Delete"
    static let tabBarRemoveAlbumLabel = "Remove Album"
    static let tabBarRemoveLabel = "Remove From Album"
    static let tabBarAddToAlbumLabel = "Add To Album"
    static let tabAlbumCoverAlbumLabel = "Make album cover"
    static let tabBarEditeLabel = "Edit"
    static let tabBarPrintLabel = "Print"
    static let tabBarDownloadLabel = "Download"
    static let tabBarSyncLabel = "Sync"
    static let tabBarMoveLabel = "Move"
    static let tabBarShareLabel = "Share"
    static let tabBarInfoLabel = "Info"
    
    //MARK: Select Name 
    static let selectNameTitleFolder = "New Folder"
    static let selectNameTitleAlbum = "New Album"
    static let selectNameTitlePlayList = "New PlayList"
    static let selectNameNextButtonFolder = "Create"
    static let selectNameNextButtonAlbum = "Create"
    static let selectNameNextButtonPlayList = "Create"
    static let selectNamePlaceholderFolder = "Folder Name"
    static let selectNamePlaceholderAlbum = "Album Name"
    static let selectNamePlaceholderPlayList = "Play List Name"
    static let selectNameEmptyNameFolder = "Sorry, but folder name should not be empty"
    static let selectNameEmptyNameAlbum = "Sorry, but album name should not be empty"
    static let selectNameEmptyNamePlayList = "Sorry, but play list name should not be empty"
    
    //MARK: Albums
    static let albumsTitle = "Albums"
    static let selectAlbumButtonTitle = "Add"
    static let uploadPhotos = "Upload Photos"
    
    //MARK: Feedback View
    static let feedbackMailTextFormat = "Please do not delete the information below. The information will be used to address the problem.\n\nApplication Version: %@\nMsisdn: %@\nCarrier: %@\nDevice:%@\nDevice OS: %@\nLanguage: %@\nLanguage preference: %@\nNetwork Status: %@\nTotal Storage: %lld\nUsed Storage: %lld\nPackages: %@\n"
    static let feedbackViewTitle = "Thanks for leaving a comment!"
    static let feedbackViewSubTitle = "Feedback Form"
    static let feedbackViewSuggestion = "Suggestion"
    static let feedbackViewComplaint = "Complaint"
    static let feedbackViewLanguageLabel = "You need to specify your language preference so that we can serve you better."
    static let feedbackViewSendButton = "Send"
    static let feedbackViewSelect = "Select"
    static let feedbackEmail = "DESTEK-LIFEBOX@TURKCELL.COM.TR"
    static let feedbackEmailError = "Please configurate email client"
    static let feedbackErrorEmptyDataTitle = "Error"
    static let feedbackErrorTextError = "Please type your message"
    static let feedbackErrorLanguageError = "You need to specify your language preference so that we can serve you better."
    
    
    //MARK: PopUp
    static let popUpProgress = "(%ld of %ld)"
    static let popUpSyncing = "Syncing files"
    static let popUpUploading = "Uploading files"
    static let popUpDownload = "Downloading files"
    static let freeAppSpacePopUpTextNormal = "There are some duplicated items both in your device and lifebox"
    static let freeAppSpacePopUpTextWaring = "Your device memory is almost full"
    static let freeAppSpacePopUpButtonTitle = "Free up space"

    
    //MARK: - ActionSheet
    
    static let actionSheetCancel = "Cancel"
    
    static let actionSheetShare = "Share"
    static let actionSheetInfo = "Info"
    static let actionSheetEdit = "Edit"
    static let actionSheetDelete = "Delete"
    static let actionSheetMove = "Move"
    static let actionSheetSync = "Sync"
    static let actionSheetDownload = "Download"
    
    static let actionSheetShareSmallSize = "Small Size"
    static let actionSheetShareOriginalSize = "Original Size"
    static let actionSheetShareShareViaLink = "Share Via Link"
    static let actionSheetShareCancel = "Cancel"
 
    static let actionSheetCreateStory = "Create a Story"
    static let actionSheetCopy = "Copy"
    static let actionSheetAddToFavorites = "Add to Favorites"
    static let actionSheetRemove = "Remove"
    static let actionSheetRemoveFavorites = "Remove from Favorites"
    static let actionSheetAddToAlbum = "Add to album"
    static let actionSheetBackUp = "Back Up"
//    static let actionSheetAddToCmeraRoll = "" now its download to camera roll
    static let actionSheetRemoveFromAlbum = "Remove from album"
    
    static let actionSheetTakeAPhoto = "Take Photo"
    static let actionSheetChooseFromLib = "Choose From Library"
    
    static let actionSheetPhotos = "Photos"
    static let actionSheetiCloudDrive = "iCloud Drive"
    static let actionSheetLifeBox = "lifebox"
    static let actionSheetMore = "More"
    
    static let actionSheetSelect = "Select"
    static let actionSheetSelectAll = "Select All"
    
    static let actionSheetRename = "Rename"
    
    static let actionSheetDocumentDetails = "Document Details"
    
    static let actionSheetAddToPlaylist = "Share Album"
    static let actionSheetMusicDetails = "Music Dteails"
    
    static let actionSheetMakeAlbumCover = "Make album covers"
    static let actionSheetAlbumDetails = "Album Details"
    static let actionSheetShareAlbum = "Share Album"
    static let actionSheetDownloadToCameraRoll = "Download to Camera Roll"
    
    // MARK: Free Up Space
    static let freeAppSpaceTitle = "There are %d duplicated photos both in your device and lifebox. Clear some space by selecting the photos that you want to delete."
    static let freeAppSpaceAlertTitle = "Allow lifebox to delete %d photos?"
    static let freeAppSpaceAlertText = "Some photos will also be deleted from an album."
    static let freeAppSpaceAlertCancel = "Cancel"
    static let freeAppSpaceAlertDelete = "Delete"
    static let freeAppSpaceAlertSuccesTitle = "You have free space for %d more items."
    static let freeAppSpaceAlertSuccesButton = "OK"
    
    // MARK NAVBAR titles
    
    static let cancel = "Cancel"
    
    
    //MARK: - 
    
    static let albumLikeSlidertitle = "My Stream"
    
    // MARK: - ActivityTimeline
    static let activityTimelineFiles = "file(s)"
    static let activityTimelineTitle = "My Activity Timeline"
    
    // MARK: - PullToRefresh
    static let pullToRefreshPull = "Pull to refresh"
    static let pullToRefreshRelease = "Release to refresh"
    static let pullToRefreshSuccess = "Success"
    static let pullToRefreshRefreshing = "Refreshing..."
    static let pullToRefreshFailed = "Failed"
    
    // MARK: - usageInfo
    static let usageInfoPhotos = "%ld photos"
    static let usageInfoVideos = "%ld videos"
    static let usageInfoSongs = "%ld songs"
    static let usageInfoDocuments = "%ld documents"
    static let usageInfoBytesRemained = "%@ of %@ has remained"
    static let usageInfoWelcome = "Welcome Pack (%@)"
    static let usageInfoDocs = "%ld docs"
    
    // MARK: - offers
    static let offersSubTurkcellActivate = "Special prices for lifecell subscribers! To activate lifebox 50GB for 24,99UAH/30 days send SMS with the text 50VKL, for lifebox 500GB for 52,99UAH/30days send SMS with the text 500VKL to the number 8080."
    static let offersSubTurkcellCancel = "To deactivate lifebox 50GB please send SMS with the text 50VYKL, for lifebox 500GB please send SMS with the text 500VYKL to the number 8080."
    static let offersTurkcellCancel = "You can send SMS message to 2222 by writing \"Depo Iptal\" to cancel subscription."
    static let offersAllCancel = "You can open settings and cancel subscption."
    static let offersInfo = "Info"
    static let offersCancel = "Cancel"
    static let offersBuy = "Buy"
    static let offersOk = "OK"
    static let offersSettings = "Settings"
    static let offersPrice = "%f ₺ / month"
    
    // MARK: - OTP
    static let otpNextButton = "Next"
    static let otpResendButton = "Resend"
    static let otpTitleText = "Enter the verification code\nsent to your number %@"
    
    // MARK: - Errors
    static let errorEmptyEmail = "Indicates that the e-mail parameter is sent blank."
    static let errorEmptyPassword = "Indicates that the password parameter is sent blank."
    static let errorEmptyPhone = "Specifies that the phone number parameter is sent  blank."
    static let errorInvalidEmail = "E-mail address is in an invalid format."
    static let errorExistEmail = "A user with the given e-mail address already exists."
    static let errorVerifyEmail = "Indicates that a user with the given e-mail address already exists and login will be  allowed after e-mail address validation."
    static let errorInvalidPhone = "Phone number is in an invalid format."
    static let errorExistPhone = "A user with the given phone number already exists."
    static let errorInvalidPassword = "Password is invalid"
    static let errorInvalidPasswordConsecutive = "It is not allowed that the password consists of consecutive characters."
    static let errorInvalidPasswordSame = "It is not allowed that the password consists of all the same characters."
    static let errorInvalidPasswordLengthExceeded = "The password consists of more number of characters than is allowed. The length allowed is provided in the value field of the response."
    static let errorInvalidPasswordBelowLimit = "The password consists of less number of characters than is allowed. The length allowed is provided in the value field of the response."
    static let errorManyRequest = "It indicates that sending OTP procedure is repeated numerously. It can be tried again later but a short amount of time should be spent before retry."
    
    static let TOO_MANY_REQUESTS = "Too many invalid attempts, please try again later"
    
    static let errorUnknown = "Unknown error"
    static let errorServer = "Server error"
    
    static let canceledOperationTextError = "Cancelled"
    
    static let ACCOUNT_NOT_FOUND = "Account cannot be found"
    static let INVALID_PROMOCODE = "This package activation code is invalid"
    static let PROMO_CODE_HAS_BEEN_ALREADY_ACTIVATED = "This package activation code has been used before, please try different code"
    static let PROMO_CODE_HAS_BEEN_EXPIRED = "This package activation code has expired"
    static let PROMO_CODE_IS_NOT_CREATED_FOR_THIS_ACCOUNT = "This package activation code is defined for different user"
    static let THERE_IS_AN_ACTIVE_JOB_RUNNING = "Package activation process is in progress"
    static let CURRENT_JOB_IS_FINISHED_OR_CANCELLED = "This package activation code has been used before, please try different code"
    static let PROMO_IS_NOT_ACTIVATED = "This package activation code has not been activated  yet"
    static let PROMO_HAS_NOT_STARTED = "This package activation code definition time has not yet begun"
    static let PROMO_NOT_ALLOWED_FOR_MULTIPLE_USE = "You will not be able to use the this package activation code from this campaign for the second time because you have already benefited from it"
    static let PROMO_IS_INACTIVE = "The package activation code is not active"
    
    static let passcode = "Passcode"
    static let passcodeEnter = "Enter lifebox passcode"
    static let passcodeEnterOld = "Enter old lifebox passcode"
    static let passcodeEnterNew = "Enter new lifebox passcode"
    static let passcodeConfirm = "Confirm lifebox passcode"
    static let passcodeChanged = "Passcode is changed successfully"
    static let passcodeSet = "You successfully set passcode"
    static let passcodeDontMatch = "Passcodes don't match, please try again"
    static let passcodeEnterTitle = "Enter passcode"
    static let passcodeBiometricsDefault = "To enter passcode"
    static let passcodeEnableFaceID = "Enable Face ID"
    static let passcodeEnableTouchID = "Enable Touch ID"
    static let passcodeNumberOfTries = "You have %@ attempts left"
    static let errorConnectedToNetwork = "Please check your internet connection is active and Cellular Data is ON under Settings/lifebox."
    
    static let apply = "Apply"
    static let success = "Success"
    
    static let promocodeTitle = "Lifebox campaign"
    static let promocodePlaceholder = "Enter your promo code"
    static let promocodeError = "This package activation code is invalid"
    static let promocodeEmpty = "Please enter your promo code"
    static let promocodeSuccess = "Your package is successfully defined"
    static let promocodeInvalid = "Verification code is invalid.\nPlease try again"
    static let promocodeBlocked = "Verification code is blocked.\nPlease request a new code"
    
    static let packages = "Packages"
}


struct NumericConstants {
    //verefy phone screen
    static let vereficationCharacterLimit = 6
    static let vereficationTimerLimit = 120//in seconds
    static let maxVereficationAttempts = 3
    //
    
    static let numerCellInLineOnIphone: CGFloat = 4
    static let numerCellInDocumentLineOnIphone: CGFloat = 2
    static let iPhoneGreedInset: CGFloat = 2
    static let iPhoneGreedHorizontalSpace: CGFloat = 1
    static let iPadGreedInset: CGFloat = 5
    static let iPadGreedHorizontalSpace: CGFloat = 5
    static let maxNumberPhotosInStory: Int = 20
    static let maxNumberAudioInStory: Int = 1
    static let creationStoryOrderingCountPhotosInLineiPhone: Int = 4
    static let creationStoryOrderingCountPhotosInLineiPad: Int = 6
    static let albumCellListHeight: CGFloat = 100
    
    static let topContentInset: CGFloat = 64
    
    static let animationDuration: Double = 0.3
    
    static let lifeSessionDuration: TimeInterval = 60 * 50 //50 min
    
    static let timeIntervalBetweenAutoSync: TimeInterval = 60*60

    static let freeAppSpaceLimit = 0.2
    
    static let fourGigabytes: UInt64 = 4 * 1024 * 1024 * 1024
    
}
