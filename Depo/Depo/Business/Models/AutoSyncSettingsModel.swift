//
//  AutoSyncSettingsModel.swift
//  Depo
//
//  Created by Konstantin on 3/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


struct AutoSyncSettings {
    var isAutoSyncEnabled: Bool = false
    var photoSetting = AutoSyncSetting(syncItemType: .photo, option: .never)
    var videoSetting = AutoSyncSetting(syncItemType: .video, option: .never)
}


struct AutoSyncSetting: Equatable {

    var syncItemType: AutoSyncItemType
    var option: AutoSyncOption
    
    static func ==(lhs: AutoSyncSetting, rhs: AutoSyncSetting) -> Bool {
        return lhs.option == rhs.option && lhs.syncItemType == rhs.syncItemType
    }
}


enum AutoSyncItemType {
    case photo
    case video
    
    func text() -> String {
        switch self {
        case .photo:
            return "Photos"
        case .video:
            return "Videos"
        }
    }
}


enum AutoSyncOption {
    case wifiOnly
    case wifiAndCellular
    case never
    
    func text() -> String {
        switch self {
        case .never:
            return "Never"
        case .wifiOnly:
            return "Wi-Fi"
        case .wifiAndCellular:
            return "Wi-Fi and Cellular"
        }
    }
}
