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
        AccountService().info(success: { (accountInfoResponce) in
            DispatchQueue.main.async {
                var settings: [AutoSyncModel] = SettingsAutoSyncModel().getDataForTable()
                var uniqueUserID = ""
                
                if let accountInfo = accountInfoResponce as? AccountInfoResponse{
                    uniqueUserID = accountInfo.cellografId ?? ""
                    if let dict = UserDefaults.standard.object(forKey: uniqueUserID) as? [String: Bool]{
                        let autoSyncModel = SettingsAutoSyncModel()
                        autoSyncModel.configurateWithDictionary(dictionary: dict)
                        settings = autoSyncModel.getDataForTable()
                    }
                }
                
                success(settings, uniqueUserID)
            }
        }) { (error) in
            DispatchQueue.main.async {
                success(SettingsAutoSyncModel().getDataForTable(), "")
            }
        }
    }
    
    func saveAutoSyncModel(model: SettingsAutoSyncModel, uniqueUserId: String){
        let dict = model.configurateDictionary()
        UserDefaults.standard.set(dict, forKey: uniqueUserId)
    }
    
}
