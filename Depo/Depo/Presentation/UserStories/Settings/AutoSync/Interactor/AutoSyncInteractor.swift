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
    private let analyticsManager: AnalyticsService = factory.resolve()
    
    func prepareCellModels() {
        let settings = dataStorage.settings
        output.prepaire(syncSettings: settings)
    }
    
    func onSave(settings: AutoSyncSettings, fromSettings: Bool) {
        ///Sending autoSyncStatus when settings changed
        if dataStorage.settings != settings || !fromSettings {
            /// There is no scenario both success and error for now. Just sending BE
            AccountService().autoSyncStatus(syncSettings: settings) { result in
                switch result {
                case .success(_):
                    print(result)
                case .failed(let error):
                    print(error.description)
                }
            }
        }
        
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
                let locationAccessGranted = (status != .restricted)
                
                self?.output.onCheckPermissions(photoAccessGranted: photoAccessGranted, locationAccessGranted: locationAccessGranted)
            }
        }
    }
    
    func trackScreen() {
        analyticsManager.logScreen(screen: .autoSyncSettings)
        analyticsManager.trackDimentionsEveryClickGA(screen: .autoSyncSettings)
    }
    
}
