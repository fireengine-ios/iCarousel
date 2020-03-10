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
class AutoSyncPresenter: BasePresenter, AutoSyncModuleInput, AutoSyncViewOutput, AutoSyncInteractorOutput {
    
    weak var view: AutoSyncViewInput!
    var interactor: AutoSyncInteractorInput!
    var router: AutoSyncRouterInput!
    
    var fromSettings: Bool = false

    func viewIsReady() {
        startAsyncOperationDisableScreen()
        interactor.checkPermissions()
    }
    
    func prepaire(syncSettings: AutoSyncSettings, albums: [AutoSyncAlbum]) {
        completeAsyncOperationEnableScreen()
        view.prepaire(syncSettings: syncSettings, albums: albums)
    }
    
    func change(settings: AutoSyncSettings) {
        if !fromSettings {
            router.routNextVC()
            save(settings: settings)
        } else {
            save(settings: settings)
        }
    }
    
    func save(settings: AutoSyncSettings) {
        interactor.onSave(settings: settings, fromSettings: fromSettings)
    }
    
    func onSettingSaved() {
        
    }
    
    func checkPermissions() {
        interactor.checkPermissions()
    }
    
    func onCheckPermissions(photoAccessGranted: Bool, locationAccessGranted: Bool) {
        guard photoAccessGranted else {
            view.disableAutoSync()
            view.checkPermissionsFailedWith(error: TextConstants.cameraAccessAlertText)
            return
        }
        
        /// location access is optional
        if !locationAccessGranted {
            view.showLocationPermissionPopup { [weak self] in
                self?.interactor.prepareCellModels()
            }
        } else {
            interactor.prepareCellModels()
        }
    }
        
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
