//
//  SettingsTypes.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum SettingsTypes: Int {
    case permissions
    case myActivities
    case passcode
    case helpAndSupport
    case agreements
    case logout
    
    var text: String {
        switch self {
        case .permissions: return TextConstants.settingsViewCellPermissions
        case .myActivities: return TextConstants.settingsViewCellActivityTimline
        case .passcode: return TextConstants.settingsViewCellPasscode
        case .helpAndSupport: return TextConstants.settingsViewCellHelp
        case .agreements: return TextConstants.agreements
        case .logout: return TextConstants.settingsViewCellLogout
        }
    }
    
    static let allSectionTwoTypes = [permissions]
    static let allSectionThreeTypes = [myActivities, passcode]
    static let allSectionFourTypes = [helpAndSupport, agreements, logout]

    static func prepareTypes(hasPermissions: Bool) -> [[SettingsTypes]] {
        var result = [[SettingsTypes]]()
        if hasPermissions {
            result.append(SettingsTypes.allSectionTwoTypes)
        }
        result.append(SettingsTypes.allSectionThreeTypes)
        result.append(SettingsTypes.allSectionFourTypes)
        return result

    }

}

