//
//  PeriodicContactSyncDataStorage.swift
//  Depo
//
//  Created by 12345 on 22.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PeriodicContactSyncDataStorage {
    
    private let storageVars: StorageVars = factory.resolve()
    
    var settings: PeriodicContactsSyncSettings {
        if let storedSettings = storageVars.periodicContactSyncSettings as? [String: Bool] {
            return PeriodicContactsSyncSettings(with: storedSettings)
        }
        
        return PeriodicContactsSyncSettings()
    }
    
    func save(periodicContactSyncSettings: PeriodicContactsSyncSettings) {
        let settingsToStore = periodicContactSyncSettings.asDictionary()
        storageVars.periodicContactSyncSettings = settingsToStore
    }
    
    func clear() {
        storageVars.periodicContactSyncSettings = nil
    }
    
}
