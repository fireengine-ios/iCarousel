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
    let methods: [Method]
}

extension ResetPassword {
    enum ContinuationAction: String, Codable {
        case withAvailableMethods = "CONTINUE_WITH_AVALIABLE_METHODS"
        case withEmailLinkVerification = "CONTINUE_WITH_EMAIL_LINK_VERIFICATION"
        case withRecoveryEmailLinkVerification = "CONTINUE_WITH_RECOVERY_EMAIL_LINK_VERIFICATION"
        case withSMSVerification = "CONTINUE_WITH_SMS_OTP_VERIFICATION"
    }
}

extension ResetPassword {
    enum Method: Codable {
        case email(email: String)
        case recoveryEmail(email: String)
        case securityQuestion(id: Int)
        case sms(phone: String)
        case unknown

        enum CodingKeys: String, CodingKey {
            case method = "method"
            case content = "content"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let method = try container.decode(String.self, forKey: .method)
            switch method {
            case "EMAIL":
                let content = try container.decode(String.self, forKey: .method)
                self = .email(email: content)
            case "RECOVERY_EMAIL":
                let content = try container.decode(String.self, forKey: .method)
                self = .recoveryEmail(email: content)
            case "SECURITY_QUESTION":
                let content = try container.decode(Int.self, forKey: .method)
                self = .securityQuestion(id: content)
            case "MSISDN":
                let content = try container.decode(String.self, forKey: .content)
                self = .sms(phone: content)
            default:
                self = .unknown
            }
        }

        func encode(to encoder: Encoder) throws {

        }
    }
}
