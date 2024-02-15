//
//  ResetPasswordResponse.swift
//  Depo
//
//  Created by Hady on 8/25/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

typealias ResetPasswordResponse = ResetPassword

struct ResetPassword: Codable {
    let action: ContinuationAction?
    let referenceToken: String?
    let remainingTimeInMinutes: Int?
    let expectedInputLength: Int?
    let methods: [IdentityVerificationMethod]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        action = try? container.decodeIfPresent(ContinuationAction.self, forKey: .action)
        referenceToken = try container.decodeIfPresent(String.self, forKey: .referenceToken)
        remainingTimeInMinutes = try container.decodeIfPresent(Int.self, forKey: .remainingTimeInMinutes)
        expectedInputLength = try container.decodeIfPresent(Int.self, forKey: .expectedInputLength)
        methods = try container.decodeIfPresent([IdentityVerificationMethod].self, forKey: .methods) ?? []
    }
}

extension ResetPassword {
    enum ContinuationAction: String, Codable {
        case withAvailableMethods = "CONTINUE_WITH_AVALIABLE_METHODS"
        case withEmailLinkVerification = "CONTINUE_WITH_EMAIL_LINK_VERIFICATION"
        case withRecoveryEmailLinkVerification = "CONTINUE_WITH_RECOVERY_EMAIL_LINK_VERIFICATION"
        case withSMSVerification = "CONTINUE_WITH_SMS_OTP_VERIFICATION"
    }
}
