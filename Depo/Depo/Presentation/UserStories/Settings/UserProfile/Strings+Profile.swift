//
//  Strings+UserProfile.swift
//  Depo
//
//  Created by Hady on 9/2/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

extension Strings {
    enum Profile: String, Localizable {
        case profileRecoveryMail                        = "profile_recovery_mail"
        case profileRecoveryMailDescription             = "profile_recovery_mail_desc"
        case profileRecoveryMailHint                    = "profile_recovery_mail_hint"
        case profileMailVerified                        = "profile_mail_verified"
        case profileVerifyButtonTitle                   = "profile_verify"
        case profileRecoveryEmailIsEmpty                = "profile_recovery_email_empty"
        case profileRecoveryEmailIsInvalid              = "profile_recovery_email_invalid"
        case profileRecoveryEmailIsSameWithAccountEmail = "profile_recovery_email_is_same_with_account_email"
    }
}

func localized(_ key: Strings.Profile) -> String {
    return key.localized
}
