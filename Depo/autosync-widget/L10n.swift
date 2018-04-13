//
//  L10n.swift
//  autosync-widget
//
//  Created by Konstantin on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
    /// Last upload: %@
    static func widgetBottomTitleLastSyncFormat(_ p1: String) -> String {
        return L10n.tr("OurLocalizable", "widgetBottomTitleLastSyncFormat", p1)
    }
    /// never
    static let widgetBottomTitleNewerSyncronized = L10n.tr("OurLocalizable", "widgetBottomTitleNewerSyncronized")
    /// Photos are up-to-date
    static let widgetTopTitleFinished = L10n.tr("OurLocalizable", "widgetTopTitleFinished")
    /// Photo synchronization is inactive
    static let widgetTopTitleInactive = L10n.tr("OurLocalizable", "widgetTopTitleInactive")
    /// Photo synchronization is in progress
    static let widgetTopTitleInProgress = L10n.tr("OurLocalizable", "widgetTopTitleInProgress")
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
    fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

private final class BundleToken {}

