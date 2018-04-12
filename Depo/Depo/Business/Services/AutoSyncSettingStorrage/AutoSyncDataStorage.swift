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
    
    func getAutosyncSettings() -> AutoSyncSettings {
        if let storedSettings = storageVars.autoSyncSettings as? [String: Bool] {
            return AutoSyncSettings(with: storedSettings)
        } else if !storageVars.autoSyncSettingsMigrationCompleted {
            storageVars.autoSyncSettingsMigrationCompleted = true
            return AutoSyncSettings.createMigrated()
        }
        
        return AutoSyncSettings()
    }
    
    func save(autoSyncSettings: AutoSyncSettings) {
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
