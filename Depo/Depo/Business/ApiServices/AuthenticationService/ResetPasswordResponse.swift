//
//  ResetPasswordResponse.swift
//  Depo
//
//  Created by Hady on 8/25/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

typealias ResetPasswordResponse = APIResponse<ResetPassword>

struct ResetPassword: Codable {
    let action: ContinuationAction?
    let referenceToken: String?
    let remainingTimeInMinutes: Int?
    let expectedInputLength: Int?
    let methods: [IdentityVerificationMethod]
}

extension ResetPassword {
    enum ContinuationAction: String, Codable {
        case withAvailableMethods = "CONTINUE_WITH_AVALIABLE_METHODS"
        case withEmailLinkVerification = "CONTINUE_WITH_EMAIL_LINK_VERIFICATION"
        case withRecoveryEmailLinkVerification = "CONTINUE_WITH_RECOVERY_EMAIL_LINK_VERIFICATION"
        case withSMSVerification = "CONTINUE_WITH_SMS_OTP_VERIFICATION"
    }
}
