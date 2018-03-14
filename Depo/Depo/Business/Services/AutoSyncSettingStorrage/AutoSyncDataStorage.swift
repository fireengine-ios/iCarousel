//
//  AutoSyncDataStorage.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoSyncDataStorage: NSObject {
    static let shared = AutoSyncDataStorage()
    
    private var uniqueUserID = ""

    func getAutoSyncSettingsForCurrentUser(success: @escaping (AutoSyncSettings, _ uniqueUserId: String) -> Void) {
        SingletonStorage.shared.getAccountInfoForUser(success: { [weak self] accountInfoResponce in
            guard let `self` = self else {
                return
            }

            let settings: AutoSyncSettings
            
            self.uniqueUserID = accountInfoResponce.projectID ?? ""
            if let dict = UserDefaults.standard.object(forKey: self.uniqueUserID) as? [String: Bool] {
                settings = AutoSyncSettings(with: dict)
            } else {
                settings = AutoSyncSettings()
            }
            success(settings, self.uniqueUserID)
        }) { (error) in
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
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: uniqueUserID)
        uniqueUserID = ""
    }
    
}
