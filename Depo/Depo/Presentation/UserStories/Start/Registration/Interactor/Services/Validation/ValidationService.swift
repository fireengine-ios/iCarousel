//
//  ValidationService.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit


class UserValidator {
    
    let regularExpressionPassword = "^(?=.*\\d)(?=.*[a-zA-Z]).{5,16}$"//"^(?!\\D*\\d{3,}\\D*)(?![^A-Za-z]*[A-Za-z]{3,}[^A-Za-z]*).{5,16}$"
    //"^(?=.*\\d)(?=.*[a-zA-Z]).{5,16}$" // At least one digit, one lowcase pr one uppercase latter, more than 6 less than 16
    let regularExpressionMail = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{1,}$"
    let regularExpressionSimplePass = "^(?=.).{5,16}$"
    
    func validateUserInfo(mail: String, code: String, phone: String, password: String, repassword: String) -> [UserValidationResults] {

        let regularExpressionPassword: NSRegularExpression? = try? NSRegularExpression(pattern: self.regularExpressionSimplePass, options: .dotMatchesLineSeparators)
        let regularExpressionMailVer: NSRegularExpression? = try? NSRegularExpression(pattern: self.regularExpressionMail, options: .dotMatchesLineSeparators)
            
        var warningsArray: [UserValidationResults] = []
        
        let mailLenght = mail.count
        if mail.isEmpty {
            warningsArray.append(.mailIsEmpty)
        } else if (regularExpressionMailVer?.matches(in: mail, options: .reportCompletion, range: NSMakeRange(0, mailLenght)).count)! == 0 {
            warningsArray.append(.mailNotValid)
        }
        
        if phone.isEmpty || code.isEmpty {//< 10 {
            warningsArray.append(.phoneIsEmpty)//phoneNotValid)
        }
        
        let passwordLenght = password.count
        if password.isEmpty {
            warningsArray.append(.passwordIsEmpty)
        } else if regularExpressionPassword?.matches(in: password, options: .reportCompletion, range: NSMakeRange(0,passwordLenght)).count == 0 {
            warningsArray.append(.passwordNotValid)
        }
        
        if repassword.isEmpty {
            warningsArray.append(.repasswordIsEmpty)
        } else if password != repassword {
            warningsArray.append(.passwodsNotMatch)
        }
        
        if warningsArray.isEmpty {
            return []//.allValid
        }
        return warningsArray
    }
}
