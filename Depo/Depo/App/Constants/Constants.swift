//
//  Constants.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

struct TextConstants {
    static let itroViewGoToRegisterButtonText = NSLocalizedString("Start using Lifebox now!", comment: "")
    static let introViewGoToLoginButtonText = NSLocalizedString("I have an account, let me log in", comment: "")
    
    static let registrationCellTitleEmail = NSLocalizedString("E-MAIL", comment: "")
    static let registrationCellTitleGSMNumber = NSLocalizedString("GSM Number", comment: "")
    static let registrationCellTitlePassword = NSLocalizedString("Password", comment: "")
    static let registrationCellTitleReEnterPassword = NSLocalizedString("Re-Enter Password", comment: "")
    static let registrationCellPlaceholderEmail = NSLocalizedString(" You have to fill in your mail", comment: "")
    static let notCorrectEmail = NSLocalizedString("Please enter valid Email", comment: "")
    static let registrationCellPlaceholderPassword = NSLocalizedString(" You have to fill in a password", comment: "")
    static let registrationCellPlaceholderReFillPassword = NSLocalizedString(" You have to fill in a password", comment: "")
    static let registrationTitleText = NSLocalizedString("Register to lifebox and get a 5 GB of storage for free!", comment: "")
    static let registrationNextButtonText = NSLocalizedString("Next", comment: "")
    static let registrationResendButtonText = NSLocalizedString("Resend", comment: "")
    static let optInNavigarionTitle = NSLocalizedString("Verify Your Purchase", comment: "")
    static let phoneVereficationMainTitleText = NSLocalizedString("Verify Your Phone Number", comment: "")
    static let mailVereficationMainTitleText = NSLocalizedString("Verify Your Email", comment: "")
    static let phoneVereficationInfoTitleText = NSLocalizedString("Enter the verification code", comment: "")
    static let phoneVereficationNonValidCodeErrorText = NSLocalizedString("Verification code is invalid. \n Please try again.", comment: "")
    static let phoneVereficationResendRequestFailedErrorText = NSLocalizedString("Request failed \n Please try again", comment: "")
    static let loginScreenCredentialsError = NSLocalizedString("Login denied. Please check your credentials.", comment: "")
    static let loginScreenNoLoginError = NSLocalizedString("Please check the GSM number", comment: "")
    static let loginScreenNoPasswordError = NSLocalizedString("Please enter your password", comment: "")
    static let loginScreenNoInternetError = NSLocalizedString("Please check your internet connection.", comment: "")
    static let registrationPasswordError = NSLocalizedString("Please set a password including nonconsecutive letters and numbers, minimum 6 maximum 16 characters.", comment: "")
    static let hourBlockLoginError = NSLocalizedString("You have performed too many attempts. Please try again 1 hour later.", comment: "")
    static let registrationMailError = NSLocalizedString("Please check the e-mail address.", comment: "")
    static let registrationPasswordNotMatchError = NSLocalizedString("Password fields do not match.", comment: "")
    
    static let registrationEmailPopupTitle = NSLocalizedString("E-mail Usage Information", comment: "")
    static let registrationEmailPopupMessage = NSLocalizedString("You are finalizing the process with %@ e-mail address. We will be using this e-mail for password operations and site notifications", comment: "")
    
    //MARK: - Registration Error Messages
    static let invalidMailErrorText = NSLocalizedString("Please enter a valid email address.", comment: "")
    static let invalidPhoneNumberText = NSLocalizedString("Please enter a valid GSM number.", comment: "")
    static let invalidPasswordText = NSLocalizedString("Please enter your password", comment: "")
    static let invalidPasswordMatchText = NSLocalizedString("Password fields do not match", comment: "")
    //MARK: -
    static let termsAndUsesTitile = NSLocalizedString("Sign Up", comment: "")
    static let termsAndUsesApplyButtonText = NSLocalizedString("Accept  Terms", comment: "")
    static let termsAndUseTextFormat = NSLocalizedString("<html><body text=\"#FFFFFF\" face=\"Bookman Old Style, Book Antiqua, Garamond\" size=\"5\">%@</body></html>", comment: "")
    
    static let loginTitle = NSLocalizedString("Login", comment: "")
    static let loginTableTitle = NSLocalizedString("Register to lifebox and get a 5 GB of storage for free!", comment: "")
    static let loginCantLoginButtonTitle = NSLocalizedString("I can't login", comment: "")
    static let loginRememberMyCredential = NSLocalizedString("Remember my credentials", comment: "")
    static let loginCellTitleEmail = NSLocalizedString("E-Mail or GSM Number", comment: "")
    static let loginCellTitlePassword = NSLocalizedString("Password", comment: "")
    static let loginCellEmailPlaceholder = NSLocalizedString( "You have to fill in your mail or GSM Number", comment: "")
    static let loginCellPasswordPlaceholder = NSLocalizedString("You have to fill in a password", comment: "")
    
    static let autoSyncNavigationTitle = NSLocalizedString("Auto Sync", comment: "")
    static let autoSyncTitle = NSLocalizedString("Lifebox can sync your files automatically. Would you like to have this feature right now?", comment: "")
    static let autoSyncCellWiFiTile = NSLocalizedString("Wi-fi", comment: "")
    static let autoSyncCellWiFiSubTitle = NSLocalizedString("When syncing via Wi-Fi, your photos and videos are uploaded by default.", comment: "")
    static let autoSyncCellMobileDataTitle = NSLocalizedString("Mobile Data", comment: "")
    static let autoSyncCellMobileDataSubTitle = NSLocalizedString("Select the items to sync with mobile data.", comment: "")
    static let autoSyncCellPhotos = NSLocalizedString("Photos", comment: "")
    static let autoSyncCellVideos = NSLocalizedString("Videos", comment: "")
    static let autoSyncStartUsingLifebox = NSLocalizedString("Let’s start using Lifebox", comment: "")
    static let autoSyncskipForNowButton = NSLocalizedString("Skip for now", comment: "")
    static let autoSyncAlertTitle = NSLocalizedString("Skip setting Auto-Sync?", comment: "")
    static let autoSyncAlertText = NSLocalizedString("You’re skipping auto-sync setting turned off. You can activate this later in preferences.", comment: "")
    static let autoSyncAlertYes = NSLocalizedString("Skip Auto-Sync", comment: "")
    static let autoSyncAlertNo = NSLocalizedString("Cancel", comment: "")
    static let autoSyncSaveButton = NSLocalizedString("Save", comment: "")
    static let welcome1Info = NSLocalizedString("Welcome1Info", comment: "")
    static let welcome1SubInfo = NSLocalizedString("Welcome1SubInfo", comment: "")
    
    static let autoSyncSyncOverTitle = NSLocalizedString("Sync over data plan?", comment: "")
    static let autoSyncSyncOverMessage = NSLocalizedString("Syncing files using cellular data could incur data charges", comment: "")
    static let autoSyncSyncOverOn = NSLocalizedString("Turn-on Sync", comment: "")
    
    
    static let registerTitle = NSLocalizedString("Sign Up", comment: "")
    
