//
//  Strings+ResetPassword.swift
//  Depo
//
//  Created by Hady on 8/24/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

extension Strings {
    enum ResetPassword: String, Localizable {
        case resetPasswordTitle                  = "reset_password"
        case resetPasswordInfoTurkcell           = "If you are already a Turkcell subscriber, you can obtain your password by sending free SMS containing SIFRE to 2222."
        case resetPasswordCaptchaPlaceholder     = "enter_the_text_shown_in_the_image"
        case resetPasswordErrorCaptchaFormatText = "Please type the text"
        case resetPasswordErrorCaptchaText       = "This text doesn't match. Please try again"

        // keys with prefix
        case resetPasswordYourAccountEmail       = "your_account_email"
        case resetPasswordEnterYourAccountEmail  = "enter_your_account_email"
        case resetPasswordInstructions           = "instructions"
        case resetPasswordEnterValidEmail        = "enter_valid_email"
        case resetPasswordInstructionsOther      = "instructions_other"
        case resetPasswordButtonTitle            = "reset_button"

        var localizationKey: String {
            switch self {
            case .resetPasswordTitle,
                 .resetPasswordInfoTurkcell,
                 .resetPasswordCaptchaPlaceholder,
                 .resetPasswordErrorCaptchaFormatText,
                 .resetPasswordErrorCaptchaText:
                return rawValue

            case .resetPasswordYourAccountEmail,
                 .resetPasswordEnterYourAccountEmail,
                 .resetPasswordInstructions,
                 .resetPasswordEnterValidEmail,
                 .resetPasswordInstructionsOther,
                 .resetPasswordButtonTitle:
                return "forgotMyPassword_" + rawValue
            }
        }
    }
}

func localized(_ key: Strings.ResetPassword) -> String {
    return key.localized
}
