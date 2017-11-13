//
//  AutoSyncDataStorage.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoSyncDataStorage: NSObject {

    func getAutoSyncModelForCurrentUser(success:@escaping ([AutoSyncModel], _ uniqueUserId: String) -> Swift.Void){
        SingletonStorage.shared().getAccountInfoForUser(success: { (accountInfoResponce) in
            let settings: [AutoSyncModel]
            
            let uniqueUserID = accountInfoResponce.projectID ?? ""
            if let dict = UserDefaults.standard.object(forKey: uniqueUserID) as? [String: Bool]{
                let autoSyncModel = SettingsAutoSyncModel()
                autoSyncModel.configurateWithDictionary(dictionary: dict)
                settings = autoSyncModel.getDataForTable()
            }else{
                settings = SettingsAutoSyncModel().getDataForTable()
            }
            
            success(settings, uniqueUserID)
        }) { (error) in
            success(SettingsAutoSyncModel().getDataForTable(), "")
        }
    }
    
    func saveAutoSyncModel(model: SettingsAutoSyncModel, uniqueUserId: String){
        let dict = model.configurateDictionary()
        UserDefaults.standard.set(dict, forKey: uniqueUserId)
        if model.isAutoSyncEnable {
            LocationManager.shared().startUpdateLocation()
        }else{
            LocationManager.shared().stopUpdateLocation()
        }
        
    }
    
}
