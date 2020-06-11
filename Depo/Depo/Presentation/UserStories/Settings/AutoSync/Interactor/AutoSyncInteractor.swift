//
//  AutoSyncAutoSyncInteractor.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

final class AutoSyncInteractor: AutoSyncInteractorInput {
    weak var output: AutoSyncInteractorOutput!

    private var dataStorage = AutoSyncDataStorage()
    private let localMediaStorage = LocalMediaStorage.default
    private lazy var locationManager = LocationManager.shared
    private let analyticsManager: AnalyticsService = factory.resolve()
    private let albumsService = MediaItemsAlbumOperationService.shared
    
    func prepareCellModels() {
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] photoAccessGranted, _ in
            if photoAccessGranted {
                self?.albumsService.getAutoSyncAlbums { [weak self] albums in
                    guard let self = self else {
                        return
                    }
                    
                    let settings = self.dataStorage.settings
                    DispatchQueue.main.async {
                        self.output.prepaire(syncSettings: settings, albums: albums)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.output.checkPhotoPermissionsFailed()
                }
            }
        }
    }
    
    func trackScreen(fromSettings: Bool) {
        AnalyticsService.sendNetmeraEvent(event: fromSettings ? NetmeraEvents.Screens.AutoSyncScreen() : NetmeraEvents.Screens.FirstAutoSyncScreen())
        analyticsManager.logScreen(screen: fromSettings ? .autoSyncSettings : .autosyncSettingsFirst)
        analyticsManager.trackDimentionsEveryClickGA(screen: fromSettings ? .autoSyncSettings : .autosyncSettingsFirst)
    }
    
    func trackTurnOnAutosync() {
        analyticsManager.track(event: .turnOnAutosync)
    }
    
    func trackSettings(_ settings: AutoSyncSetting, fromSettings: Bool) {
        let eventAction: GAEventAction = fromSettings ? .settingsAutoSync : .firstAutoSync
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: eventAction, eventLabel: GAEventLabel.getAutoSyncSettingEvent(autoSyncSettings: settings))
    }
    
    func onSave(settings: AutoSyncSettings, albums: [AutoSyncAlbum], fromSettings: Bool) {
        AnalyticsService.sendNetmeraEvent(event: fromSettings ? NetmeraEvents.Actions.Autosync(autosyncSettings: settings) : NetmeraEvents.Actions.FirstAutosync(autosyncSettings: settings))
        dataStorage.save(autoSyncSettings: settings, fromSettings: fromSettings)
        SyncServiceManager.shared.update(syncSettings: settings)
        albumsService.saveAutoSyncAlbums(albums)
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
}
