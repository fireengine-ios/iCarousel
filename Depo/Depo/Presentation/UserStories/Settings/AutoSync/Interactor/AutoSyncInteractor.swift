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
    
    private var albums = [AutoSyncAlbum]()
    
    func prepareCellModels() {
        getAlbums { [weak self] albums in
            guard let self = self else {
                return
            }
            
            let settings = self.dataStorage.settings
            self.output.prepaire(syncSettings: settings, albums: albums)
        }
    }
    
    func trackScreen(fromSettings: Bool) {
        AnalyticsService.sendNetmeraEvent(event: fromSettings ? NetmeraEvents.Screens.FirstAutoSyncScreen() : NetmeraEvents.Screens.AutoSyncScreen())
    }
    
    func onSave(settings: AutoSyncSettings, fromSettings: Bool) {
        AnalyticsService.sendNetmeraEvent(event: fromSettings ? NetmeraEvents.Actions.Autosync(autosyncSettings: settings) : NetmeraEvents.Actions.FirstAutosync(autosyncSettings: settings))
        output.onSettingSaved()
        dataStorage.save(autoSyncSettings: settings , fromSettings: fromSettings)
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
    
    private func getAlbums(completion: @escaping (_ albums: [AutoSyncAlbum]) -> Void) {
        if !albums.isEmpty {
            completion(albums)
            return
        }

        localMediaStorage.getLocalAlbums { assets in
            var albums = assets.map { AutoSyncAlbum(asset: $0) }
            if let mainAlbum = albums.first(where: { $0.name == AutoSyncAlbum.mainAlbumName }) {
                albums.remove(mainAlbum)
                albums.insert(mainAlbum, at: 0)
            }
            
            completion(albums)
        }
    }
}
