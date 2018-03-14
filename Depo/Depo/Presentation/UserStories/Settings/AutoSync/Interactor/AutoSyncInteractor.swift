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

    func prepareCellModels() {
        dataStorage.getAutoSyncSettingsForCurrentUser(success: { [weak self] settings, uniqueUserId in
            self?.output.prepaire(syncSettings: settings)
            self?.uniqueUserID = uniqueUserId
        })
    }
    
    func onSave(settings: AutoSyncSettings) {
        output.onSettingSaved()
        
        dataStorage.save(autoSyncSettings: settings, uniqueUserId: uniqueUserID ?? "")
        SyncServiceManager.shared.update(syncSettings: settings)
    }
    
    func checkPermissionForPhoto() {
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: true) { [weak self] accessGranted, _ in
            self?.output.onCheckPermissionForPhoto(accessGranted: accessGranted)
        }
    }
}
