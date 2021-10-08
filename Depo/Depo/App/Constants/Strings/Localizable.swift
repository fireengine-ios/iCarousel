//
//  Localizable.swift
//  Depo
//
//  Created by Hady on 9/2/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

protocol Localizable {
    var localizationKey: String { get }
    var localizationTable: String? { get }
    var localized: String { get }
}

extension Localizable {
    var localizationTable: String? {
        return "OurLocalizable"
    }
}

extension Localizable where Self: RawRepresentable, RawValue == String {
    var localizationKey: String {
        return rawValue
    }

    var localized: String {
        return NSLocalizedString(localizationKey, tableName: localizationTable, bundle: .main, value: "", comment: "")
    }
}
