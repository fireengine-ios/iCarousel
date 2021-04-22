//
//  SameColorsChecker.swift
//  Depo
//
//  Created by Anton Ignatovich on 19.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class SameColorsChecker {
    private lazy var allColors: [String: CGColor] = {
        var allColors: [String: CGColor] = [:]
        ColorConstants.allCases.forEach { allColors[$0.rawValue] = $0.color.cgColor }
        return allColors
    }()

    func checkColorDuplicates() -> [String: [String]] {
        var duplicates: [String: [String]] = [:]
        for colorPair in allColors {
            duplicates[colorPair.key] = checkDuplicatesForColorWithNameInConstants(with: colorPair.key)
        }
        return duplicates.filter { !$0.value.isEmpty }
    }

    func checkDuplicatesForColorWithNameInConstants(with name: String) -> [String] {
        guard let desiredCGColor = allColors[name] else { return [] }

        var duplicates: [String] = []

        for colorPairInner in allColors {
            if colorPairInner.key.elementsEqual(name) { continue }
            if desiredCGColor == colorPairInner.value {
                duplicates.append(colorPairInner.key)
            }
        }

        return duplicates
    }

    func searchForColors(with cgColor: CGColor) -> [String] {
        var duplicates: [String] = []

        for colorPairInner in allColors {
            if cgColor == colorPairInner.value {
                duplicates.append(colorPairInner.key)
            }
        }

        return duplicates
    }
}
