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
        } else if !storageVars.autoSyncSettingsMigrationCompleted {
            storageVars.autoSyncSettingsMigrationCompleted = true
            let settings = AutoSyncSettings.createMigrated()
            save(autoSyncSettings: settings, triggerLocation: false)
            return settings
        }
        
        return AutoSyncSettings()
    }
    
    
    func save(autoSyncSettings: AutoSyncSettings, triggerLocation: Bool = true) {
        let settingsToStore = autoSyncSettings.asDictionary()
        storageVars.autoSyncSettings = settingsToStore
        
        if triggerLocation {
            if autoSyncSettings.isAutoSyncEnabled {
                LocationManager.shared.startUpdateLocation()
            } else {
                PopUpService.shared.setLoginCountForShowImmediately()
                PopUpService.shared.checkIsNeedShowUploadOffPopUp()
                LocationManager.shared.stopUpdateLocation()
            }
            
        }
    }
    
    func clear() {
        storageVars.autoSyncSettings = nil
    }
    
}
