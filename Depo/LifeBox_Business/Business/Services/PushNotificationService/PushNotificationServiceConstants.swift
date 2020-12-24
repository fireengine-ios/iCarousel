//
//  PushNotificationServiceConstants.swift
//  Depo
//
//  Created by Andrei Novikau on 27.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

enum PushNotificationAction: String {
    case main = "main"
    case floatingMenu = "floating_menu"
    case allFiles = "all_files"
    case music = "music"
    case documents = "documents"
    case favorites = "favourites"
    case contactUs = "contact_us"
    case usageInfo = "usage_info"
    case recentActivities = "recent_activities"
    case email = "email"
    case faq = "faq"
    case passcode = "passcode"
    case loginSettings = "login_settings"
    case http = "http"
    case login = "login"
    case search = "search"
    case home = "home_page"
    case settings = "settings"
    case profileEdit = "profile_edit"
    case changePassword = "change_password"
    case tbmatic = "TBMatik"
    case securityQuestion = "security_question"
    case permissions = "permissions"
    case supportFormLogin = "support_form_login"
    case supportFormSignup = "support_form_signup"
    case trashBin = "trash_bin"
    
    case sharedWithMe = "shared_with_me"
    case sharedByMe = "shared_by_me"
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
