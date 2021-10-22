//
//  Strings.swift
//  Depo
//
//  Created by Hady on 9/2/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

func localized(_ key: Strings) -> String {
    return key.localized
}

enum Strings: String, Localizable {

    // MARK: - Delete Account
    case deleteAccountButton = "DELETE_ACC_BTN"
    case deleteAccountDescription = "DELETE_ACC_DESC"
    case deleteAccountFirstPopupTitle = "DELETE_ACC_FIRST_POP_UP_TITLE"
    case deleteAccountFirstPopupMessage = "DELETE_ACC_POP_UP_CONTENT_FIRST"
    case deleteAccountSecondPopupMessage = "DELETE_ACC_POP_UP_CONTENT_SECOND"
    case deleteAccountGSMInput = "DELETE_ACC_INPUT_GSM"
    case deleteAccountPasswordInput = "DELETE_ACC_INPUT_PASS"
    case deleteAccountPasswordError = "DELETE_ACC_PASS_ERROR"
    case deleteAccountThirdPopupTitle = "DELETE_ACC_THIRD_POP_UP_TITLE"
    case deleteAccountThirdPopupMessage = "DELETE_ACC_POP_UP_CONTENT_THIRD"
    case deleteAccountFinalPopupTitle = "DELETE_ACC_FINAL_POP_UP_TITLE"
    case deleteAccountFinalPopupMessage = "DELETE_ACC_POP_UP_CONTENT_FINAL"
    case deleteAccountDeleteButton = "DELETE_ACC_POP_UP_BTN_DELETE"
    case deleteAccountCancelButton = "DELETE_ACC_POP_UP_BTN_CANCEL"
    case deleteAccountContinueButton = "DELETE_ACC_POP_UP_BTN_CONTINUE"
    case deleteAccountConfirmButton = "DELETE_ACC_POP_UP_BTN_CONFIRM"
    case deleteAccountCloseButton = "DELETE_ACC_POP_UP_BTN_CLOSE"
}
