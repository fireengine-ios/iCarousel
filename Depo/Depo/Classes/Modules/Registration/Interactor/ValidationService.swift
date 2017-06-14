//
//  ValidationService.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit


class UserValidator {
    
    func isUserInfoValid(mail: String, phone: String, password: String, repassword: String) -> Bool {
        if phone.characters.count < 10 {
            self.showAlert(withText: NSLocalizedString("MsisdnFormatErrorMessage", comment: ""))
            return false
        }
        if password.characters.count == 0 {
            self.showAlert(withText: NSLocalizedString("PassFormatErrorMessage", comment: ""))
            return false
        }
        if mail.characters.count == 0 && Util.isValidEmail(mail) == false, Util.isValidEmail(mail) == false {
            self.showAlert(withText: NSLocalizedString("EmailFormatErrorMessage", comment: ""))
            return false
        }
        if password != repassword {
            self.showAlert(withText: NSLocalizedString("PassMismatchErrorMessage", comment: ""))
            return false
        }
        return true
    }
    
    private func showAlert(withText text: String) {
        guard let appDelegate = UIApplication.shared.delegate else {
            return
        }
        guard let window = appDelegate.window else {
            return
        }
        let customAlert = CustomAlertView.init(frame: CGRect(x:0, y:0,
                                           width: window!.frame.size.width,
                                           height: window!.frame.size.height),
                             withTitle: "ERROR", withMessage: text, with: ModalTypeError)
        (appDelegate as! AppDelegate).showCustomAlert(customAlert)
        
//        appDelegate.show
//        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
    }
    
}
