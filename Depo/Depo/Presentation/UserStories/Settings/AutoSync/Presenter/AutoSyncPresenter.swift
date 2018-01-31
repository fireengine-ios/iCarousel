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
        interactor.prepareCellsModels()
    }
    
    func preperedCellsModels(models:[AutoSyncModel]){
         compliteAsyncOperationEnableScreen()
        view.preperedCellsModels(models: models)
    }
    
    func skipForNowPressed() {
        let controller = PopUpController.with(title: TextConstants.autoSyncAlertTitle,
                                              message: TextConstants.autoSyncAlertText,
                                              image: .none,
                                              firstButtonTitle: TextConstants.autoSyncAlertNo,
                                              secondButtonTitle: TextConstants.autoSyncAlertYes,
                                              secondAction: { [weak self] vc in
                                                self?.router.routNextVC()
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
    
    func saveChanges(setting: SettingsAutoSyncModel){
        if !fromSettings {
            let dataSyncEnabled = setting.isAutoSyncEnable && (setting.mobileDataPhotos == true || setting.mobileDataVideo == true)
            if dataSyncEnabled {
                router.showSyncOverPopUp(okHandler: {[weak self] in
                    self?.router.routNextVC()
                    self?.interactor.onSaveSettings(setting: setting)
                })
            } else {
                router.routNextVC()
                saveSettings(setting)
            }
        } else {
            saveSettings(setting)
        }
    }
    
    func saveSettings(_ setting: SettingsAutoSyncModel) {
        interactor.onSaveSettings(setting: setting)
    }
    
    
    func onSettingSaved(){
        
    }
    
    func enableAutoSync() {
        interactor.checkPermissionForPhoto()
    }
    
    func onCheckPermissionForPhoto(accessGranted: Bool) {
        if accessGranted {
            view.reloadTableView()
        } else {
            view.disableAutoSync()
        }
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
