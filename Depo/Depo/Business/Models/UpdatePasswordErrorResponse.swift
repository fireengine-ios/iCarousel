//
//  UpdatePasswordErrorResponse.swift
//  Depo
//
//  Created by Maxim Soldatov on 11/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

enum StatusType: String {
    case invalidPassword = "INVALID_PASSWORD"
    case invalidCaptcha = "4001"
    case unknown = "unknown"
}

enum ReasonType: String {
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
            static let minimumCharacterLimit = "minimumCharacterLimit"
            static let sameCharacterLimit = "sameCharacterLimit"
            static let recentHistoryLimit = "recentHistoryLimit"
            static let maximumCharacterLimit = "maximumCharacterLimit"
            static let sequentialCharacterLimit = "sequentialCharacterLimit"
        }
    
    let status: StatusType
    let reason: ReasonType
    var minimumCharacterLimit: Int?
    var sameCharacterLimit: Int?
    var recentHistoryLimit: Int?
    var maximumCharacterLimit: Int?
    var sequentialCharacterLimit: Int?
   
    init(status: StatusType,
         reason: ReasonType,
         minimumCharacterLimit: Int,
         sameCharacterLimit: Int,
         recentHistoryLimit: Int,
         maximumCharacterLimit: Int,
         sequentialCharacterLimit: Int
    ) {
        
        self.status = status
        self.reason = reason
        self.minimumCharacterLimit = minimumCharacterLimit
        self.sameCharacterLimit = sameCharacterLimit
        self.recentHistoryLimit = recentHistoryLimit
        self.maximumCharacterLimit = maximumCharacterLimit
        self.sequentialCharacterLimit = sequentialCharacterLimit
    }
    
    convenience init?(json: JSON) {
         
        let value = json[ResponseKey.value]
        
        let status = StatusType(rawValue: json[ResponseKey.status].stringValue) ?? .unknown
        let reason = ReasonType(rawValue: value[ResponseKey.reason].stringValue) ?? .unknown
        
        let minimumCharacterLimit = value[ResponseKey.minimumCharacterLimit].intValue
        let sameCharacterLimit = value[ResponseKey.sameCharacterLimit].intValue
        let recentHistoryLimit = value[ResponseKey.recentHistoryLimit].intValue
        let maximumCharacterLimit = value[ResponseKey.maximumCharacterLimit].intValue
        let sequentialCharacterLimit = value[ResponseKey.sequentialCharacterLimit].intValue
        
        self.init(status: status,
                  reason: reason,
                  minimumCharacterLimit: minimumCharacterLimit,
                  sameCharacterLimit: sameCharacterLimit,
                  recentHistoryLimit: recentHistoryLimit,
                  maximumCharacterLimit: maximumCharacterLimit,
                  sequentialCharacterLimit: sequentialCharacterLimit  )
    }
}
