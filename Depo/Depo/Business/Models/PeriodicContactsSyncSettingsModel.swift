//
//  PeriodicContactsSyncSettingsModel.swift
//  Depo
//
//  Created by Brothers Harhun on 20.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

struct PeriodicContactsSyncSetting {
    var option: PeriodicContactsSyncOption
}

extension PeriodicContactsSyncSetting: Equatable {
    static func ==(lhs: PeriodicContactsSyncSetting, rhs: PeriodicContactsSyncSetting) -> Bool {
        return lhs.option == rhs.option
    }
}

enum PeriodicContactsSyncOption {
    case none
    case daily
    case weekly
    case monthly
    
    var localizedText: String {
        switch self {
        case .none:
            return ""
        case .daily:
            return TextConstants.autoSyncSettingsOptionDaily
        case .weekly:
            return TextConstants.autoSyncSettingsOptionWeekly
        case .monthly:
            return TextConstants.autoSyncSettingsOptionMonthly
        }
    }
    
    var universalText: String {
        get {
            return String(describing: self)
        }
    }
    
}

enum PeriodicContactsSyncSettingsKey {
    case isPeriodicContactsSyncEnabledKey
    case daily
    case weekly
    case monthly
    
    var localizedText: String {
        switch self {
        case .isPeriodicContactsSyncEnabledKey:
            return TextConstants.isPeriodicContactsSyncEnabledKey
        case .daily:
            return TextConstants.autoSyncSettingsOptionDaily
        case .weekly:
            return TextConstants.autoSyncSettingsOptionWeekly
        case .monthly:
            return TextConstants.autoSyncSettingsOptionMonthly
        }
    }
    
    var universalText: String {
        get {
            return String(describing: self)
        }
    }
    
}

final class PeriodicContactsSyncSettings {
    
    var isPeriodicContactsSyncEnabled: Bool {
        return isPeriodicContactsSyncOptionEnabled
    }
    
    var timeSetting = PeriodicContactsSyncSetting(option: .daily)
    
    var isPeriodicContactsSyncOptionEnabled: Bool = false //Periodic contacts sync switcher in settings is on/off
    
    init() { }

    init(with dictionary: [String: Bool]) {
        isPeriodicContactsSyncOptionEnabled = dictionary[PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.universalText] ?? false
        
        let daily = dictionary[PeriodicContactsSyncSettingsKey.daily.universalText] ?? true
        let weekly = dictionary[PeriodicContactsSyncSettingsKey.weekly.universalText] ?? false
        
        //setup time setting
        
        if daily {
            timeSetting.option = .daily
        } else if weekly{
            timeSetting.option = .weekly
        } else {
            timeSetting.option = .monthly
        }
    }
    
    func disablePeriodicContactsSync() {
        isPeriodicContactsSyncOptionEnabled = false
        timeSetting.option = .daily
    }
    
    func set(periodicContactsSync: PeriodicContactsSyncSetting) {
        timeSetting = periodicContactsSync
    }
    
    func asDictionary() -> [String: Bool] {
        return [PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.localizedText: isPeriodicContactsSyncOptionEnabled,
                PeriodicContactsSyncSettingsKey.daily.universalText: (timeSetting.option == .daily),
                PeriodicContactsSyncSettingsKey.weekly.universalText: (timeSetting.option == .weekly),
                PeriodicContactsSyncSettingsKey.monthly.universalText: (timeSetting.option == .monthly)]
    }
    
    var syncPeriodic: SYNCPeriodic {
        let periodicBackUp: SYNCPeriodic
        
        if isPeriodicContactsSyncOptionEnabled {
            switch timeSetting.option {
            case .daily:
                periodicBackUp = .daily
            case .weekly:
                periodicBackUp = .every7
            case .monthly:
                periodicBackUp = .every30
            case .none:
                periodicBackUp = .none
            }
        } else {
            periodicBackUp = .none
        }
        
        return periodicBackUp
    }
}
