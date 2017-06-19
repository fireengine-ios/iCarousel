//
//  ValidationService.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit


class UserValidator {
    
    func validateUserInfo(mail: String, phone: String, password: String, repassword: String) -> UserValidationResults {
        if mail.characters.count == 0 && !Util.isValidEmail(mail) {
            //            self.showAlert(withText: NSLocalizedString("EmailFormatErrorMessage", comment: ""))
            return .mailNotValid
        }
        if phone.characters.count < 10 {
//            self.showAlert(withText: NSLocalizedString("MsisdnFormatErrorMessage", comment: ""))
            return .phoneNotValid
        }
        if password.characters.count == 0 {
//            self.showAlert(withText: NSLocalizedString("PassFormatErrorMessage", comment: ""))
            return .passwordNotValid
        }
        if password != repassword {
//            self.showAlert(withText: NSLocalizedString("PassMismatchErrorMessage", comment: ""))
            return .passwodsNotMatch
        }
        return .allValid
    }
}
