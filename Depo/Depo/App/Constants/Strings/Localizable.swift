//
//  Localizable.swift
//  Depo
//
//  Created by Hady on 9/2/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

private let defaultLocalizationTable = "OurLocalizable"
private let fallbackLocale = "en"

protocol Localizable {
    var localizationKey: String { get }
    var localizationTable: String? { get }
}

extension Localizable {
    var localizationTable: String? {
        return defaultLocalizationTable
    }
}

extension Localizable {
    var localized: String {
        return getLocalizedString(localizationKey, tableName: localizationTable, fallbackLocale: fallbackLocale)
    }
}

extension Localizable where Self: RawRepresentable, RawValue == String {
    var localizationKey: String {
        return rawValue
    }
}

func localized(_ key: String, tableName: String = defaultLocalizationTable) -> String {
    return getLocalizedString(key, tableName: tableName, fallbackLocale: fallbackLocale)
}

private func getLocalizedString(_ key: String, tableName: String?, fallbackLocale: String) -> String {
    let result = NSLocalizedString(key, tableName: tableName, bundle: .main, value: "", comment: "")
    if result.isEmpty {
        let bundle = Bundle.forLocale(fallbackLocale) ?? .main
        return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: "", comment: "")
    }

    return result
}

private extension Bundle {
    static func forLocale(_ locale: String) -> Bundle? {
        guard let path = Bundle.main.path(forResource: locale, ofType: "lproj") else {
            return nil
        }

        return Bundle(path: path)
    }
}
