//
//  AccountConstants.swift
//  Depo
//
//  Created by Alper Kırdök on 17.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class AccountConstants {
    static let shared = AccountConstants()

    let accountBGColors:[UIColor] = [.lrTealishTwo, ColorConstants.marineFour, .lrDarkSkyBlue, .lrOrange, .lrButterScotch, .lrFadedRed]

    func generateBGColors(numberOfItems: Int) -> [UIColor] {
        var bgColors = [UIColor]()
        for i in 0..<numberOfItems {
            let accountBGColorsCount = accountBGColors.count
            bgColors.append(accountBGColors[i % accountBGColorsCount])
        }

        return bgColors
    }

    // Using Name
    func dotTextBy(name: String) -> String {
        let fullNameArray = name.components(separatedBy: " ")
        let firstName = fullNameArray.first
        let lastName = fullNameArray.last
        var firstLetterOfName = ""
        var firstLetterOfLastname = ""

        if let firstName = firstName {
            firstLetterOfName = firstName[0]
        }

        if let lastName = lastName {
            firstLetterOfLastname = lastName[0]
        }

        return (firstLetterOfName + firstLetterOfLastname).uppercased()
    }

    // Using Email
    func dotTextBy(email: String) -> String {
        let emailFirstTwoLetters: String = email[0] + email[1]
        return emailFirstTwoLetters.uppercased()
    }
}
