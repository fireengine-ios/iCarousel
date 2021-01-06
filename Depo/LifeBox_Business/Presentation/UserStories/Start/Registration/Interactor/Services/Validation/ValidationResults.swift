//
//  ValidationResults.swift
//  Depo
//
//  Created by Aleksandr on 6/18/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum UserValidationResults {
    ///Unused (see UserValidator)
//    case allValid
    case mailNotValid
    case passwordNotValid
    case passwodsNotMatch
    ///Unused (see UserValidator)
//    case phoneNotValid
    case mailIsEmpty
    case phoneIsEmpty
    case passwordIsEmpty
    case repasswordIsEmpty
    case captchaIsEmpty
}
