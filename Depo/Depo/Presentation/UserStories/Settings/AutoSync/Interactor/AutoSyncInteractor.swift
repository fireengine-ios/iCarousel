//
//  AutoSyncAutoSyncInteractor.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncInteractor: AutoSyncInteractorInput {

    weak var output: AutoSyncInteractorOutput!
    var dataStorage = AutoSyncDataStorage()
    var uniqueUserID: String? = ""

    func prepareCellsModels() {
        dataStorage.getAutoSyncModelForCurrentUser(success: { [weak self] (models, uniqueUserId) in
            self?.output.preperedCellsModels(models: models)
            self?.uniqueUserID = uniqueUserId
        })
    }
    
    func onSaveSettings(setting: SettingsAutoSyncModel){
        output.onSettingSaved()
        
        dataStorage.saveAutoSyncModel(model: setting, uniqueUserId: uniqueUserID ?? "")
        SyncServiceManger.shared.updateSyncSettings(settingsModel: setting)
    }
    
}
