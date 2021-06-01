//
//  ValidationService.swift
//  Depo
//
//  Created by Aleksandr on 6/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit


class UserValidator {
    
    private static let passwordMinLength = 6
    private static let passwordMaxLength = 16
    private static let passwordSameCharacterLimit = 2
    private static let passwordSequentialCharacterLimit = 2

    let regularExpressionMail = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{1,}$"
    
    func validateUserInfo(mail: String,
                          code: String,
                          phone: String,
                          password: String,
                          repassword: String,
                          captchaAnswer: String?) -> [UserValidationResults] {

        let regularExpressionMailVer: NSRegularExpression? = try? NSRegularExpression(pattern: self.regularExpressionMail,
                                                                                      options: .dotMatchesLineSeparators)

        var warningsArray: [UserValidationResults] = []
        
        let mailLenght = mail.count
        if mail.isEmpty {
            warningsArray.append(.mailIsEmpty)
        } else if (regularExpressionMailVer?.matches(in: mail, options: .reportCompletion, range: NSRange(location: 0, length: mailLenght)).count)! == 0 {
            warningsArray.append(.mailNotValid)
        }
        
        if phone.isEmpty || code.isEmpty {//< 10 {
            warningsArray.append(.phoneIsEmpty)//phoneNotValid)
        }

        warningsArray.append(
            contentsOf: validatePassword(password, repassword: repassword)
        )
        
        if let captchaAnswer = captchaAnswer, captchaAnswer.isEmpty {
            warningsArray.append(.captchaIsEmpty)
        }
        
        if warningsArray.isEmpty {
            return []//.allValid
        }
        return warningsArray
    }

    func validatePassword(_ password: String, repassword: String? = nil) -> [UserValidationResults] {
        if password.isEmpty {
            return [.passwordIsEmpty]
        }

        let minimumLength = Self.passwordMinLength
        if password.count < minimumLength {
            return [.passwordBelowMinimumLength(minLength: minimumLength)]
        }

        let maximumLength = Self.passwordMaxLength
        if password.count > maximumLength {
            return [.passwordExceedsMaximumLength(maxLength: maximumLength)]
        }

        if !password.contains(where: { $0.isUppercase }) {
            return [.passwordMissingUppercase]
        }

        if !password.contains(where: { $0.isLowercase }) {
            return [.passwordMissingLowercase]
        }

        if !password.contains(where: { $0.isNumber }) {
            return [.passwordMissingNumbers]
        }

        let sameOrSequentialErrors = checkForSameOrSequentialChar(in: password)
        if !sameOrSequentialErrors.isEmpty {
            return sameOrSequentialErrors
        }

        // Validate repassword as well (if passed)
        if let repassword = repassword {
            if repassword.isEmpty {
                return [.repasswordIsEmpty]
            }

            if repassword != password {
                return [.passwordsNotMatch]
            }
        }

        return []
    }

    private func checkForSameOrSequentialChar(in password: String) -> [UserValidationResults] {
        var sequence = 1, same = 1, revSequence = 1

        let passwordArray = Array(password)
        for i in 0 ..< passwordArray.count - 1 {
            let current = passwordArray[i]
            let after = passwordArray[i + 1]

            if after == current {
                same += 1
                sequence = 1
                revSequence = 1
            } else if areBothCharsFromTheSameSet(current, after) {
                if after == current.next() {
                    sequence += 1
                    same = 1
                    revSequence = 1
                } else if after == current.previous() {
                    revSequence += 1
                    same = 1
                    sequence = 1
                } else {
                    sequence = 1
                    revSequence = 1
                    same = 1
                }
            } else {
                sequence = 1
                revSequence = 1
                same = 1
            }

            let sequentialLimit = Self.passwordSequentialCharacterLimit
            if sequence > sequentialLimit || revSequence > sequentialLimit {
                return [.passwordExceedsSequentialCharactersLimit(limit: sequentialLimit)]
            }
            let sameLimit = Self.passwordSameCharacterLimit
            if same > sameLimit {
                return [.passwordExceedsSameCharactersLimit(limit: sameLimit)]
            }
        }

        return []
    }


    /// Checks if given characters are both numbers, uppercase characters or lowercase characters
    private func areBothCharsFromTheSameSet(_ firstChar: Character, _ secondChar: Character) -> Bool {
        if firstChar.isUppercase && secondChar.isUppercase {
            return true
        }

        if firstChar.isLowercase && secondChar.isLowercase {
            return true
        }

        if firstChar.isNumber && secondChar.isNumber {
            return true
        }

        return false;
    }
}

private extension Character {
    func next() -> Character? {
        if let firstChar = unicodeScalars.first {
            let nextUnicode = firstChar.value + 1
            if let next = UnicodeScalar(nextUnicode) {
                return Character(UnicodeScalar(next))
            }
        }

        return nil
    }

    func previous() -> Character? {
        if let firstChar = unicodeScalars.first {
            let nextUnicode = firstChar.value - 1
            if let next = UnicodeScalar(nextUnicode) {
                return Character(UnicodeScalar(next))
            }
        }

        return nil
    }
}