    static let forgotPasswordTitle = NSLocalizedString("Forgot My Password", comment: "")
    static let forgotPasswordSubTitle = NSLocalizedString("If you are already a Turkcell subscriber, you can retrieve your password by sending SMS to 2222", comment: "")
    static let forgotPasswordSpecialSubTitle = NSLocalizedString("If you registered with your Turkcell Number you can just send SIFRE LIFEBOX to 2222 to recieve a new password or enter your mail below", comment: "")
    static let forgotPasswordSendPassword = NSLocalizedString("Send password reset link", comment: "")
    static let forgotPasswordCellTitle = NSLocalizedString("E-MAIL", comment: "")
    
    static let captchaPlaceholder = NSLocalizedString("Type the text", comment: "")
    
    static let checkPhoneResendCodeButtonText = NSLocalizedString("Resend", comment: "")
    static let checkPhoneNextButtonText = NSLocalizedString("Next", comment: "")
    
    static let checkPhoneAlertTitle = NSLocalizedString("Error", comment: "")
    static let checkPhoneAlertFormedText = NSLocalizedString("Verification code is invalid. Please try again.", comment: "")
    
    static let serverResponceError = NSLocalizedString("Wrong type of answer", comment: "")
    
    static let errorAlert = NSLocalizedString("Error", comment: "")
    static let errorAlerTitleBackupAlreadyExist = NSLocalizedString("Overwrite backup?", comment: "")
    static let errorAlertTextBackupAlreadyExist = NSLocalizedString("You have already a backup. Do you want to overwrite the existing one?", comment: "")
    static let errorAlertNopeBtnBackupAlreadyExist = NSLocalizedString("Nope", comment: "")
    static let errorAlertYesBtnBackupAlreadyExist = NSLocalizedString("Yes", comment: "")
    
    //MARK: - mail update
    static let updaitMailMaybeLater = NSLocalizedString("Maybe later", comment: "")
    
    // MARK: - DetailScreenError
    
    static let theFileIsNotSupported = NSLocalizedString("The file isn't supported", comment: "")
    static let warning = NSLocalizedString("Warning", comment: "")
    
    // MARK: - Search
    

    static let search = NSLocalizedString("Search", comment: "")
    static let searchRecentSearchTitle = NSLocalizedString("RECENT SEARCHES", comment: "")
    static let searchSuggestionsTitle = NSLocalizedString("SUGGESTIONS", comment: "")
    static let searchNoFilesToCreateStoryError = NSLocalizedString("No files to create a story", comment: "")
    
    static let noFilesFoundInSearch = NSLocalizedString("No results found for your query.", comment: "")
    
    // MARK: - Sync Contacts
    
    static let backUpMyContacts = NSLocalizedString("Back Up My Contacts", comment: "")
    
    // MARK: - Authification Cells
    static let showPassword = NSLocalizedString("Show", comment: "")
    static let hidePassword = NSLocalizedString("Hide", comment: "")
    
    
    // MARK: - button navigation name
    static let chooseTitle = NSLocalizedString("Choose", comment: "")
    static let nextTitle = NSLocalizedString("Next", comment: "")
    static let backTitle = NSLocalizedString("Back", comment: "")
    
    // MARK: - home buttons title
    static let homeButtonAllFiles = NSLocalizedString("All Files", comment: "")
    static let homeButtonCreateStory = NSLocalizedString("Create a Story", comment: "")
    static let homeButtonFavorites = NSLocalizedString("Favorites", comment: "")
    static let homeButtonSyncContacts = NSLocalizedString("Sync Contacts", comment: "")
    
    //MARK: - Home page subButtons Lables
    static let takePhoto = NSLocalizedString("Take Photo", comment: "")
    static let upload = NSLocalizedString("Upload", comment: "")
    static let createStory = NSLocalizedString("Create a Story", comment: "")
    static let newFolder = NSLocalizedString("New Folder", comment: "")
    static let createAlbum = NSLocalizedString("Create album", comment: "")
    static let uploadFromLifebox = NSLocalizedString("Upload from lifebox", comment: "")
    
    //MARK: - Navigation bar img names
    
    static let moreBtnImgName = NSLocalizedString("more", comment: "")
    static let cogBtnImgName = NSLocalizedString("cog", comment: "")
    static let searchBtnImgName = NSLocalizedString("search", comment: "")
    static let deleteBtnImgName = NSLocalizedString("DeleteShareButton", comment: "")
    
    // MARK: - Searchbar img name
    
    static let searchIcon = NSLocalizedString("searchIcon", comment: "")
    
    //MARK: - Navigation bar buttons titles
    
    static let cancelSelectionButtonTitle = NSLocalizedString("Cancel", comment: "")
    
    //MARK: - More actions Collection view section titles
    
    static let syncTypeTitle = NSLocalizedString("Sync Type", comment: "")
    static let viewTypeTitle = NSLocalizedString("View Type", comment: "")
    static let sortTypeTitle = NSLocalizedString("Sort Type", comment: "")
    static let fileTypeTitle = NSLocalizedString("File Type", comment: "")
    static let selectionTypeTitle = NSLocalizedString("Selection Type", comment: "")
    
    
    static let viewTypeListTitle = NSLocalizedString("List", comment: "")
    static let viewTypeGridTitle = NSLocalizedString("Grid", comment: "")
    
    static let sortTypeAlphabeticAZTitle = NSLocalizedString("Name (A-Z)", comment: "")
    static let sortTypeAlphabeticZATitle = NSLocalizedString("Name (Z-A)", comment: "")
    static let sortTimeOldNewTitle = NSLocalizedString("Oldest", comment: "")
    static let sortTimeNewOldTitle = NSLocalizedString("Newest", comment: "")
    static let sortTimeSizeTitle = NSLocalizedString("Size", comment: "")
    static let sortTimeSizeLargestTitle = NSLocalizedString("Largest", comment: "")
    static let sortTimeSizeSmallestTitle = NSLocalizedString("Smallest", comment: "")
    
    static let sortHeaderAlphabetic = NSLocalizedString("Alphabetically Sorted", comment: "")
    static let sortHeaderTime = NSLocalizedString("Sorted by Time", comment: "")
    static let sortHeaderSize = NSLocalizedString("Sorted by Size", comment: "")
    
    static let fileTypeVideoTitle = NSLocalizedString("Video", comment: "")
    static let fileTypeDocsTitle = NSLocalizedString("Docs", comment: "")
    static let fileTypeMusicTitle = NSLocalizedString("Music", comment: "")
    static let fileTypePhotosTitle = NSLocalizedString("Photos", comment: "")
    static let fileTypeAlbumTitle = NSLocalizedString("Album", comment: "")
    static let fileTypeFolderTitle = NSLocalizedString("Folder", comment: "")
    
