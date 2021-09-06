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
        case profileRecoveryMail            = "profile_recovery_mail"
        case profileRecoveryMailDescription = "profile_recovery_mail_desc"
        case profileRecoveryMailHint        = "profile_recovery_mail_hint"
    }
}

func localized(_ key: Strings.Profile) -> String {
    return key.localized
}
