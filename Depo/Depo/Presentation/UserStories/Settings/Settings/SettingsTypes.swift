//
//  SettingsTypes.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum SettingsTypes: Int {
    case invitation
    case autoUpload
    case periodicContactSync
    case faceImage
    case connectAccounts
    case permissions
    case myActivities
    case passcode
    case security
    case helpAndSupport
    case termsAndPolicy
    case logout
    
    var text: String {
        switch self {
        case .invitation: return TextConstants.settingsItemInvitation
        case .autoUpload: return TextConstants.settingsViewCellAutoUpload
        case .periodicContactSync: return TextConstants.settingsViewCellContactsSync
        case .faceImage: return TextConstants.settingsViewCellFaceAndImageGrouping
        case .connectAccounts: return TextConstants.settingsViewCellConnectedAccounts
        case .permissions: return TextConstants.settingsViewCellPermissions
        case .myActivities: return TextConstants.settingsViewCellActivityTimline
        case .passcode: return TextConstants.settingsViewCellPasscode
        case .security: return TextConstants.settingsViewCellLoginSettings
        case .helpAndSupport: return TextConstants.settingsViewCellHelp
        case .termsAndPolicy: return TextConstants.settingsViewCellPrivacyAndTerms
        case .logout: return TextConstants.settingsViewCellLogout
        }
    }

    static let allSectionOneTypes = [autoUpload, periodicContactSync, faceImage]
    static let allSectionTwoTypes = [connectAccounts, permissions]
    static let allSectionThreeTypes = [myActivities, passcode, security]
    static let allSectionFourTypes = [helpAndSupport, termsAndPolicy, logout]

    static func prepareTypes(hasPermissions: Bool) -> [[SettingsTypes]] {
        let invitationTypes = [SettingsTypes.invitation]
        var accountTypes = [SettingsTypes.connectAccounts]
        if hasPermissions {
            accountTypes.append(SettingsTypes.permissions)
        }
        return [invitationTypes,
                SettingsTypes.allSectionOneTypes,
                accountTypes,
                SettingsTypes.allSectionThreeTypes,
                SettingsTypes.allSectionFourTypes]
    }

}