    static let selectedTypeSelectedTitle = NSLocalizedString("Select", comment: "")
    static let selectedTypeSelectedAllTitle = NSLocalizedString("Select All", comment: "")
    
    //MARK: - TOPBAR
    
    static let topBarVideosFilter = NSLocalizedString("Videos", comment: "")
    static let topBarPhotosFilter = NSLocalizedString("Photos", comment: "")
    
    //MARK: Home page Welcome
    static let homeWelcomTextBig = NSLocalizedString("Welcome! Let’s get you started!", comment: "")
    static let homeWelcomTextSmall = NSLocalizedString("You can start using your smart box with our suggestions. When you’re done you can swipe to dismiss the card -including this one too. Nothing is lost! You can access everything you see here through the app. ", comment: "")
    
    //MARK: - Camera alert
    static let cameraAccessAlertTitle = NSLocalizedString("Caution!", comment: "")
    static let cameraAccessAlertText = NSLocalizedString("You can't take photos with disabled camera. Please turn the camera on in settings.", comment: "")
    static let cameraAccessAlertGoToSettings = NSLocalizedString("Settings", comment: "")
    static let cameraAccessAlertNo = NSLocalizedString("No", comment: "")
    
    //MARK: - Sync out of space alert
    static let syncOutOfSpaceAlertTitle = NSLocalizedString("Caution!", comment: "")
    static let syncOutOfSpaceAlertText = NSLocalizedString("You have reached your lifebox memory limit.\nLet’s have a look for upgrade options!", comment: "")
    static let syncOutOfSpaceAlertGoToSettings = NSLocalizedString("Upgrade", comment: "")
    static let syncOutOfSpaceAlertCancel = NSLocalizedString("Cancel", comment: "")
    
    //MARK: - Photo Library alert
    static let photoLibraryAccessAlertTitle = NSLocalizedString("Caution!", comment: "")
    static let photoLibraryAccessAlertText = NSLocalizedString("Access to Gallery is denied. Please change it from the settings menu of the device", comment: "")
    static let photoLibraryAccessAlertGoToSettings = NSLocalizedString("Settings", comment: "")
    static let photoLibraryAccessAlertNo = NSLocalizedString("No", comment: "")
    
    //MARK: Home page wiFiSync view
    static let homeWiFiTitleText = NSLocalizedString("Waiting for Wi-Fi to auto sync 14 items", comment: "")
    static let homeWiFiSyncButtonTitle = NSLocalizedString("Sync with Data Plan Now", comment: "")
    
    //MARK: Home page completeProfile view
    static let homeCompleteProfileSubTitleBig = NSLocalizedString("Your profile looks empty", comment: "")
    static let homeCompleteProfileSubTitleSmall = NSLocalizedString("You don’t have a profile picture, let’s upload a pretty photo!", comment: "")
    static let homeCompleteProfileUploadButton = NSLocalizedString("Upload", comment: "")
    static let homeCompleteProfileTakeAPhoto = NSLocalizedString("Take a Photo", comment: "")
    
    
    //MARK: Home page like filter view
    static let homeLikeFilterTitle = NSLocalizedString("Did you like this filter?", comment: "")
    static let homeLikeFilterSubTitle = NSLocalizedString("You can apply this filter and my more to your other picures as well", comment: "")
    static let homeLikeFilterSavePhotoButton = NSLocalizedString("Save this photo", comment: "")
    static let homeLikeFilterChangeFilterButton = NSLocalizedString("Change filter", comment: "")
    
    //MARK: Home page expande storrage view
    static let homeExpandeStorageBigTitle = NSLocalizedString("Your storage is almost full!", comment: "")
    static let homeExpandeStorageSmallTitle = NSLocalizedString("You are using %85 of your disk space! It’s a great time to expand your storage.", comment: "")
    static let homeExpandeStorageButton = NSLocalizedString("Expand My Storage", comment: "")
    
    //MARK: Home page uploaded images view
    static let homeUploadedImagesTitle = NSLocalizedString("You’ve uploaded %@ two days ago!", comment: "")
    static let homeUploadedPhotosTitle = NSLocalizedString("%d Photos", comment: "")
    static let homeUploadedImagesViewAllStreams = NSLocalizedString("View All My Stream", comment: "")
    static let homeUploadedImagesViewAllPictures = NSLocalizedString("View All Pictures", comment: "")
    
    //MARK: Popup
    static let ok = NSLocalizedString("OK", comment: "")
    
    //MARK: PhotosVideosView
    static let photosVideosViewNoPhotoTitleText = NSLocalizedString("You don’t have anything on your photo roll.", comment: "")
    static let photosVideosViewNoPhotoButtonText = NSLocalizedString("Start adding your photos", comment: "")
    static let photosVideosViewHaveNoPermissionsAllertText = NSLocalizedString("Enable photo permissions in settings", comment: "")
    
    //MARK:PhotoVideoDetail
    static let photosVideosDetailViewShareButton = NSLocalizedString("Share", comment: "")
    static let photosVideosDetailViewInfoButton = NSLocalizedString("info", comment: "")
    static let photosVideosDetailViewEditButton = NSLocalizedString("Edit", comment: "")
    static let photosVideosDetailViewMoveButton = NSLocalizedString("Move", comment: "")
    static let photosVideosDetailViewDeleteButton = NSLocalizedString("Delete", comment: "")
    
    //MARK: AudioView
    static let audioViewNoAudioTitleText = NSLocalizedString("You don’t have any music on your Lifebox yet.", comment: "")
    static let audioViewNoAudioButtonText = NSLocalizedString("Start adding your music", comment: "")
    
    //MARK: DocumentsView
    static let documentsViewNoDocumenetsTitleText = NSLocalizedString("You don’t have any documents on your Lifebox yet.", comment: "")
    static let documentsViewNoDocumenetsButtonText = NSLocalizedString("Start adding your documents", comment: "")
    
    //MARK: settings
    static let backPrintTitle = NSLocalizedString("Back to Lifebox", comment: "")
    
    //MARK: settings
    
    static let settingsViewUploadPhotoLabel = NSLocalizedString("Upload Photo", comment: "")
    static let settingsViewLeaveFeedback = NSLocalizedString("Leave feedback", comment: "")
    
    static let settingsViewCellBeckup = NSLocalizedString("Back-up my contacts", comment: "")
    static let settingsViewCellImportPhotos = NSLocalizedString("Import Photos", comment: "")
    static let settingsViewCellAutoUpload = NSLocalizedString("Auto Sync", comment: "")
    static let settingsViewCellActivityTimline = NSLocalizedString("My Activity Timeline", comment: "")
    static let settingsViewCellRecentlyDeletedFiles = NSLocalizedString("Recently Deleted Files", comment: "")
    static let settingsViewCellUsageInfo = NSLocalizedString("Usage Info and Packages", comment: "")
    static let settingsViewCellPasscode = NSLocalizedString("Lifebox Touch ID and Passcode", comment: "")
    static let settingsViewCellHelp = NSLocalizedString("Help & Support", comment: "")
    static let settingsViewCellLogout = NSLocalizedString("Logout", comment: "")
    static let settingsViewCellTurkcellPasscode = NSLocalizedString("Turkcell Passcode", comment: "")
    static let settingsViewCellTurkcellAutoLogin = NSLocalizedString("Auto-login", comment: "")
    static let settingsViewLogoutCheckMessage = NSLocalizedString("Are you sure you want to exit the application?", comment: "")
    
