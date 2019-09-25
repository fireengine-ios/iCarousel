//
//  SetSecretQuestionErrors.swift
//  Depo
//
//  Created by Maxim Soldatov on 9/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

enum SetSecretQuestionErrors {
    case invalidCaptcha
    case invalidId
    case invalidAnswer
    case unknown
}

extension SetSecretQuestionErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCaptcha:
            return TextConstants.invalidCaptcha
        case .invalidId:
            return TextConstants.userProfileSecretQuestionInvalidId
        case .invalidAnswer:
            return TextConstants.userProfileSecretQuestionInvalidAnswer
        case .unknown:
            return TextConstants.temporaryErrorOccurredTryAgainLater
        }
    }
}



