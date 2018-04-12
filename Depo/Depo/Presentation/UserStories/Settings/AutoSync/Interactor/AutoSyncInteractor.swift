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
    let localMediaStorage = LocalMediaStorage.default

    func prepareCellModels() {
        let settings = dataStorage.settings
        output.prepaire(syncSettings: settings)
    }
    
    func onSave(settings: AutoSyncSettings) {
        output.onSettingSaved()
        dataStorage.save(autoSyncSettings: settings)
        SyncServiceManager.shared.update(syncSettings: settings)
    }
    
    func checkPermissionForPhoto() {
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: true) { [weak self] accessGranted, _ in
            self?.output.onCheckPermissionForPhoto(accessGranted: accessGranted)
        }
    }
}