    //MARK: Import photos
    static let importPhotos = NSLocalizedString("Import Photos", comment: "")
    static let importFromDB = NSLocalizedString("Import From Dropbox", comment: "")
    static let importFromFB = NSLocalizedString("Import From Facebook", comment: "")
    static let importFromInstagram = NSLocalizedString("Import From Instagram", comment: "")
    static let importFromCropy = NSLocalizedString("Import From Cropy", comment: "")
    
    //MARK: userProfile
    static let userProfileTitle = NSLocalizedString("Your Profile", comment: "")
    static let userProfileNameAndSurNameSubTitle = NSLocalizedString("Name and Surname", comment: "")
    static let userProfileEmailSubTitle = NSLocalizedString("E-Mail", comment: "")
    static let userProfileGSMNumberSubTitle = NSLocalizedString("GSM Number", comment: "")
    static let userProfileBottomLabelText1 = NSLocalizedString("I’d like hear about news and promotions about lifebox occasionally.", comment: "")
    static let userProfileBottomLabelText2 = NSLocalizedString("We promise, we won’t sent you spam.", comment: "")
    static let userProfileWhantToChangePasswordButton = NSLocalizedString("I want to change my password", comment: "")
    static let userProfileEditButton = NSLocalizedString("Edit", comment: "")
    static let userProfileDoneButton = NSLocalizedString("Done", comment: "")
    static let userProfileDataNotСhanged = NSLocalizedString("Data did not changed", comment: "")
    static let userProfileDataNotCorrect = NSLocalizedString("Data is not correct", comment: "")
    
    //MARK: fileInfo
    static let fileInfoFileNameTitle = NSLocalizedString("File Name", comment: "")
    static let fileInfoInfoTitle = NSLocalizedString("File Info", comment: "")
    static let fileInfoFolderSizeTitle = NSLocalizedString("Folder size", comment: "")
    static let fileInfoAlbumSizeTitle = NSLocalizedString("Items", comment: "")
    static let fileInfoFileSizeTitle = NSLocalizedString("File size", comment: "")
    static let fileInfoDurationTitle = NSLocalizedString("Duration", comment: "")
    static let fileInfoDateModifiedTitle = NSLocalizedString("Date modified", comment: "")
    static let fileInfoUploadDateTitle = NSLocalizedString("Upload date", comment: "")
    static let fileInfoTakenDateTitle = NSLocalizedString("Taken date", comment: "")
    static let fileInfoAlbumTitle = NSLocalizedString("Album", comment: "")
    static let fileInfoArtistTitle = NSLocalizedString("Artist", comment: "")
    static let fileInfoTitleTitle = NSLocalizedString("Title", comment: "")
    static let fileInfoAlbumNameTitle = NSLocalizedString("Album Name", comment: "")
    static let fileInfoAlbumInfoTitle = NSLocalizedString("Album Info", comment: "")
    static let fileInfoSave = NSLocalizedString("Save", comment: "")
    
    //MARK: settings User info view
    static let settingsUserInfoViewUpgradeButtonText = NSLocalizedString("UPGRADE", comment: "")
    static let settingsUserInfoViewQuota = NSLocalizedString("%@ of %@ has remained", comment: "")
    
    //MARK: Bacup contacts view
    static let settingsBackupContactsViewTitle = NSLocalizedString("Back Up My Contacts", comment: "")
    static let settingsBackupContactsViewNewContactsText = NSLocalizedString("New Contact", comment: "")
    static let settingsBackupContactsViewDuplicatesText = NSLocalizedString("Updated", comment: "")
    static let settingsBackupContactsViewRemovedText = NSLocalizedString("Removed", comment: "")
    static let settingsBackupedText = NSLocalizedString("Backed up %d Contacts", comment: "")
    static let settingsRestoredText = NSLocalizedString("Restored up %d Contacts", comment: "")
    static let settingsBacupingText = NSLocalizedString("%d%% Backed up…", comment: "")
    static let settingsRestoringText = NSLocalizedString("%d%% Restored up…", comment: "")
    static let settingsBacupNeverDidIt = NSLocalizedString("You can backup your contacts to lifebox. By\ndoing that you can easly access your contact\nlist from any device and anywhere.", comment: "")
    static let settingsBacupNewer = NSLocalizedString("You never backed up your contacts", comment: "")
    static let settingsBacupLessAMinute = NSLocalizedString("Your last back up was a few seconds ago.", comment: "")
    static let settingsBacupLessADay = NSLocalizedString("Your last back was on %@", comment: "")
    static let settingsBacupButtonTitle = NSLocalizedString("Back-Up", comment: "")
    static let settingsBacupRestoreTitle = NSLocalizedString("Restore", comment: "")
    static let settingsBacupClearBacupTitle = NSLocalizedString("Clear Bacup", comment: "")
    static let settingsBacupCancelBacupTitle = NSLocalizedString("Cancel Bacup", comment: "")
    
    //MARK: ActionsMenuAction
    static let actionsMenuActionMove = NSLocalizedString("Move", comment: "")
    static let actionsMenuActionRemoveFromAlbum = NSLocalizedString("Remove from album", comment: "")
    static let actionsMenuActionAddToFavorites = NSLocalizedString("Add to favorites", comment: "")
    static let actionsMenuActionDeleteDeviceOriginal = NSLocalizedString("Delete device original", comment: "")
    static let actionsMenuActionCopy = NSLocalizedString("Copy", comment: "")
    static let actionsMenuActionDocumentDetail = NSLocalizedString("Document Details", comment: "")
    
    //MARK: Create folder
    static let createFolderTitleText = NSLocalizedString("New Folder", comment: "")
    static let createFolderPlaceholderText = NSLocalizedString("Folder Name", comment: "")
    static let createFolderCreateButton = NSLocalizedString("Create", comment: "")
    static let createFolderEmptyFolderNameAlert = NSLocalizedString("Sorry, but folder name should not be empty", comment: "")
    static let createFolderEmptyFolderButtonText = NSLocalizedString("Ok", comment: "")
    
    //MARK: Create story Name
    static let createStoryNameTitle = NSLocalizedString("Create a Name", comment: "")
    static let createStoryNamePlaceholder = NSLocalizedString("Name", comment: "")
    static let createStoryNameSave = NSLocalizedString("SAVE", comment: "")
    static let createStoryEmptyTextError = NSLocalizedString("Sorry, but story name should not be empty", comment: "")
    static let createStorySelectAudioButton = NSLocalizedString("Continue", comment: "")
    
