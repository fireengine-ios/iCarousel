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
}

final class PeriodicContactsSyncSettings {
    
    var isPeriodicContactsSyncEnabled: Bool {
        return isPeriodicContactsSyncOptionEnabled
    }
    
    var timeSetting = PeriodicContactsSyncSetting(option: .daily)
    
    var isPeriodicContactsSyncOptionEnabled: Bool = false //Periodic contacts sync switcher in settings is on/off
    
    init() { }

    init(with dictionary: [String: Bool]) {
        isPeriodicContactsSyncOptionEnabled = dictionary[PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.localizedText] ?? false
        
        let daily = dictionary[PeriodicContactsSyncSettingsKey.daily.localizedText] ?? true
        let weekly = dictionary[PeriodicContactsSyncSettingsKey.weekly.localizedText] ?? false
        
        //setup time setting
        
        if daily {
            timeSetting.option = .daily
        } else if weekly{
            timeSetting.option = .weekly
        } else {
            timeSetting.option = .monthly
        }
    }
    
    init(with periodic: SYNCPeriodic) {
        switch periodic {
            case SYNCPeriodic.daily:
                isPeriodicContactsSyncOptionEnabled = true
                timeSetting.option = .daily
            case SYNCPeriodic.every7:
                isPeriodicContactsSyncOptionEnabled = true
                timeSetting.option = .weekly
            case SYNCPeriodic.every30:
                isPeriodicContactsSyncOptionEnabled = true
                timeSetting.option = .monthly
            case .none:
                disablePeriodicContactsSync()
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
                PeriodicContactsSyncSettingsKey.daily.localizedText: (timeSetting.option == .daily),
                PeriodicContactsSyncSettingsKey.weekly.localizedText: (timeSetting.option == .weekly),
                PeriodicContactsSyncSettingsKey.monthly.localizedText: (timeSetting.option == .monthly)]
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
