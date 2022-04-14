//
//  AppFont.swift
//  Depo
//
//  Created by Hady on 4/12/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

import UIKit

enum AppFont: String {
    case light = "TurkcellSatura"
    case regular = "TurkcellSaturaReg"
    case medium = "TurkcellSaturaMed"
    case bold = "TurkcellSaturaBol"
}

private extension AppFont {
    func resolvedFont(with size: CGFloat) -> UIFont {
        UIFont(name: self.rawValue, size: size)!
    }
}

enum AppFontPresets {
//    static let heading1 = UIFont.appFont(.medium, relativeToStyle: .headline, size: 48)
//    static let heading2 = UIFont.appFont(.medium, relativeToStyle: .subheadline, size: 20)
//    static let heading3 = UIFont.appFont(.medium, relativeToStyle: .subheadline, size: 16)
//    static let title1 = UIFont.appFont(.medium, relativeToStyle: .title2, size: 16)
//    static let title2 = UIFont.appFont(.medium, relativeToStyle: .title2, size: 14)
}

extension UIFont {
    static func appFont(_ font: AppFont, size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let resolvedFont = font.resolvedFont(with: size)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: resolvedFont)
        }

        return resolvedFont
    }
}





















