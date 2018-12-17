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
        interactor.trackScreen()
        startAsyncOperationDisableScreen()
        interactor.prepareCellModels()
    }
    
    func prepaire(syncSettings: AutoSyncSettings) {
        completeAsyncOperationEnableScreen()
        view.prepaire(syncSettings: syncSettings)
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
        interactor.onSave(settings: settings)
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
        
        if !locationAccessGranted {
            view.showLocationPermissionPopup { [weak self] in
                self?.view.checkPermissionsSuccessed()
            }
        } else {
            if !AuthoritySingleton.shared.isShowedPopupAboutPremiumAfterSync,
                !AuthoritySingleton.shared.isPremium {
                AuthoritySingleton.shared.setShowedPopupAboutPremiumAfterSync(isShow: true)
                
                router.showPopupForNewUser(with: TextConstants.syncPopup,
                                           title: TextConstants.lifeboxPremium,
                                           headerTitle: TextConstants.becomePremiumMember)
            }
            view.checkPermissionsSuccessed()
        }
    }
        
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
