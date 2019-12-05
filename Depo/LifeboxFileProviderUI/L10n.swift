//
//  L10n.swift
//  LifeboxFileProviderUI
//
//  Created by Bondar Yaroslav on 3/6/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
    /// Error
    static let error = L10n.tr("OurLocalizable", "Error")
    /// Please open lifebox app and sign in to continue
    static let errorAuthenticationMessage = L10n.tr("OurLocalizable", "error_authentication_message")
    /// Sign in to lifebox
    static let errorAuthenticationTitle = L10n.tr("OurLocalizable", "error_authentication_title", TextConstants.NotLocalized.appNameLowercased)
    /// Files app cannot be used with a passcode. If you would like to use Files app, please open lifebox and disable Passcode Lock
    static let errorPasscodeMessage = L10n.tr("OurLocalizable", "error_passcode_message")
    /// Passcode Lock is enabled
    static let errorPasscodeTitle = L10n.tr("OurLocalizable", "error_passcode_title")
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
    fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

private final class BundleToken {}
