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
        interactor.prepareCellModels()
    }
    
    func prepaire(syncSettings: AutoSyncSettings) {
        completeAsyncOperationEnableScreen()
        view.prepaire(syncSettings: syncSettings)
    }
    
    func skipForNowPressed(onSyncDisabled: @escaping VoidHandler) {
        let controller = PopUpController.with(title: TextConstants.autoSyncAlertTitle,
                                              message: TextConstants.autoSyncAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.autoSyncAlertNo,
                                              secondButtonTitle: TextConstants.autoSyncAlertYes,
                                              secondAction: { [weak self] vc in
                                                onSyncDisabled()
                                                self?.router.routNextVC()
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
    
    func change(settings: AutoSyncSettings) {
        if !fromSettings {
            let photoOption = settings.photoSetting.option
            let videoOption = settings.videoSetting.option
            let dataSyncEnabled = settings.isAutoSyncOptionEnabled && (photoOption == .wifiAndCellular || videoOption == .wifiAndCellular)
            if dataSyncEnabled {
                router.showSyncOverPopUp(okHandler: {[weak self] in
                    self?.router.routNextVC()
                    self?.interactor.onSave(settings: settings)
                })
            } else {
                router.routNextVC()
                save(settings: settings)
            }
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
            view.checkPermissionsFailedWith(error: TextConstants.locationServiceDisable)
        }
        
        view.checkPermissionsSuccessed()
    }
        
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
