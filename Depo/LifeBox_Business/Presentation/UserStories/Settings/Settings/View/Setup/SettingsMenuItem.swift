//
//  SettingsMenuItem.swift
//  Depo
//
//  Created by Anton Ignatovich on 12.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

enum SettingsMenuItem {
    case profile
    case agreements
    case faq
    case contactUs
    case deletedFiles

    var icon: UIImage? {
        switch self {
        case .profile:
            return UIImage(named: "profile")
        case .agreements:
            return UIImage(named: "agreements")
        case .contactUs:
            return UIImage(named: "contactus")
        case .faq:
            return UIImage(named: "faq")
        case .deletedFiles:
            return UIImage(named: "settings_trash")
        }
    }

    var title: String {
        switch self {
        case .profile:
            return TextConstants.settingsPageProfile
        case .agreements:
            return TextConstants.settingsPageAgreements
        case .contactUs:
            return TextConstants.settingsPageContactUs
        case .faq:
            return TextConstants.settingsPageFAQ
        case .deletedFiles:
            return TextConstants.settingsPageDeletedFiles
        }
    }
}
