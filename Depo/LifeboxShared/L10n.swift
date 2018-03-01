//
//  TextConstants.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 3/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

/// used https://github.com/SwiftGen/SwiftGen
/// swiftgen strings -t structured-swift3 /Users/user/gitProjects/lifebox-ios-new/Depo/LifeboxShared/Localizable.strings

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
    /// Cancel
    static let cancel = L10n.tr("Localizable", "cancel")
    /// Upload
    static let upload = L10n.tr("Localizable", "upload")
    /// Uploading...
    static let uploading = L10n.tr("Localizable", "uploading")
    
    enum Error {
        /// Please check your internet connection is active and Mobile Data is ON.
        static let internet = L10n.tr("Localizable", "error.internet")
        /// You have not login via app yet
        static let login = L10n.tr("Localizable", "error.login")
    }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
    fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

private final class BundleToken {}
