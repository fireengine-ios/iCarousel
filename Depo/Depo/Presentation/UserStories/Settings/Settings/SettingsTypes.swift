//
//  SettingsTypes.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum SettingsTypes: Int {
    case invitation
    case paycell
    case autoUpload
    case periodicContactSync
    case faceImage
    case connectAccounts
    case permissions
    case myActivities
    case passcode
    case helpAndSupport
    case chatbot
    
    var text: String {
        switch self {
        case .invitation: return TextConstants.settingsItemInvitation
        case .paycell: return localized(.paycellCampaignTitle)
        case .autoUpload: return TextConstants.settingsViewCellAutoUpload
        case .periodicContactSync: return TextConstants.settingsViewCellContactsSync
        case .faceImage: return TextConstants.settingsViewCellFaceAndImageGrouping
        case .connectAccounts: return TextConstants.settingsViewCellConnectedAccounts
        case .permissions: return TextConstants.settingsViewCellPermissions
        case .myActivities: return TextConstants.settingsViewCellActivityTimline
        case .passcode: return TextConstants.settingsViewCellLoginSettings
        case .helpAndSupport: return TextConstants.settingsViewCellHelp
        case .chatbot: return TextConstants.chatbotMenuTitle
        }
    }

    static let allSectionOneTypes = [autoUpload, periodicContactSync, faceImage]
    static let allSectionTwoTypes = [connectAccounts, permissions]
    static let allSectionThreeTypes = [myActivities, passcode]
    static var allSectionFourTypes = [helpAndSupport]

    static func prepareTypes(hasPermissions: Bool, isInvitationShown: Bool, isChatbotShown: Bool, isPaycellShown: Bool) -> [[SettingsTypes]] {
        var result = [[SettingsTypes]]()
        
        var invitationTypes: [SettingsTypes] = []
        if isInvitationShown {
            invitationTypes.append(SettingsTypes.invitation)
        }
        
        if isPaycellShown {
            invitationTypes.append(SettingsTypes.paycell)
        }
        
        result.append(invitationTypes)
        result.append(SettingsTypes.allSectionOneTypes)

        var accountTypes = [SettingsTypes.connectAccounts]
        if hasPermissions {
            accountTypes.append(SettingsTypes.permissions)
        }

        result.append(accountTypes)

        result.append(SettingsTypes.allSectionThreeTypes)

        if ((Device.locale == "tr" || Device.locale == "en") && !RouteRequests.isBillo) {
            if isChatbotShown && !allSectionFourTypes.contains(chatbot) {
                SettingsTypes.allSectionFourTypes.insert(chatbot, at: 1)
            } else if !isChatbotShown && allSectionFourTypes.contains(chatbot){
                SettingsTypes.allSectionFourTypes.remove(chatbot)
            }
        }

        result.append(SettingsTypes.allSectionFourTypes)

        return result
    }
}
