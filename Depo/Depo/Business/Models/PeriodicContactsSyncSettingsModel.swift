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

enum PeriodicContactsSyncOption {
    case daily
    case weekly
    case monthly
    
    var localizedText: String {
        switch self {
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
    
    private struct SettingsKeys {
        private init() {}
        
        static let isPeriodicContactsSyncEnabledKey = "isPeriodicContactsSyncEnabledKey"
        static let dailyKey = "daily"
        static let weeklyKey = "weekly"
        static let monthlyKey = "monthly"
    }
    
    var isPeriodicContactsSyncEnabled: Bool {
        return isPeriodicContactsSyncOptionEnabled
    }
    
    var timeSetting = PeriodicContactsSyncSetting(option: .daily)
    
    var isPeriodicContactsSyncOptionEnabled: Bool = false //Periodic contacts sync switcher in settings is on/off
    
    init() { }

    init(with dictionary: [String: Bool]) {
        isPeriodicContactsSyncOptionEnabled = dictionary[SettingsKeys.isPeriodicContactsSyncEnabledKey] ?? false
        
        let daily = dictionary[SettingsKeys.dailyKey] ?? true
        let weekly = dictionary[SettingsKeys.weeklyKey] ?? false
        
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
    
    private func set(periodicContactsSync: PeriodicContactsSyncSetting) {
        timeSetting = periodicContactsSync
    }
    
    func asDictionary() -> [String: Bool] {
        return [SettingsKeys.isPeriodicContactsSyncEnabledKey: isPeriodicContactsSyncOptionEnabled,
                SettingsKeys.dailyKey: (timeSetting.option == .daily),
                SettingsKeys.weeklyKey: (timeSetting.option == .weekly),
                SettingsKeys.monthlyKey: (timeSetting.option == .monthly)]
    }
}
