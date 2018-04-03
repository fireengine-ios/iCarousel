//
//  ServerMessageError.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class ServerMessageError {
    let message: String
    let code: Int
    
    init(message: String, code: Int) {
        self.message = message
        self.code = code
    }
    
    private enum ErrorKeys {
        static let accountNotFoundForEmail = "ACCOUNT_NOT_FOUND_FOR_EMAIL"
    }
}
extension ServerMessageError: LocalizedError {
    var errorDescription: String? {
        switch message {
        case ErrorKeys.accountNotFoundForEmail:
            return TextConstants.forgotPasswordErrorNotRegisteredText
        default:
            return message
        }
    }
}
