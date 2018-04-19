//
//  AutoSyncAutoSyncInteractor.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncInteractor: AutoSyncInteractorInput {

    weak var output: AutoSyncInteractorOutput!

    private var dataStorage = AutoSyncDataStorage()
    private let localMediaStorage = LocalMediaStorage.default
    private lazy var locationManager = LocationManager.shared

    func prepareCellModels() {
        let settings = dataStorage.settings
        output.prepaire(syncSettings: settings)
    }
    
    func onSave(settings: AutoSyncSettings) {
        output.onSettingSaved()
        dataStorage.save(autoSyncSettings: settings)
        SyncServiceManager.shared.update(syncSettings: settings)
    }
    
    func checkPermissions() {
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] photoAccessGranted, _ in
            guard photoAccessGranted else {
                self?.output.onCheckPermissions(photoAccessGranted: photoAccessGranted, locationAccessGranted: false)
                return
            }

            self?.locationManager.authorizationStatus { [weak self] status in
                let locationAccessGranted = (status == .authorizedAlways)
                
                self?.output.onCheckPermissions(photoAccessGranted: photoAccessGranted, locationAccessGranted: locationAccessGranted)
            }
        }
    }
}