    //MARK: Create story Photos
    static let createStoryPhotosTitle = NSLocalizedString("Photo selection", comment: "")
    static let createStoryPhotosNext = NSLocalizedString("Next", comment: "")
    static let createStoryPhotosMaxCountAllert = NSLocalizedString("Please choose %d files at most", comment: "")
    static let createStoryPhotosMaxCountAllertOK = NSLocalizedString("Ok", comment: "")
    static let createStoryNoSelectedPhotosError = NSLocalizedString("Sorry, but story photos should not be empty", comment: "")
    static let createStoryCreated = NSLocalizedString("Story created", comment: "")
    static let createStoryNotCreated = NSLocalizedString("Story not created", comment: "")
    static let failWhileAddingToAlbum = NSLocalizedString("Fail while adding to album", comment: "")
    static let createStoryMusicEmpty = NSLocalizedString("You did not choose music for your story", comment: "")
    static let createStoryAddMusic = NSLocalizedString("Add music", comment: "")
    
    //MARK: Create story Audio
    static let createStoryNoSelectedAudioError = NSLocalizedString("Sorry, but story audio should not be empty", comment: "")
    static let createStoryAudioSelected = NSLocalizedString("Add Music", comment: "")
    
    
    //MARK: Create story Photo Order
    static let createStoryPhotosOrderNextButton = NSLocalizedString("Create", comment: "")
    static let createStorySave = NSLocalizedString("Save", comment: "")
    static let createStoryPhotosOrderTitle = NSLocalizedString("You can change the sequence ", comment: "")
    
    //MARK: Upload
    static let uploadFilesNextButton = NSLocalizedString("Upload", comment: "")
    static let uploadFilesSingleHeader = NSLocalizedString("Item Selected", comment: "")
    static let uploadFilesMultipleHeader = NSLocalizedString("Items Selected", comment: "")
    static let uploadFilesNothingUploadError = NSLocalizedString("Nothing to upload", comment: "")
    static let uploadFilesNothingUploadOk = NSLocalizedString("Ok", comment: "")
    static let uploadSuccessful = NSLocalizedString("Upload was successful", comment: "")
    static let uploadFailed = NSLocalizedString("Upload failed", comment: "")
    
    //MARK: UploadFromLifeBox
    static let uploadFromLifeBoxTitle = NSLocalizedString("Upload from lifebox", comment: "")
    static let uploadFromLifeBoxNextButton = NSLocalizedString("Next", comment: "")
    static let uploadFromLifeBoxNoSelectedPhotosError = NSLocalizedString("Sorry, but photos not selected", comment: "")
    static let uploadFromLifeBoxEmptyFolderButtonText = NSLocalizedString("Ok", comment: "")
    static let failWhileuploadFromLifeBoxCopy = NSLocalizedString("Fail while uploading from LifeBox", comment: "")
    
    
    //MARK: Select Folder
    static let selectFolderNextButton = NSLocalizedString("Select", comment: "")
    static let selectFolderCancelButton = NSLocalizedString("Cancel", comment: "")
    static let selectFolderBackButton = NSLocalizedString("Back", comment: "")
    static let selectFolderEmptySelectionError = NSLocalizedString("Need to select folder", comment: "")
    static let selectFolderEmptySelectionErrorOK = NSLocalizedString("Ok", comment: "")
    static let selectFolderTitle = NSLocalizedString("Choose a destination folder", comment: "")
    
    //MARK: - TabBar tab lables
    static let home = NSLocalizedString("Home", comment: "")
    static let photoAndVideo = NSLocalizedString("Photos & Videos", comment: "")
    static let music = NSLocalizedString("Music", comment: "")
    static let documents = NSLocalizedString("Documents", comment: "")
    static let tabBarDeleteLabel = NSLocalizedString("Delete", comment: "")
    static let tabBarRemoveAlbumLabel = NSLocalizedString("Remove Album", comment: "")
    static let tabBarRemoveLabel = NSLocalizedString("Remove From Album", comment: "")
    static let tabBarAddToAlbumLabel = NSLocalizedString("Add To Album", comment: "")
    static let tabAlbumCoverAlbumLabel = NSLocalizedString("Make album cover", comment: "")
    static let tabBarEditeLabel = NSLocalizedString("Edit", comment: "")
    static let tabBarPrintLabel = NSLocalizedString("Print", comment: "")
    static let tabBarDownloadLabel = NSLocalizedString("Download", comment: "")
    static let tabBarSyncLabel = NSLocalizedString("Sync", comment: "")
    static let tabBarMoveLabel = NSLocalizedString("Move", comment: "")
    static let tabBarShareLabel = NSLocalizedString("Share", comment: "")
    static let tabBarInfoLabel = NSLocalizedString("Info", comment: "")
    
    //MARK: Select Name
    static let selectNameTitleFolder = NSLocalizedString("New Folder", comment: "")
    static let selectNameTitleAlbum = NSLocalizedString("New Album", comment: "")
    static let selectNameTitlePlayList = NSLocalizedString("New PlayList", comment: "")
    static let selectNameNextButtonFolder = NSLocalizedString("Create", comment: "")
    static let selectNameNextButtonAlbum = NSLocalizedString("Create", comment: "")
    static let selectNameNextButtonPlayList = NSLocalizedString("Create", comment: "")
    static let selectNamePlaceholderFolder = NSLocalizedString("Folder Name", comment: "")
    static let selectNamePlaceholderAlbum = NSLocalizedString("Album Name", comment: "")
    static let selectNamePlaceholderPlayList = NSLocalizedString("Play List Name", comment: "")
    static let selectNameEmptyNameFolder = NSLocalizedString("Sorry, but folder name should not be empty", comment: "")
    static let selectNameEmptyNameAlbum = NSLocalizedString("Sorry, but album name should not be empty", comment: "")
    static let selectNameEmptyNamePlayList = NSLocalizedString("Sorry, but play list name should not be empty", comment: "")
    
    //MARK: Albums
    static let albumsTitle = NSLocalizedString("Albums", comment: "")
    static let selectAlbumButtonTitle = NSLocalizedString("Add", comment: "")
    static let uploadPhotos = NSLocalizedString("Upload Photos", comment: "")
    
