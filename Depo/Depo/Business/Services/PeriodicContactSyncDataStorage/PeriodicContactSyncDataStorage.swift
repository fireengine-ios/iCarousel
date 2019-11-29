//
//  PeriodicContactSyncDataStorage.swift
//  Depo
//
//  Created by 12345 on 22.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PeriodicContactSyncDataStorage {
    
    private let storageVars: StorageVars = factory.resolve()
    private let tokenStorage: TokenStorage = factory.resolve()
    
    var settings: PeriodicContactsSyncSettings {
        guard var storedSettings = storageVars.usersWhoUsedApp[SingletonStorage.shared.uniqueUserID] as? [String: Bool] else {
            return PeriodicContactsSyncSettings()
        }
        
        switch SyncSettings.shared().periodicBackup {
        case SYNCPeriodic.daily:
            storedSettings.updateValue(true, forKey: PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.universalText)
            storedSettings.updateValue(true, forKey: PeriodicContactsSyncOption.daily.universalText)
        case SYNCPeriodic.every7:
            storedSettings.updateValue(true, forKey: PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.universalText)
            storedSettings.updateValue(true, forKey: PeriodicContactsSyncOption.weekly.universalText)
        case SYNCPeriodic.every30:
            storedSettings.updateValue(true, forKey: PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.universalText)
            storedSettings.updateValue(true, forKey: PeriodicContactsSyncOption.monthly.universalText)
        case .none:
            storedSettings.updateValue(false, forKey: PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.universalText)
            storedSettings.updateValue(true, forKey: PeriodicContactsSyncOption.daily.universalText)
        }
        return PeriodicContactsSyncSettings(with: storedSettings)
    }
    
    func save(periodicContactSyncSettings: PeriodicContactsSyncSettings) {
        let settingsToStore = periodicContactSyncSettings.asDictionary()
        
        SyncSettings.shared().token = tokenStorage.accessToken
        storageVars.usersWhoUsedApp[SingletonStorage.shared.uniqueUserID] = settingsToStore
    }
    
    func clear() {
        storageVars.usersWhoUsedApp.removeValue(forKey: SingletonStorage.shared.uniqueUserID)
    }
    
}
