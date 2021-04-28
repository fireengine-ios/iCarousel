//
//  CustomErrors.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum CustomErrors {
    case unknown
    case serverError(CustomStringConvertible)
    case text(String)
}
extension CustomErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .text(let str):
            return str
        case .serverError(let text):
            #if DEBUG
                return TextConstants.errorServer + ": " + text.description 
            #else
                return TextConstants.errorServer
            #endif
        }
    }
    
    var localizedDescription: String {
        guard let errorDescription = errorDescription else {
            return TextConstants.temporaryErrorOccurredTryAgainLater
        }

        if errorDescription.contains("\(errorCode)") == true {
            return TextConstants.temporaryErrorOccurredTryAgainLater
        } else {
            return errorDescription
        }
    }
}
