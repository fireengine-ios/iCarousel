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
        if var storedSettings = storageVars.periodicContactSyncSettings as? [String: Bool] {
            switch SyncSettings.shared().periodicBackup {
            case SYNCPeriodic.daily:
                storedSettings.updateValue(true, forKey: PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.localizedText)
                storedSettings.updateValue(true, forKey: PeriodicContactsSyncOption.daily.localizedText)
            case SYNCPeriodic.every7:
                storedSettings.updateValue(true, forKey: PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.localizedText)
                storedSettings.updateValue(true, forKey: PeriodicContactsSyncOption.weekly.localizedText)
            case SYNCPeriodic.every30:
                storedSettings.updateValue(true, forKey: PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.localizedText)
                storedSettings.updateValue(true, forKey: PeriodicContactsSyncOption.monthly.localizedText)
            case .none:
                storedSettings.updateValue(false, forKey: PeriodicContactsSyncSettingsKey.isPeriodicContactsSyncEnabledKey.localizedText)
                storedSettings.updateValue(true, forKey: PeriodicContactsSyncOption.daily.localizedText)
            }
            return PeriodicContactsSyncSettings(with: storedSettings)
        }
        
        return PeriodicContactsSyncSettings()
    }
    
    func save(periodicContactSyncSettings: PeriodicContactsSyncSettings) {
        let settingsToStore = periodicContactSyncSettings.asDictionary()
        
        storageVars.periodicContactSyncSettings = settingsToStore
        SyncSettings.shared().token = tokenStorage.accessToken
        
        /// here must be "!". "if let" create copy
        if storageVars.usersWhoUsedApp != nil {
            storageVars.usersWhoUsedApp![SingletonStorage.shared.uniqueUserID] = settingsToStore
        } else {
            var usersWhoUsedApp = [String: Any]()
            usersWhoUsedApp[SingletonStorage.shared.uniqueUserID] = settingsToStore
            storageVars.usersWhoUsedApp = usersWhoUsedApp
        }
    }
    
    func clear() {
        storageVars.periodicContactSyncSettings = nil
    }
    
}
