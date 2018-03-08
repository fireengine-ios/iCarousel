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
    let localMediaStorage = LocalMediaStorage.default

    func prepareCellsModels() {
        dataStorage.getAutoSyncModelForCurrentUser(success: { [weak self] (models, uniqueUserId) in
            self?.output.preperedCellsModels(models: models)
            self?.uniqueUserID = uniqueUserId
        })
    }
    
    func onSaveSettings(setting: SettingsAutoSyncModel) {
        output.onSettingSaved()
        
        SyncServiceManager.shared.logChangesIfNeeded(settingsModel: setting)
        
        dataStorage.saveAutoSyncModel(model: setting, uniqueUserId: uniqueUserID ?? "")
        SyncServiceManager.shared.updateSyncSettings(settingsModel: setting)
    }
    
    func checkPermissionForPhoto() {
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: true) { [weak self] (accessGranted, _) in
            self?.output.onCheckPermissionForPhoto(accessGranted: accessGranted)
        }
    }
}
