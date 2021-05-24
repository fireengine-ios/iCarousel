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
}
