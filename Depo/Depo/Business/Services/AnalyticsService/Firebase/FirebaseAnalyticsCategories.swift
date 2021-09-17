//
//  FirebaseAnalyticsCategories.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum GAEventCategory {
    case enhancedEcommerce
    case functions
    case videoAnalytics
    case errors
    case popUp
    case twoFactorAuthentication
    case emailVerification
    case recoveryEmailVerification
    case securityQuestion
    case campaign
    case photoEdit(PhotoEditCategory)
    case sharedFolder

    enum PhotoEditCategory {
        case main
        case filters
        case adjustments
        case popup
        
        var text: String {
            switch self {
            case .main:
                return "Photo Edit Analytics"
            case .filters:
                return "Filter Analytics"
            case .adjustments:
                return "Adjust Analytics"
            case .popup:
                return "POP UP"
            }
        }
    }
    
    var text: String {
        switch self {
        case .enhancedEcommerce:
            return "Enhance Ecommerce"
        case .functions:
            return "Functions"
        case .videoAnalytics:
            return "Video Analytics"
        case .errors:
            return "Errors"
        case .popUp:
            return "POP UP"
        case .twoFactorAuthentication:
            return "Two Factor Authentication"
        case .emailVerification:
            return "E-mail verification"
        case .recoveryEmailVerification:
            return "Recovery E-mail verification"
        case .securityQuestion:
            return "Security Question"
        case .campaign:
            return "Campaign"
        case .photoEdit(let category):
            return category.text
        case .sharedFolder:
            return "Shared Folder"
        }
    }
}
