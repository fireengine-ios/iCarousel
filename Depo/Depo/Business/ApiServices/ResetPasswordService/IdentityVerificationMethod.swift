//
//  IdentityVerificationMethod.swift
//  Depo
//
//  Created by Hady on 8/26/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

enum IdentityVerificationMethod: Codable {
    case email(email: String)
    case recoveryEmail(email: String)
    case securityQuestion
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
            let content = try container.decode(String.self, forKey: .content)
            self = .email(email: content)
        case "RECOVERY_EMAIL":
            let content = try container.decode(String.self, forKey: .content)
            self = .recoveryEmail(email: content)
        case "SECURITY_QUESTION":
            self = .securityQuestion
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

enum VerificationMethod {
    case eMail
    case recoveryEMail
    case securityQuestion
    case msisdn
    
    var methodString: String {
        switch self {
        case .eMail:
            return "EMAIL"
        case .recoveryEMail:
            return "RECOVERY_EMAIL"
        case .securityQuestion:
            return "SECURITY_QUESTION"
        case .msisdn:
            return "MSISDN"
        }
    }
}