    //MARK: Feedback View
    static let feedbackMailTextFormat = NSLocalizedString("Please do not delete the information below. The information will be used to address the problem.\n\nApplication Version: %@\nMsisdn: %@\nCarrier: %@\nDevice:%@\nDevice OS: %@\nLanguage: %@\nLanguage preference: %@\nNetwork Status: %@\nTotal Storage: %lld\nUsed Storage: %lld\nPackages: %@\n", comment: "")
    static let feedbackViewTitle = NSLocalizedString("Thanks for leaving a comment!", comment: "")
    static let feedbackViewSubTitle = NSLocalizedString("Feedback Form", comment: "")
    static let feedbackViewSuggestion = NSLocalizedString("Suggestion", comment: "")
    static let feedbackViewComplaint = NSLocalizedString("Complaint", comment: "")
    static let feedbackViewSubjectFormat = NSLocalizedString("%@ about Lifebox", comment: "")
    static let feedbackViewLanguageLabel = NSLocalizedString("You need to specify your language preference so that we can serve you better.", comment: "")
    static let feedbackViewSendButton = NSLocalizedString("Send", comment: "")
    static let feedbackViewSelect = NSLocalizedString("Select", comment: "")
    static let feedbackEmail = NSLocalizedString("DESTEK-LIFEBOX@TURKCELL.COM.TR", comment: "")
    static let feedbackEmailError = NSLocalizedString("Please configurate email client", comment: "")
    static let feedbackErrorEmptyDataTitle = NSLocalizedString("Error", comment: "")
    static let feedbackErrorTextError = NSLocalizedString("Please type your message", comment: "")
    static let feedbackErrorLanguageError = NSLocalizedString("You need to specify your language preference so that we can serve you better.", comment: "")
    
    
    //MARK: PopUp
    static let popUpProgress = NSLocalizedString("(%ld of %ld)", comment: "")
    static let popUpSyncing = NSLocalizedString("Syncing files over", comment: "")
    static let popUpUploading = NSLocalizedString("Uploading files over", comment: "")
    static let popUpDownload = NSLocalizedString("Downloading files", comment: "")
    static let popUpDeleteComplete = NSLocalizedString("Deleting is complete", comment: "")
    static let popUpDownloadComplete = NSLocalizedString("Download is complete", comment: "")
    static let popUpOperationComplete = NSLocalizedString("Operation is complete", comment: "")
    static let freeAppSpacePopUpTextNormal = NSLocalizedString("There are some duplicated items both in your device and lifebox", comment: "")
    static let freeAppSpacePopUpTextWaring = NSLocalizedString("Your device memory is almost full", comment: "")
    static let freeAppSpacePopUpButtonTitle = NSLocalizedString("Free up space", comment: "")
    static let networkTypeWiFi = NSLocalizedString("Wi-Fi", comment: "")
    static let networkType2g = NSLocalizedString("2G", comment: "")
    static let networkType3g = NSLocalizedString("3G", comment: "")
    static let networkType4g = NSLocalizedString("4G", comment: "")
    static let networkTypeLTE = NSLocalizedString("LTE", comment: "")
    static let autoUploaOffPopUpText = NSLocalizedString("Auto Upload is off.\nGo to setting to auto sync.", comment: "")
    static let autoUploaOffCancel = NSLocalizedString("Cancel", comment: "")
    static let autoUploaOffSettings = NSLocalizedString("Settings", comment: "")
    static let waitingForWiFiPopUpTitle = NSLocalizedString("Waiting for Wi-Fi connection to auto-sync", comment: "")
    static let waitingForWiFiPopUpSettingsButton = NSLocalizedString("Settings", comment: "")
    static let waitingForWiFiPopUpSyncButton = NSLocalizedString("Sync with data plan", comment: "")
    static let prepareToAutoSunc = NSLocalizedString("Auto Sync Preparation", comment: "")
    static let waitForWiFiButtonTitle = NSLocalizedString("Wait for a Wi-Fi Connection", comment: "")
    
    
    //MARK: - ActionSheet
    static let actionSheetDeleteDeviceOriginal = "Delete Device Original"
 
    static let actionSheetCancel = NSLocalizedString("Cancel", comment: "")

    
    static let actionSheetShare = NSLocalizedString("Share", comment: "")
    static let actionSheetInfo = NSLocalizedString("Info", comment: "")
    static let actionSheetEdit = NSLocalizedString("Edit", comment: "")
    static let actionSheetDelete = NSLocalizedString("Delete", comment: "")
    static let actionSheetMove = NSLocalizedString("Move", comment: "")
    static let actionSheetSync = NSLocalizedString("Sync", comment: "")
    static let actionSheetDownload = NSLocalizedString("Download", comment: "")
    
    static let actionSheetShareSmallSize = NSLocalizedString("Small Size", comment: "")
    static let actionSheetShareOriginalSize = NSLocalizedString("Original Size", comment: "")
    static let actionSheetShareShareViaLink = NSLocalizedString("Share Via Link", comment: "")
    static let actionSheetShareCancel = NSLocalizedString("Cancel", comment: "")
    
    static let actionSheetCreateStory = NSLocalizedString("Create a Story", comment: "")
    static let actionSheetCopy = NSLocalizedString("Copy", comment: "")
    static let actionSheetAddToFavorites = NSLocalizedString("Add to Favorites", comment: "")
    static let actionSheetRemove = NSLocalizedString("Remove", comment: "")
    static let actionSheetRemoveFavorites = NSLocalizedString("Remove from Favorites", comment: "")
    static let actionSheetAddToAlbum = NSLocalizedString("Add to album", comment: "")
    static let actionSheetBackUp = NSLocalizedString("Back Up", comment: "")
    static let actionSheetRemoveFromAlbum = NSLocalizedString("Remove from album", comment: "")
    
    static let actionSheetTakeAPhoto = NSLocalizedString("Take Photo", comment: "")
    static let actionSheetChooseFromLib = NSLocalizedString("Choose From Library", comment: "")
    
    static let actionSheetPhotos = NSLocalizedString("Photos", comment: "")
    static let actionSheetiCloudDrive = NSLocalizedString("iCloud Drive", comment: "")
    static let actionSheetLifeBox = NSLocalizedString("lifebox", comment: "")
    static let actionSheetMore = NSLocalizedString("More", comment: "")
    
    static let actionSheetSelect = NSLocalizedString("Select", comment: "")
    static let actionSheetSelectAll = NSLocalizedString("Select All", comment: "")
    
    static let actionSheetRename = NSLocalizedString("Rename", comment: "")
    
    static let actionSheetDocumentDetails = NSLocalizedString("Document Details", comment: "")
    
    static let actionSheetAddToPlaylist = NSLocalizedString("Share Album", comment: "")
    static let actionSheetMusicDetails = NSLocalizedString("Music Dteails", comment: "")
    
    static let actionSheetMakeAlbumCover = NSLocalizedString("Make album covers", comment: "")
    static let actionSheetAlbumDetails = NSLocalizedString("Album Details", comment: "")
    static let actionSheetShareAlbum = NSLocalizedString("Share Album", comment: "")
    static let actionSheetDownloadToCameraRoll = NSLocalizedString("Download to Camera Roll", comment: "")
    
    // MARK: Free Up Space
    static let freeAppSpaceTitle = NSLocalizedString("There are %d duplicated photos both in your device and lifebox. Clear some space by selecting the photos that you want to delete.", comment: "")
    static let freeAppSpaceAlertTitle = NSLocalizedString("Allow lifebox to delete %d photos?", comment: "")
    static let freeAppSpaceAlertText = NSLocalizedString("Some photos will also be deleted from an album.", comment: "")
    static let freeAppSpaceAlertCancel = NSLocalizedString("Cancel", comment: "")
    static let freeAppSpaceAlertDelete = NSLocalizedString("Delete", comment: "")
    static let freeAppSpaceAlertSuccesTitle = NSLocalizedString("You have free space for %d more items.", comment: "")
    static let freeAppSpaceAlertSuccesButton = NSLocalizedString("OK", comment: "")
    
