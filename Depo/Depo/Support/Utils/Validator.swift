//
//  Validator.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class Validator {
    
    static func isValid(email: String?) -> Bool {
        guard let email = email else {
            return false
        }
        let emailRegEx = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func isValid(phone: String) -> Bool {
        var phoneNumber = phone.filter { $0 != "(" && $0 != ")" }
        if !phone.contains("+") {
            phoneNumber = "+" + phoneNumber
        }
        let phoneRegEx = "^((\\+)|(00))[0-9]{4,18}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        let result = phoneTest.evaluate(with: phoneNumber)
        return result
    }
}
