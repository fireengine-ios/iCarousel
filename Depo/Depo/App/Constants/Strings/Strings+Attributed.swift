//
//  Strings+Attributed.swift
//  Depo
//
//  Created by Hady on 10/21/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//
//  Source: https://www.swiftbysundell.com/articles/styled-localized-strings-in-swift

import UIKit


///
/// Parses localized strings into attributed strings
///
/// Supports:
/// * Bolding parts of the localized string. Format: "Hi, **This will be bold**"
///
/// - Parameters:
///   - key: Localization key
///   - options: See `LocalizedAttributedStringOptions` for more.
/// - Returns: `NSAttributedString`
func localizedAttributed(_ key: Strings,
                         withOptions options: LocalizedAttributedStringOptions = .default()) -> NSAttributedString {
    let components = localized(key).components(separatedBy: "**")
    let sequence = components.enumerated()
    let attributedString = NSMutableAttributedString()

    return sequence.reduce(into: attributedString) { string, pair in
        let isBold = !pair.offset.isMultiple(of: 2)
        let font = isBold ? options.boldFont : options.font

        string.append(NSAttributedString(
            string: pair.element,
            attributes: [.font: font]
        ))
    }
}

struct LocalizedAttributedStringOptions {
    let font: UIFont
    let boldFont: UIFont

    static func `default`() -> Self {
        let size = UIFont.preferredFont(forTextStyle: .body).pointSize
        return LocalizedAttributedStringOptions(
            font: .TurkcellSaturaFont(size: size),
            boldFont: .TurkcellSaturaBolFont(size: size)
        )
    }
}
