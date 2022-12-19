//
//  SettingsTypes.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum SettingsTypes: Int {
    case autoUpload
    case periodicContactSync
    case faceImage
    case permissions
    case myActivities
    case passcode
    case helpAndSupport
    case chatbot
    case packages
    
    var text: String {
        switch self {
        case .autoUpload: return TextConstants.settingsViewCellAutoUpload
        case .periodicContactSync: return TextConstants.settingsViewCellContactsSync
        case .faceImage: return TextConstants.settingsViewCellFaceAndImageGrouping
        case .permissions: return TextConstants.settingsViewCellPermissions
        case .myActivities: return TextConstants.settingsViewCellActivityTimline
        case .passcode: return TextConstants.settingsViewCellLoginSettings
        case .helpAndSupport: return TextConstants.settingsViewCellHelp
        case .chatbot: return TextConstants.chatbotMenuTitle
        case .packages: return TextConstants.packages
        }
    }
    
    static let defaultSectionOneTypes = [autoUpload, faceImage]
    static let defaultSectionTwoTypes = [myActivities, passcode]
    static var defaultSectionThreeTypes = [helpAndSupport]
    
    static func prepareTypes(hasPermissions: Bool, isInvitationShown: Bool, isChatbotShown: Bool, isPaycellShown: Bool) -> [[SettingsTypes]] {
        var result = [[SettingsTypes]]()
        
        addPackagesSection(to: &result)
        addDefaultSection(to: &result,
                          hasPermissions: hasPermissions,
                          isInvitationShown: isInvitationShown,
                          isChatbotShown: isChatbotShown,
                          isPaycellShown: isPaycellShown)
        return result
    }
    
    private static func addPackagesSection(to result: inout [[SettingsTypes]]) {
        var cells: [SettingsTypes] = []
        cells.append(SettingsTypes.packages)
        result.append(cells)
    }
    
    private static func addDefaultSection(to result: inout [[SettingsTypes]],
                                          hasPermissions: Bool,
                                          isInvitationShown: Bool,
                                          isChatbotShown: Bool,
                                          isPaycellShown: Bool) {
        var cells: [SettingsTypes] = []

        cells.append(contentsOf: SettingsTypes.defaultSectionOneTypes)
        
        cells.append(contentsOf: SettingsTypes.defaultSectionTwoTypes)
        
        if ((Device.locale == "tr" || Device.locale == "en") && !RouteRequests.isBillo) {
            if isChatbotShown && !defaultSectionThreeTypes.contains(chatbot) {
                SettingsTypes.defaultSectionThreeTypes.insert(chatbot, at: 1)
            } else if !isChatbotShown && defaultSectionThreeTypes.contains(chatbot){
                SettingsTypes.defaultSectionThreeTypes.remove(chatbot)
            }
        }
        cells.append(contentsOf: SettingsTypes.defaultSectionThreeTypes)
        result.append(cells)
    }
}