    static let save = NSLocalizedString("Save", comment: "")
    static let cropyMessage = NSLocalizedString("This edited photo will be saved as a new photo in your device gallery", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    
    
    //MARK: -
    
    static let albumLikeSlidertitle = NSLocalizedString("My Stream", comment: "")
    
    // MARK: - ActivityTimeline
    static let activityTimelineFiles = NSLocalizedString("file(s)", comment: "")
    static let activityTimelineTitle = NSLocalizedString("My Activity Timeline", comment: "")
    
    // MARK: - PullToRefresh
    static let pullToRefreshPull = NSLocalizedString("Pull to refresh", comment: "")
    static let pullToRefreshRelease = NSLocalizedString("Release to refresh", comment: "")
    static let pullToRefreshSuccess = NSLocalizedString("Success", comment: "")
    static let pullToRefreshRefreshing = NSLocalizedString("Refreshing...", comment: "")
    static let pullToRefreshFailed = NSLocalizedString("Failed", comment: "")
    
    // MARK: - usageInfo
    static let usageInfoPhotos = NSLocalizedString("%ld photos", comment: "")
    static let usageInfoVideos = NSLocalizedString("%ld videos", comment: "")
    static let usageInfoSongs = NSLocalizedString("%ld songs", comment: "")
    static let usageInfoDocuments = NSLocalizedString("%ld documents", comment: "")
    static let usageInfoBytesRemained = NSLocalizedString("%@ of %@ has remained", comment: "")
    static let usageInfoQuotaInfo = NSLocalizedString("Quota info", comment: "")
    static let usageInfoDocs = NSLocalizedString("%ld docs", comment: "")
    
    // MARK: - offers
    static let offersActivateUkranian = NSLocalizedString("Special prices for lifecell subscribers! To activate lifebox 50GB for 24,99UAH/30 days send SMS with the text 50VKL, for lifebox 500GB for 52,99UAH/30days send SMS with the text 500VKL to the number 8080", comment: "")
    static let offersActivateCyprus = NSLocalizedString("Platinum and lifecell customers can send LIFE, other customers can send LIFEBOX 50GB for lifebox 50GB package, LIFEBOX 500GB for lifebox 500GB package and LIFEBOX 2.5TB for lifebox 2.5TB package to 3030 to start their memberships", comment: "")
    
    static let offersCancelUkranian = NSLocalizedString("To deactivate lifebox 50GB please send SMS with the text 50VYKL, for lifebox 500GB please send SMS with the text 500VYKL to the number 8080", comment: "")
    static let offersCancelCyprus = NSLocalizedString("Platinum and lifecell customers can send LIFE CANCEL, other customers can send LIFEBOX CANCEL to 3030 to cancel their memberships", comment: "")
    static let offersCancelMoldcell = NSLocalizedString("Hm, can’t believe you are doing this! When you decide to reactivate it, we’ll be here for you :) If you insist, sent “STOP” to 2", comment: "")
    static let offersCancelAll = NSLocalizedString("You can visit iTunes to cancel your subscription", comment: "")
    static let offersCancelTurkcell = NSLocalizedString("Please text \"Iptal LIFEBOX %@\" to 2222 to cancel your subscription", comment: "")
    
    static let offersAllCancel = NSLocalizedString("You can open settings and cancel subscption.", comment: "")
    static let offersInfo = NSLocalizedString("Info", comment: "")
    static let offersCancel = NSLocalizedString("Cancel", comment: "")
    static let offersBuy = NSLocalizedString("Buy", comment: "")
    static let offersOk = NSLocalizedString("OK", comment: "")
    static let offersSettings = NSLocalizedString("Settings", comment: "")
    static let offersPrice = NSLocalizedString("%.2f %@ / month", comment: "")
    
    // MARK: - OTP
    static let otpNextButton = NSLocalizedString("Next", comment: "")
    static let otpResendButton = NSLocalizedString("Resend", comment: "")
    static let otpTitleText = NSLocalizedString("Enter the verification code\nsent to your number %@", comment: "")
    
    // MARK: - Errors
    static let errorEmptyEmail = NSLocalizedString("Indicates that the e-mail parameter is sent blank.", comment: "")
    static let errorEmptyPassword = NSLocalizedString("Indicates that the password parameter is sent blank.", comment: "")
    static let errorEmptyPhone = NSLocalizedString("Specifies that the phone number parameter is sent  blank.", comment: "")
    static let errorInvalidEmail = NSLocalizedString("E-mail address is in an invalid format.", comment: "")
    static let errorExistEmail = NSLocalizedString("This e-mail address is already registered. Please enter another e-mail address.", comment: "")
    static let errorVerifyEmail = NSLocalizedString("Indicates that a user with the given e-mail address already exists and login will be  allowed after e-mail address validation.", comment: "")
    static let errorInvalidPhone = NSLocalizedString("Phone number is in an invalid format.", comment: "")
    static let errorExistPhone = NSLocalizedString("A user with the given phone number already exists.", comment: "")
    static let errorInvalidPassword = NSLocalizedString("Password is invalid", comment: "")
    static let errorInvalidPasswordConsecutive = NSLocalizedString("It is not allowed that the password consists of consecutive characters.", comment: "")
    static let errorInvalidPasswordSame = NSLocalizedString("It is not allowed that the password consists of all the same characters.", comment: "")
    static let errorInvalidPasswordLengthExceeded = NSLocalizedString("The password consists of more number of characters than is allowed. The length allowed is provided in the value field of the response.", comment: "")
    static let errorInvalidPasswordBelowLimit = NSLocalizedString("The password consists of less number of characters than is allowed. The length allowed is provided in the value field of the response.", comment: "")
    static let errorManyRequest = NSLocalizedString("It indicates that sending OTP procedure is repeated numerously. It can be tried again later but a short amount of time should be spent before retry.", comment: "")
    
    static let TOO_MANY_REQUESTS = NSLocalizedString("Too many invalid attempts, please try again later", comment: "")
    static let EMAIL_IS_INVALID = NSLocalizedString("E-mail field is invalid", comment: "")
    
    static let errorUnknown = NSLocalizedString("Unknown error", comment: "")
    static let errorServer = NSLocalizedString("Server error", comment: "")
    
    static let errorFileSystemAccessDenied = NSLocalizedString("Can't get access to file system", comment: "")
    static let errorNothingToDownload = NSLocalizedString("Nothing to download", comment: "")
    
    static let canceledOperationTextError = NSLocalizedString("Cancelled", comment: "")
    
    static let ACCOUNT_NOT_FOUND = NSLocalizedString("Account cannot be found", comment: "")
    static let INVALID_PROMOCODE = NSLocalizedString("This package activation code is invalid", comment: "")
    static let PROMO_CODE_HAS_BEEN_ALREADY_ACTIVATED = NSLocalizedString("This package activation code has been used before, please try different code", comment: "")
    static let PROMO_CODE_HAS_BEEN_EXPIRED = NSLocalizedString("This package activation code has expired", comment: "")
    static let PROMO_CODE_IS_NOT_CREATED_FOR_THIS_ACCOUNT = NSLocalizedString("This package activation code is defined for different user", comment: "")
    static let THERE_IS_AN_ACTIVE_JOB_RUNNING = NSLocalizedString("Package activation process is in progress", comment: "")
    static let CURRENT_JOB_IS_FINISHED_OR_CANCELLED = NSLocalizedString("This package activation code has been used before, please try different code", comment: "")
    static let PROMO_IS_NOT_ACTIVATED = NSLocalizedString("This package activation code has not been activated  yet", comment: "")
    static let PROMO_HAS_NOT_STARTED = NSLocalizedString("This package activation code definition time has not yet begun", comment: "")
    static let PROMO_NOT_ALLOWED_FOR_MULTIPLE_USE = NSLocalizedString("You will not be able to use the this package activation code from this campaign for the second time because you have already benefited from it", comment: "")
    static let PROMO_IS_INACTIVE = NSLocalizedString("The package activation code is not active", comment: "")
    
    static let passcode = NSLocalizedString("Passcode", comment: "")
    static let passcodeSettingsSetTitle = NSLocalizedString("Set a Passcode", comment: "")
    static let passcodeSettingsChangeTitle = NSLocalizedString("Change Passcode", comment: "")
    static let passcodeLifebox = NSLocalizedString("lifebox Passcode", comment: "")
    static let passcodeEnter = NSLocalizedString("Please enter your lifebox passcode", comment: "")
    static let passcodeEnterOld = NSLocalizedString("Please enter your lifebox passcode", comment: "")
    static let passcodeEnterNew = NSLocalizedString("Set a Passcode", comment: "")
    static let passcodeConfirm = NSLocalizedString("Please repeate your new lifebox passcode", comment: "")
    static let passcodeChanged = NSLocalizedString("Passcode is changed successfully", comment: "")
    static let passcodeSet = NSLocalizedString("You successfully set your passcode", comment: "")
    static let passcodeDontMatch = NSLocalizedString("Passcodes don't match, please try again", comment: "")
    static let passcodeSetTitle = NSLocalizedString("Set a Passcode", comment: "")
    static let passcodeBiometricsDefault = NSLocalizedString("To enter passcode", comment: "")
    static let passcodeBiometricsError = NSLocalizedString("Please activate %@ from your device settings to use this feature", comment: "")
    static let passcodeEnable = NSLocalizedString("Enable", comment: "")
    static let passcodeFaceID = NSLocalizedString("Face ID", comment: "")
    static let passcodeTouchID = NSLocalizedString("Touch ID", comment: "")
    static let passcodeNumberOfTries = NSLocalizedString("Invalid passcode. %@ attempts left. Please try again", comment: "")
    static let errorConnectedToNetwork = NSLocalizedString("Please check your internet connection is active and Cellular Data is ON under Settings/lifebox.", comment: "")
    
    static let apply = NSLocalizedString("Apply", comment: "")
    static let success = NSLocalizedString("Success", comment: "")
    
    static let promocodeTitle = NSLocalizedString("Lifebox campaign", comment: "")
    static let promocodePlaceholder = NSLocalizedString("Enter your promo code", comment: "")
    static let promocodeError = NSLocalizedString("This package activation code is invalid", comment: "")
    static let promocodeEmpty = NSLocalizedString("Please enter your promo code", comment: "")
    static let promocodeSuccess = NSLocalizedString("Your package is successfully defined", comment: "")
    static let promocodeInvalid = NSLocalizedString("Verification code is invalid.\nPlease try again", comment: "")
    static let promocodeBlocked = NSLocalizedString("Verification code is blocked.\nPlease request a new code", comment: "")
    
    static let packages = NSLocalizedString("Packages", comment: "")
    static let purchase = NSLocalizedString("Purchase", comment: "")
    
    static let deleteFilesText = NSLocalizedString("Deleting these files will remove them from cloud. You won't be able to access them once deleted", comment: "")
    static let deleteAlbums = NSLocalizedString("Deleting this album will remove the files from lifebox. You won't be able to access them once deleted. Are you sure you want to delete?", comment: "")
    static let removeAlbums = NSLocalizedString("Deleting this album will not remove the files from lifebox. You can access these files from Photos tab. Are you sure you want to delete?", comment: "")
    static let removeFromAlbum = NSLocalizedString("This file will be removed only from your album. You can access this file from Photos tab", comment: "")
    
    static let locationServiceDisable = NSLocalizedString("Location services are disabled in your device settings. To use background sync feature of lifebox, you need to enable location services under \"Settings - Privacy - Location Services\" menu.", comment: "")
}


struct NumericConstants {
    //verefy phone screen
    static let vereficationCharacterLimit = 6
    static let vereficationTimerLimit = 120//in seconds
    static let maxVereficationAttempts = 3
    //
    static let maxDetailsLoadingAttempts = 5
    static let detailsLoadingTimeAwait = UInt32(2)
    
