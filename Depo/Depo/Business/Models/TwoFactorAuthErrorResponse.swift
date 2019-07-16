//
//  TwoFactorAuthErrorResponse.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/15/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class TwoFactorAuthErrorResponseChallengeType {
    
    private enum TwoFactorAuthErrorResponseChallengeTypeKey {
        static let token = "token"
        static let type = "type"
        static let authenticatorId = "authenticatorId"
        static let displayName = "displayName"
        static let otpCode = "otpCode"
    }
    
    var token: Int?
    var type: AvailableTypes?
    var authenticatorId: String?
    var displayName: String?
    var otpCode: Int?
    
    convenience init(json: JSON) {
        self.init()
        token = json[TwoFactorAuthErrorResponseChallengeTypeKey.token].intValue
        type = AvailableTypes(rawValue: json[TwoFactorAuthErrorResponseChallengeTypeKey.type].stringValue)
        authenticatorId = json[TwoFactorAuthErrorResponseChallengeTypeKey.authenticatorId].stringValue
        displayName = json[TwoFactorAuthErrorResponseChallengeTypeKey.displayName].stringValue
        otpCode = json[TwoFactorAuthErrorResponseChallengeTypeKey.otpCode].intValue
    }
}

final class TwoFactorAuthErrorResponse {
    
    private enum TwoFactorAuthErrorResponseKey {
        static let reason = "reason"
        static let error = "error"
        static let twoFAToken = "2faToken"
        static let challengeTypes = "challengeTypes"
    }
    
    var reason: ReasonForExtraAuth?
    var error: String?
    var twoFAToken: String?
    var challengeTypes: [TwoFactorAuthErrorResponseChallengeType]?
    
}

extension TwoFactorAuthErrorResponse: Map {
    
    convenience init?(json: JSON) {
        self.init()
        reason = ReasonForExtraAuth(rawValue: json[TwoFactorAuthErrorResponseKey.reason].stringValue)
        error = json[TwoFactorAuthErrorResponseKey.error].stringValue
        twoFAToken = json[TwoFactorAuthErrorResponseKey.twoFAToken].stringValue
        challengeTypes = json[TwoFactorAuthErrorResponseKey.challengeTypes].arrayValue.map { TwoFactorAuthErrorResponseChallengeType(json: $0)}
    }
}
