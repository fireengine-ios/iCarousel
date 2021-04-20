//
//  PushNotificationServiceConstants.swift
//  Depo
//
//  Created by Andrei Novikau on 27.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

enum PushNotificationAction: String {
    case http = "http"
    case myDisk = "my_disk"
    case settings = "settings"
    case agreements = "agreements"
    case faq = "faq"
    case profile = "profile"
    case trashBin = "trash_bin"
    case sharedWithMe = "shared_with_me"
    case sharedByMe = "shared_by_me"
    case sharedArea = "shared_area"
}

enum PushNotificationParameter: String {
    case action = "action"
    case pushType = "push_type"
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
