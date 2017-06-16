//
//  ValidationService.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit


class UserValidator {
    // TODO : Incorrect logic need return to Presenter !!!!
    func isUserInfoValid(mail: String, phone: String, password: String, repassword: String) -> Bool {
        
        if phone.characters.count < 10 {
//            self.showAlert(withText: NSLocalizedString("MsisdnFormatErrorMessage", comment: ""))
            return false
        }
        if password.characters.count == 0 {
//            self.showAlert(withText: NSLocalizedString("PassFormatErrorMessage", comment: ""))
            return false
        }
        if mail.characters.count == 0 && !Util.isValidEmail(mail) {
//            self.showAlert(withText: NSLocalizedString("EmailFormatErrorMessage", comment: ""))
            return false
        }
        if password != repassword {
//            self.showAlert(withText: NSLocalizedString("PassMismatchErrorMessage", comment: ""))
            return false
        }
        return true
    }
}
