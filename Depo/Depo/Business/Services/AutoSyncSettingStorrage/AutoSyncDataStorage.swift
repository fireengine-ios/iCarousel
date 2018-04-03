//
//  AutoSyncDataStorage.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoSyncDataStorage: NSObject {

    func getAutoSyncSettingsForCurrentUser(success: @escaping (AutoSyncSettings, _ uniqueUserId: String) -> Void) {
        SingletonStorage.shared.getAccountInfoForUser(success: { accountInfoResponce in
            var settings = AutoSyncSettings()
            
            let uniqueUserID = accountInfoResponce.projectID ?? ""
            if let dict = UserDefaults.standard.object(forKey: uniqueUserID) as? [String: Bool] {
                settings = AutoSyncSettings(with: dict)
            } else if !settings.isMigrationCompleted {
                settings.migrate()
            }
            
            success(settings, uniqueUserID)
        }) { error in
            success(AutoSyncSettings(), "")
        }
    }
    
    func save(autoSyncSettings: AutoSyncSettings, uniqueUserId: String) {
        let dict = autoSyncSettings.asDictionary()
        UserDefaults.standard.set(dict, forKey: uniqueUserId)
        if autoSyncSettings.isAutoSyncEnabled {
            LocationManager.shared.startUpdateLocation()
        } else {
            PopUpService.shared.setLoginCountForShowImmediately()
            PopUpService.shared.checkIsNeedShowUploadOffPopUp()
            LocationManager.shared.stopUpdateLocation()
        }
        
    }
    
    static func clear() {
        SingletonStorage.shared.getUniqueUserID(success: { userId in
            UserDefaults.standard.removeObject(forKey: userId)
        }, fail: {
            ///error should be handled before the callback
        })
        
    }
    
}
