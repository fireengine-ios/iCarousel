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
    
    var settings = PeriodicContactsSyncSettings()
    
    func save(periodicContactSyncSettings: PeriodicContactsSyncSettings) {
        let settingsToStore = periodicContactSyncSettings.asDictionary()
        
        SyncSettings.shared().token = tokenStorage.accessToken
        storageVars.usersWhoUsedApp[SingletonStorage.shared.uniqueUserID] = settingsToStore
    }
    
    func clear() {
        storageVars.usersWhoUsedApp.removeValue(forKey: SingletonStorage.shared.uniqueUserID)
    }
    
}
