//
//  AutoSyncAutoSyncPresenter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//


/**
 logic from android page
 https://wiki.life.com.by/display/LTFizy/004+Auto+Sync+page+Android
 
 texts from iOS
 https://wiki.life.com.by/display/LTFizy/004+Auto+Sync+iOS
 */
class AutoSyncPresenter: BasePresenter, AutoSyncModuleInput, AutoSyncViewOutput {
    
    weak var view: AutoSyncViewInput!
    var interactor: AutoSyncInteractorInput!
    var router: AutoSyncRouterInput!
    
    var fromSettings = false

    func viewIsReady() {
        startAsyncOperationDisableScreen()
        interactor.prepareCellModels()
    }
    
    func change(settings: AutoSyncSettings, selectedAlbums: [AutoSyncAlbum]) {
        if !fromSettings {
            router.routNextVC()
        }
        save(settings: settings, selectedAlbums: selectedAlbums)
        
    }
    
    func save(settings: AutoSyncSettings, selectedAlbums: [AutoSyncAlbum]) {
        interactor.onSave(settings: settings, selectedAlbums: selectedAlbums, fromSettings: fromSettings)
    }
    
    func checkPermissions() {
        interactor.checkPermissions()
    }
        
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}

//MARK: - AutoSyncInteractorOutput

extension AutoSyncPresenter: AutoSyncInteractorOutput {
    func prepaire(syncSettings: AutoSyncSettings, albums: [AutoSyncAlbum]) {
        completeAsyncOperationEnableScreen()
        view.prepaire(syncSettings: syncSettings, albums: albums)
    }
    
    func checkPhotoPermissionsFailed() {
        completeAsyncOperationEnableScreen()
        view.disableAutoSync()
        view.checkPermissionsFailedWith(error: TextConstants.cameraAccessAlertText)
    }
    
    func onCheckPermissions(photoAccessGranted: Bool, locationAccessGranted: Bool) {
        guard photoAccessGranted else {
            checkPhotoPermissionsFailed()
            return
        }
        
        /// location access is optional
        if !locationAccessGranted {
            view.showLocationPermissionPopup { [weak self] in
                self?.checkPermissionsSuccessed()
            }
        } else {
            checkPermissionsSuccessed()
        }
    }
    
    private func checkPermissionsSuccessed() {
        completeAsyncOperationEnableScreen()
        view.checkPermissionsSuccessed()
    }
}
