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
        case resetPasswordYourAccountEmail       = "forgotMyPassword_your_account_email"
        case resetPasswordEnterYourAccountEmail  = "forgotMyPassword_enter_your_account_email"
        case resetPasswordInstructions           = "forgotMyPassword_instructions"
        case resetPasswordEnterValidEmail        = "forgotMyPassword_enter_valid_email"
        case resetPasswordInstructionsOther      = "forgotMyPassword_instructions_other"
        case resetPasswordButtonTitle            = "forgotMyPassword_reset_button"
        case resetPasswordChallenge1Header       = "forgotMyPassword_challange1_header"
        case resetPasswordChallenge1Body         = "forgotMyPassword_challange1_body"
        case resetPasswordPhoneNumber            = "forgotMyPassword_phone_number"
        case resetPasswordMail                   = "forgotMyPassword_mail"
        case resetPasswordRecoveryMail           = "forgotMyPassword_recovery_mail"
        case resetPasswordSecurityQuestion       = "forgotMyPassword_security_question"
        case resetPasswordContinueButton         = "forgotMyPassword_continue"
        case resetPasswordEmailPopupMessage      = "forgotMyPassword_email_popup_message"
    }
}

func localized(_ key: Strings.ResetPassword) -> String {
    return key.localized
}
