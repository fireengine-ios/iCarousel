//
//  FirebaseAnalyticsLabels.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum GAEventLabel {
    enum FileType {
        case photo
        case video
        case people
        case things
        case places
        case story
        case albums
        case document
        case music
        case folder
        
        var text: String {
            switch self {
            case .photo:
                return "Photo"
            case .video:
                return "Video"
            case .people:
                return "Person"
            case .things:
                return "Thing"
            case .places:
                return "Place"
            case .story:
                return "Story"
            case .albums:
                return "Album"
            case .document:
                return "Document"
            case .music:
                return "Music"
            case .folder:
                return "Folder"
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
    
    enum CaptchaEvent {
        case changeClick
        case voiceClick
        
        var text: String {
            switch self {
            case .changeClick:
                return "Change Click"
            case .voiceClick:
                return "Voice Click"
            }
        }
    }
    
    enum ContactEvent {
        case backup
        case restore
        case deleteDuplicates
        case deleteBackup
        
        var text: String {
            switch self {
            case .backup:
                return "Backup"
            case .restore:
                return "Restore"
            case .deleteDuplicates:
                return "Delete of Duplicate"
            case .deleteBackup:
                return "Delete Backup"
            }
        }
    }
    
    enum QuotaPaymentType {
        case chargeToBill(_ quota: String)
        case appStore(_ quota: String)
        case creditCard(_ quota: String)
        
        var text: String {
            switch self {
            case .chargeToBill(let quota):
                return "Charge to Bill - " + quota
            case .appStore(let quota):
                return "App Store - " + quota
            case .creditCard(let quota):
                return "Credit Card - " + quota
            }
        }
    }
    
    enum OverQuotaType {
        case expandMyStorage(_ checked: Bool = false)
        case deleteFiles(_ checked: Bool = false)
        case cancel(_ checked: Bool = false)
        case skip
        
        var text: String {
            switch self {
            case .expandMyStorage(let checked):
                return checked ? "Expand My Storage - Checked" : "Expand My Storage"
            case .deleteFiles(let checked):
                return checked ? "Delete Files - Checked" : "Delete Files"
            case .cancel(let checked):
                return checked ? "Cancel - Checked" : "Cancel"
            case .skip:
                return "Skip"
            }
        }
    }
    
    enum TBMatikEvent {
        case notification
        case seeTimeline
        case share
        case close
        case letsSee
        case selectAlbum
        case deleteAlbum
        case deletePhoto
        
        var text: String {
            switch self {
            case .notification:
                return "Notification"
            case .seeTimeline:
                return "See Timeline"
            case .share:
                return "Each Channel"
            case .close:
                return "Home Page Card - Cancel"
            case .letsSee:
                return "Home Page Card - Lets see"
            case .selectAlbum:
                return "Album Click"
            case .deleteAlbum:
                return "Album Delete"
            case .deletePhoto:
                return "Photo Delete"
            }
        }
    }
    
    enum SupportFormSubjectLoginEvent {
        case subject1
        case subject2
        case subject3
        case subject4
        case subject5
        case subject6
        case subject7
        
        func text(isSupportForm: Bool) -> String {
            var text = isSupportForm ? "Subject - " : ""
            
            switch self {
            case .subject1: text += "Q1"
            case .subject2: text += "Q2"
            case .subject3: text += "Q3"
            case .subject4: text += "Q4"
            case .subject5: text += "Q5"
            case .subject6: text += "Q6"
            case .subject7: text += "Q7"
            }
            
            return text
        }
    }
    
    enum SupportFormSubjectSignUpEvent {
        case subject1
        case subject2
        case subject3
        
        func text(isSupportForm: Bool) -> String {
            var text = isSupportForm ? "Subject - " : ""
            
            switch self {
            case .subject1: text += "Q1"
            case .subject2: text += "Q2"
            case .subject3: text += "Q3"
            }
            
            return text
        }
    }
    
    enum CampaignEvent {
        case neverParticipated
        case notParticipated
        case limitIsReached
        case otherwise
        
        var text: String {
            switch self {
            case .neverParticipated:
                return "Never participated"
            case .notParticipated:
                return "Not participated to the campaign today"
            case .limitIsReached:
                return "Participation limit is reached"
            case .otherwise:
                return "Otherwise"
            }
        }
    }
    
    enum ProfileChangeType {
        case name
        case surname
        case email
        case birthday
        case address
        case phone
        case password
        case securityQuestion
        
        var text: String {
            switch self {
            case .name:
                return "Name"
            case .surname:
                return "Surname"
            case .email:
                return "E-Mail"
            case .birthday:
                return "Birthday"
            case .address:
                return "Address"
            case .phone:
                return "Phone"
            case .password:
                return "Password"
            case .securityQuestion:
                return "SecurityQuestion"
            }
        }
        
    }
    
    enum PhotoEditEvent {
        case save
        case saveAsCopy
        case resetToOriginal
        case cancel
        case keepEditing
        case discard
        case saveFilter(String)
        case saveAdjustment(PhotoEditAdjustmentType)
        
        var text: String {
            switch self {
            case .save:
                return "Save"
            case .saveAsCopy:
                return "Save as copy"
            case .resetToOriginal:
                return "Reset to original"
            case .cancel, .discard:
                return "Cancel"
            case .keepEditing:
                return "Keep editing"
            case .saveFilter(let filterName):
                return filterName
            case .saveAdjustment(let type):
                return type.text
            }
        }
    }
    
    enum PhotoEditAdjustmentType {
        case adjust
        case light
        case color
        case hsl
        case effect
        
        var text: String {
            switch self {
            case .adjust:
                return "Adjust"
            case .light:
                return "Light"
            case .color:
                return "Color"
            case .hsl:
                return "Color-HSL"
            case .effect:
                return "Effect"
            }
        }
    }
    
    enum PrivateShareEvent {
        case seeAll
        case privateShare
        case apiSuggestion
        case phonebookSuggestion
        case contactPermission(PrivateShareAnalytics.ContactsPermissionType)
        case duration(PrivateShareDuration)
        
        var text: String {
            switch self {
            case .seeAll:
                return "See All"
            case .privateShare:
                return "Private Share"
            case .apiSuggestion:
                return "API Suggestion"
            case .phonebookSuggestion:
                return "Phonebook Suggestion"
            case .contactPermission(let type):
                switch type {
                case .allowed:
                    return "allow"
                case .denied:
                    return "do not allow"
                case .notAskAgain:
                    return "do not ask again"
                }
            case .duration(let duration):
                return duration.rawValue
            }
        }
    }
    
    case empty
    case custom(String)
    
    case success
    case failure
    case result(Error?)
    case feedbackOpen
    case feedbackSend
    case download(FileType)
    case quotaUsed(Int)
    case clickPhoto
    case clickVideo
    case notificationRecieved
    case notificationRead
    case sort(SortedRules)
    case search(String) ///searched word
    case clickOtherTurkcellServices ///This event should be sent after each login (just send after login)
    //
    case importDropbox
    case importFacebook
    case importInstagram
    case importSpotify
    //
    case importSpotifyPlaylist
    case importSpotifyTrack
    case importSpotifyResult(String)
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
    //
    case photosNever
    case photosWifi
    case photosWifiLTE
    case videosNever
    case videosWifi
    case videosWifiLTE
    case captcha(CaptchaEvent)
    case contact(ContactEvent)
    case plusAction(TabBarViewController.Action)
    case shareViaLink
    case shareViaApp(String)
    case login
    case update
    case yes
    case edit
    case save(isSuccess: Bool)
    case send
    case confirm
    case confirmStatus(isSuccess: Bool)
    case resendCode
    case codeResent(isSuccessed: Bool)
    case changeEmail
    case emailChanged(isSuccessed: Bool)
    case later
    case cancel
    case storyOrVideo
    case tbmatik(_ event: TBMatikEvent)
    case paymentType(_ type: QuotaPaymentType)
    case supportLoginForm(_ event: SupportFormSubjectLoginEvent, isSupportForm: Bool)
    case supportSignUpForm(_ event: SupportFormSubjectSignUpEvent, isSupportForm: Bool)
    case clickSecurityQuestion(number: Int)
    case campaign(CampaignEvent)
    case ok
    case viewPeopleAlbum
    case enableFIGrouping
    case becomePremium
    case proceedWithExistingPeople
    case divorceButtonVideo
    case fileTypeOperation(FileType)
    case overQuota(_ event: OverQuotaType)
    case mobilePaymentAction(_ isContinue: Bool)
    case backWithCheck(_ isChecked: Bool)
    case isOn(_ isOn: Bool)
    case back
    case spotify
    case dropbox
    case instagram
    case facebook
    case photoEdit(PhotoEditEvent)
    case widgetOrder(String)
    case restart
    case privateShare(PrivateShareEvent)
    case invitationVideoButton
    case invitationLink
    case copyInvitationLink
    
    var text: String {
        switch self {
        case .empty:
            return ""
        case .custom(let value):
            return value
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        case .result(let error):
            return error == nil ? "Success" : "Failure"
        case .feedbackOpen:
            return "Open"
        case .feedbackSend:
            return "Send"
        case .download(let fileType):
            return fileType.text
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
            case .timeUp, .metaDataTimeUp, .timeUpWithoutSection, .lastModifiedTimeUp:
                return "newest-first"
            case .timeDown, .metaDataTimeDown, .timeDownWithoutSection, .lastModifiedTimeDown:
                return "oldest-first"
            }
        case .search(let searchText): ///searched word
            return searchText
        case .clickOtherTurkcellServices: ///This event should be sent after each login (just send after login)
            return TextConstants.NotLocalized.appName
        //
        case .importDropbox:
            return "Dropbox"
        case .importFacebook:
            return "Facebook"
        case .importInstagram:
            return "Instagram"
        case .importSpotify:
            return "Import from Spotify"
        //
        case .importSpotifyPlaylist:
            return "Import from Spotify Playlist"
        case .importSpotifyTrack:
            return "Import from Spotify Track"
        case .importSpotifyResult(let result):
            return "Import from Spotify \(result)"
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
        //
        case .photosNever:
            return "Photos - Never"
        case .photosWifi:
            return "Photos - Wifi"
        case .photosWifiLTE:
            return "Photos - Wifi&LTE"
        case .videosNever:
            return "Videos - Never"
        case .videosWifi:
            return "Videos - Wifi"
        case .videosWifiLTE:
            return "Videos - Wifi&LTE"
        case .captcha(let captchaEvent):
            return captchaEvent.text
        case .contact(let contantEvent):
            return contantEvent.text
        case .plusAction(let action):
            switch action {
            case .createAlbum:
                return "Create Album"
            case .createFolder:
                return "New Folder"
            case .createStory:
                return "Create Story"
            case .takePhoto:
                return "Use Camera"
            case .upload:
                return "Upload"
            case .uploadFiles:
                return "Upload Files"
            case .uploadDocuments:
                return "Upload Files"
            case .uploadMusic:
                return "Upload Music"
            case .uploadFromApp:
                return "Upload from \(TextConstants.NotLocalized.appName)"
            case .uploadFromAppFavorites:
                return "Upload from \(TextConstants.NotLocalized.appName) Favorites"
            case .importFromSpotify:
                return "Import From Spotify"
            }
        case .shareViaLink:
            return "Share via Link"
        case .shareViaApp(let appName):
            return appName
        case .login:
            return "Login"
        case .update:
            return "Update"
        case .yes:
            return "Yes"
        case .edit:
            return "Edit"
        case .save(isSuccess: let isSuccess):
            return "Save " + (isSuccess ? "Success" : "Failure")
        case .send:
            return "Send"
        case .confirm:
            return "Confirm"
        case .confirmStatus(isSuccess: let isSuccess):
            return "Confirm " + (isSuccess ? "Success" : "Failure")
        case .resendCode:
            return "Resend Code"
        case .codeResent(isSuccessed: let isSuccessed):
            return "Resend Code " + (isSuccessed ? "Success" : "Failure")
        case .changeEmail:
            return "Change Email"
        case .emailChanged(isSuccessed: let isSuccessed):
            return "Change Email " + (isSuccessed ? "Success" : "Failure")
        case .later:
            return "Later"
        case .cancel:
            return "Cancel"
        case .storyOrVideo:
            return "Story / Video"
        case .paymentType(let type):
            return type.text
        case .tbmatik(let event):
            return event.text
        case .supportLoginForm(let event, let isSupportForm):
            return event.text(isSupportForm: isSupportForm)
        case .supportSignUpForm(let event, let isSupportForm):
            return event.text(isSupportForm: isSupportForm)
        case .clickSecurityQuestion(let number):
            return "Q\(number)"
        case .campaign(let event):
            return event.text
        case .ok:
            return "OK"
        case .viewPeopleAlbum:
            return "View People Album"
        case .enableFIGrouping:
            return "Enable F/I Grouping"
        case .becomePremium:
            return "Become Premium"
        case .proceedWithExistingPeople:
            return "Proceed With Existing People"
        case .divorceButtonVideo:
            return "Divorce Button Video"
        case .fileTypeOperation(let fileType):
            return fileType.text
        case .overQuota(let type):
            return type.text
        case .mobilePaymentAction(let isContinue):
            return isContinue ? "Continue" : "Remind Me Later"
        case .backWithCheck(let isChecked):
            return isChecked ? "Back - Checked" : "Back"
        case .isOn(let isOn):
            return isOn ? "On" : "Off"
        case .back:
            return "Back"
        case .spotify:
            return "Spotify"
        case .dropbox:
            return "Dropbox"
        case .instagram:
            return "Instagram"
        case .facebook:
            return "Facebook"
        case .photoEdit(let event):
            return event.text
        case .widgetOrder(let orderName):
            return orderName
        case .restart:
            return "Restart"
        case .privateShare(let event):
            return event.text
        case .invitationVideoButton:
            return "Invitation Video Button"
        case .invitationLink:
            return "Invitation link"
        case .copyInvitationLink:
            return "Copy Invitation Link"
        }
    }
    
    static func getAutoSyncSettingEvent(autoSyncSettings: AutoSyncSetting) -> GAEventLabel {
        switch autoSyncSettings {
        case AutoSyncSetting(syncItemType: .photo, option: .never):
            return .photosNever
        case AutoSyncSetting(syncItemType: .photo, option: .wifiAndCellular):
            return .photosWifiLTE
        case AutoSyncSetting(syncItemType: .photo, option: .wifiOnly):
            return .photosWifi
        case AutoSyncSetting(syncItemType: .video, option: .never):
            return .videosNever
        case AutoSyncSetting(syncItemType: .video, option: .wifiAndCellular):
            return .videosWifiLTE
        case AutoSyncSetting(syncItemType: .video, option: .wifiOnly):
            return .videosWifi
        default:
            return .empty
        }
        
    }
    
}
