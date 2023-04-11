//
//  PushNotificationServiceConstants.swift
//  Depo
//
//  Created by Andrei Novikau on 27.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

enum PushNotificationAction: String {
    case main = "main"
    case syncSettings = "sync_settings"
    case packages = "packages"
    case photos = "photos_videos"
    case videos = "videos"
    case stories = "stories"
    case albums = "photos_albums"
    case albumDetail = "photos_album_detail"
    case allFiles = "all_files"
    case music = "music"
    case documents = "documents"
    case contactSync = "contact_sync"
    case periodicContactSync = "periodic_contact_sync"
    case favorites = "favourites"
    case createStory = "create_story"
    case contactUs = "contact_us"
    case usageInfo = "usage_info"
    case autoUpload = "auto_upload"
    case recentActivities = "recent_activities"
    case email = "email"
    case importDropbox = "import_dropbox"
    case socialMedia = "social_media"
    case faq = "faq"
    case passcode = "passcode"
    case loginSettings = "login_settings"
    case faceImageRecognition = "face_image_recognition"
    case people = "people"
    case things = "things"
    case places = "places"
    case http = "http"
    case login = "login"
    case search = "search"
    case freeUpSpace = "free_up_space" //TODO: check tag after implement on server
    case home = "home_page"
    case settings = "settings"
    case profileEdit = "profile_edit"
    case changePassword = "change_password"
    case photopickHistory = "photopick_history"
    case myStorage = "my_storage"
    case becomePremium = "become_premium"
    case tbmatic = "TBMatik"
    case securityQuestion = "security_question"
    case permissions = "permissions"
    case photopickCampaignDetail = "photopick_campaign_detail"
    case supportFormLogin = "support_form_login"
    case supportFormSignup = "support_form_signup"
    case trashBin = "trash_bin"
    case hiddenBin = "hidden_bin"
    case silent = "silent"
    case saveToMyLifebox = "save_to_my_lifebox"
    
    case widgetLogout = "widget_logout"
    case widgetQuota = "widget_quota"
    case widgetFreeUpSpace = "widget_free_up_space"
    case widgetUnsyncedFiles = "widget_unsynced_files"
    case widgetAutoSyncDisabled = "widget_autosync_disabled"
    case widgetSyncInProgress = "widget_sync_in_progress"
    case widgetNoBackup = "widget_no_backup"
    case widgetOldBackup = "widget_old_backup"
    case widgetFIR = "widget_fir"
    case widgetFIRLess3People = "widget_fir_less_then_3_photos"
    case widgetFIRDisabled = "widget_fir_disabled"
    case widgetFIRStandart = "widget_fir_standart"
    
    case sharedWithMe = "shared_with_me"
    case sharedByMe = "shared_by_me"
    case invitation = "invitation"
    case chatbot = "chatbot"
    case verifyEmail = "verify_email"
    case verifyRecoveryEmail = "verify_recovery_email"
    case brandAmbassador = "markaelcisi"
    case foryou = "seninicin"

    var fromWidget: Bool {
        isContained(in: [.widgetLogout,
                         .widgetQuota,
                         .widgetFreeUpSpace,
                         .widgetUnsyncedFiles,
                         .widgetAutoSyncDisabled,
                         .widgetSyncInProgress,
                         .widgetNoBackup,
                         .widgetOldBackup,
                         .widgetFIR,
                         .widgetFIRLess3People,
                         .widgetFIRDisabled,
                         .widgetFIRStandart])
    }
}

enum PushNotificationParameter: String {
    case action = "action"
    case pushType = "push_type"
    case tbmaticUuids = "tbt_file_list"
    case netmeraParameters = "prms"
}

enum UniversalLinkPath: String {
 
    case sharedWithMe = "shared/with-me"
    case sharedByMe = "shared/by-me"
    
    var action: PushNotificationAction {
        switch self {
        case .sharedWithMe:
            return .sharedWithMe
        case .sharedByMe:
            return .sharedByMe
        }
    }
    
}

enum DeepLinkParameter: String {
    case affiliate = "affiliate" // ex: packages?affiliate=campaign1
    case albumUUID = "albumUUID"
    case publicToken = "public_token" // public shared items
    case paycellCampaign = "paycell_campaign" // campaign name like affiliate
    case paycellToken = "referer_token" // provider user's token
}
