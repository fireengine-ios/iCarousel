//
//  ValidationResults.swift
//  Depo
//
//  Created by Aleksandr on 6/18/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum UserValidationResults: Equatable {
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
    case passwordExceedsSameCharactersLimit
    case passwordExceedsSequentialCharactersLimit
    case passwordExceedsMaximumLength
    case passwordBelowMinimumLength
    case repasswordIsEmpty
    case passwordsNotMatch
    case captchaIsEmpty
}
