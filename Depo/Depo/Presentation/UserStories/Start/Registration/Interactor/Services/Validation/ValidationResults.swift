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
    ///Unused (see UserValidator)
//    case phoneNotValid
    case mailIsEmpty
    case phoneIsEmpty
    case passwordIsEmpty
    case passwordMissingNumbers
    case passwordMissingLowercase
    case passwordMissingUppercase
    case passwordExceedsSameCharactersLimit(limit: Int)
    case passwordExceedsSequentialCharactersLimit(limit: Int)
    case passwordExceedsMaximumLength(maxLength: Int)
    case passwordBelowMinimumLength(minLength: Int)
    case repasswordIsEmpty
    case passwordsNotMatch
    case captchaIsEmpty
}