    static let countOfLoginBeforeNeedShowUploadOffPopUp = 3
    
    static let numerCellInLineOnIphone: CGFloat = 4
    static let numerCellInDocumentLineOnIphone: CGFloat = 2
    static let iPhoneGreedInset: CGFloat = 2
    static let iPhoneGreedHorizontalSpace: CGFloat = 1
    static let iPadGreedInset: CGFloat = 2
    static let iPadGreedHorizontalSpace: CGFloat = 1
    static let numerCellInLineOnIpad: CGFloat = 8
    static let numerCellInDocumentLineOnIpad: CGFloat = 4
    static let maxNumberPhotosInStory: Int = 20
    static let maxNumberAudioInStory: Int = 1
    static let creationStoryOrderingCountPhotosInLineiPhone: Int = 4
    static let creationStoryOrderingCountPhotosInLineiPad: Int = 6
    static let albumCellListHeight: CGFloat = 100
    
    static let numberOfElementsInSyncRequest: Int = 1000
    
    static let topContentInset: CGFloat = 64
    
    static let animationDuration: Double = 0.3
    
    static let lifeSessionDuration: TimeInterval = 60 * 50 //50 min
    
    static let timeIntervalBetweenAutoSync: TimeInterval = 60*60
    
    static let timeIntervalBetweenAutoSyncAfterOutOfSpaceError: TimeInterval = 60*60*12 // 12 hours

    static let freeAppSpaceLimit = 0.2
    
    static let fourGigabytes: UInt64 = 4 * 1024 * 1024 * 1024
    
    static let scaleTransform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
    
    static let maxRecentSearches: Int = 10
}
