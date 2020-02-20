//
//  AutoSyncDataStorage.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class AutoSyncDataStorage {
    
    private let storageVars: StorageVars = factory.resolve()
    
    var settings: AutoSyncSettings {
        if let storedSettings = storageVars.autoSyncSettings as? [String: Bool] {
            return AutoSyncSettings(with: storedSettings)
        } else if !storageVars.autoSyncSettingsMigrationCompleted && AutoSyncSettings.hasSettingsToMigrate {
            storageVars.autoSyncSettingsMigrationCompleted = true
            let settings = AutoSyncSettings.createMigrated()
            return settings
        }
        
        return AutoSyncSettings()
    }
    
    
    func save(autoSyncSettings: AutoSyncSettings, fromSettings: Bool) {
        
        if self.settings != autoSyncSettings || !fromSettings {
            /// There is no scenario both success and error for now. Just sending BE
            AccountService().autoSyncStatus(syncSettings: autoSyncSettings) { _ in
            }
        }
        
        let settingsToStore = autoSyncSettings.asDictionary()
        storageVars.autoSyncSettings = settingsToStore
        
        if autoSyncSettings.isAutoSyncEnabled {
            LocationManager.shared.startUpdateLocation()
        } else {
            PopUpService.shared.setLoginCountForShowImmediately()
            PopUpService.shared.checkIsNeedShowUploadOffPopUp()
            LocationManager.shared.stopUpdateLocation()
        }
    }
    
    func clear() {
        storageVars.autoSyncSettings = nil
    }
    
}
