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
    case unknown = "unknown"
}

enum UpdatePasswordErrorReasonType: String {
    case resentPassword = "PASSWORD_IN_RECENT_HISTORY"
    case uppercaseMissing = "UPPERCASE_MISSING"
    case lowercaseMissing = "LOWERCASE_MISSING"
    case numberMissing = "NUMBER_MISSING"
    case unknown = "unknown"
}

final class UpdatePasswordErrorResponse {
    
        private enum ResponseKey {
            static let status = "status"
            static let value = "value"
            static let reason = "reason"
        }
    
    let status: UpdatePasswordErrorStatusType
    let reason: UpdatePasswordErrorReasonType

    init(status: UpdatePasswordErrorStatusType, reason: UpdatePasswordErrorReasonType ) {
        self.status = status
        self.reason = reason
    }
    
    convenience init?(json: JSON) {
         
        let value = json[ResponseKey.value]
        
        let status = UpdatePasswordErrorStatusType(rawValue: json[ResponseKey.status].stringValue) ?? .unknown
        let reason = UpdatePasswordErrorReasonType(rawValue: value[ResponseKey.reason].stringValue) ?? .unknown
        
        self.init(status: status, reason: reason)
    }
}
