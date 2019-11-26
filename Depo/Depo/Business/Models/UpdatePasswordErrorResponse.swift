//
//  UpdatePasswordErrorResponse.swift
//  Depo
//
//  Created by Maxim Soldatov on 11/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

enum UpdatePasswordErrorStatusType: String {
    case invalidPassword = "INVALID_PASSWORD"
    case invalidCaptcha = "4001"
}

enum UpdatePasswordErrorReasonType: String {
    case passwordIsEmpty = "PASSWORD_FIELD_IS_EMPTY"
    case sequentialCharacters = "SEQUENTIAL_CHARACTERS"
    case sameCharacters = "SAME_CHARACTERS"
    case passwordLengthExceeded = "PASSWORD_LENGTH_EXCEEDED"
    case passwordLengthIsBelowLimit = "PASSWORD_LENGTH_IS_BELOW_LIMIT"
    case resentPassword = "PASSWORD_IN_RECENT_HISTORY"
    case uppercaseMissing = "UPPERCASE_MISSING"
    case lowercaseMissing = "LOWERCASE_MISSING"
    case numberMissing = "NUMBER_MISSING"
}

final class UpdatePasswordErrorResponse: Map {
    
    private enum ResponseKey {
        static let status = "status"
        static let value = "value"
        static let reason = "reason"
        static let sequentialCharacterLimitKey = "sequentialCharacterLimit"
        static let sameCharacterLimit = "sameCharacterLimit"
        static let recentHistoryLimit = "recentHistoryLimit"
        static let minimumCharacterLimit = "minimumCharacterLimit"
        static let maximumCharacterLimit = "maximumCharacterLimit"
    }
    
    let status: UpdatePasswordErrorStatusType?
    let reason: UpdatePasswordErrorReasonType?
    let sequentialCharacterLimit: Int
    let sameCharacterLimit: Int
    let recentHistoryLimit: Int
    let minimumCharacterLimit: Int
    let maximumCharacterLimit: Int

    init(json: JSON) {
        
        let value = json[ResponseKey.value]
        
        status = UpdatePasswordErrorStatusType(rawValue: json[ResponseKey.status].stringValue) 
        reason = UpdatePasswordErrorReasonType(rawValue: value[ResponseKey.reason].stringValue)
        minimumCharacterLimit = value[ResponseKey.minimumCharacterLimit].intValue
        maximumCharacterLimit = value[ResponseKey.maximumCharacterLimit].intValue
        sequentialCharacterLimit = value[ResponseKey.sequentialCharacterLimitKey].intValue
        sameCharacterLimit = value[ResponseKey.sameCharacterLimit].intValue
        recentHistoryLimit = value[ResponseKey.recentHistoryLimit].intValue
    }
}
