//
//  CustomOperationErrors.swift
//  Depo
//
//  Created by Alex Developer on 03.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

enum OperationError {
    case unknown
    case serverError(CustomStringConvertible)
    case text(String)
    case cancelled
}
extension OperationError: LocalizedError {
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
        case .cancelled:
            return "Operation got cancelled"
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
