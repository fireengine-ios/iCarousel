//
//  SharingSaveResponseType.swift
//  Depo
//
//  Created by Burak Donat on 31.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

enum SharingSaveResponseType: String, CaseIterable {
    case invalidToken        = "INVALID_PUBLIC_TOKEN"
    case sameAccount         = "SAME_ACCOUNT"
    case anotherSaving       = "ANOTHER_SAVING_IN_PROGESS"
    case invalidRequest      = "INVALID_REQUEST"
    case notRequiredSpace    = "ACCOUNT_HAS_NOT_REQUIRED_SPACE"
    case invalidParentFolder = "INVALID_PARENT_FOLDER"
    case unauthorized        = "UNAUTHORIZED_REQUEST"
    case noContent           = "NO_CONTENT"
    
    var description: String {
        switch self {
        case .invalidToken:
            return localized(.publicShareSaveError)
        case .sameAccount:
            return localized(.publicShareSameAccountError)
        case .anotherSaving:
            return localized(.publicShareMultiprocessError)
        case .invalidRequest:
            return localized(.publicShareSaveError)
        case .notRequiredSpace:
            return localized(.publicShareSaveError)
        case .invalidParentFolder:
            return localized(.publicShareSaveError)
        case .unauthorized:
            return localized(.publicShareSaveError)
        case .noContent:
            return localized(.publicShareFileNotFoundError)
        }
    }
}
