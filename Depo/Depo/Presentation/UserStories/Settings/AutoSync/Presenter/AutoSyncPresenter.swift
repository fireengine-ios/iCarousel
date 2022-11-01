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

    func saveSettings() {
        interactor.onSaveContact(settings: view.createAutoSyncSettings())
    }
    
    func viewIsReady() {
        interactor.trackScreen(fromSettings: fromSettings)
        startAsyncOperationDisableScreen()
        interactor.prepareCellModels()
        
//        dataSourceContact.setup(table: tableView)
//        dataSourceContact.delegate = self
        
        startAsyncOperationDisableScreen()
        interactor.prepareCellModelsContact()
    }
    
    func change(settings: AutoSyncSettings, albums: [AutoSyncAlbum]) {
        if !fromSettings {
            router.routNextVC()
        }
        save(settings: settings, albums: albums)
    }
    
    func save(settings: AutoSyncSettings, albums: [AutoSyncAlbum]) {
        interactor.onSave(settings: settings, albums: albums, fromSettings: fromSettings)
    }
    
    func checkPermissions() {
        interactor.checkPermissions()
    }
    
    func didChangeSettingsOption(settings: AutoSyncSetting) {
        interactor.trackSettings(settings, fromSettings: fromSettings)
    }
        
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    func onValueChangeContact() {
        onValueChanged()
    }
    
}

extension AutoSyncPresenter: PeriodicContactSyncDataSourceDelegate {
    func onValueChanged() {
        interactor.checkPermissionContact()
    }
}

//MARK: - AutoSyncInteractorOutput

extension AutoSyncPresenter: AutoSyncInteractorOutput {
    func operationFinished() {
        view?.stopActivityIndicator()
    }
    
    func showError(error: String) {
        UIApplication.showErrorAlert(message: error)
    }
    
    func prepaire(syncSettings: PeriodicContactsSyncSettings) {
        completeAsyncOperationEnableScreen()
        
        view.showCells(from: syncSettings)
    }
    
    func permissionSuccess() {
        interactor.onSaveContact(settings: view.createAutoSyncSettings())
    }
    
    func permissionFail() {
        view.forceDisableAutoSyncContact()
        router.showContactsSettingsPopUp()
    }
    
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
        interactor.trackTurnOnAutosync()
        completeAsyncOperationEnableScreen()
        view.checkPermissionsSuccessed()
    }
}
