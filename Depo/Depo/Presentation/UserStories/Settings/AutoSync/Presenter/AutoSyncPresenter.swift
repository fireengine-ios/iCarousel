//
//  AutoSyncAutoSyncPresenter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncPresenter: BasePresenter, AutoSyncModuleInput, AutoSyncViewOutput, AutoSyncInteractorOutput, CustomPopUpAlertActions {
    
    weak var view: AutoSyncViewInput!
    var interactor: AutoSyncInteractorInput!
    var router: AutoSyncRouterInput!
    
    let customPopUp = CustomPopUp()

    func viewIsReady() {
        startAsyncOperationDisableScreen()
        interactor.prepareCellsModels()
    }
    
    func preperedCellsModels(models:[AutoSyncModel]){
         compliteAsyncOperationEnableScreen()
        view.preperedCellsModels(models: models)
    }
    
    func startLifeBoxPressed() {
        //TODO: call interactor with collected data
        router.routNextVC()
    }
    
    func skipForNowPressed() {
        customPopUp.delegate = self
        customPopUp.showCustomAlert(withTitle: TextConstants.autoSyncAlertTitle,
                                    titleAligment: .left,
                                    withText: TextConstants.autoSyncAlertText,
                                    warningTextAligment: .left,
                                    firstButtonText: TextConstants.autoSyncAlertNo,
                                    secondButtonText: TextConstants.autoSyncAlertYes,
                                    isShadowViewShown: true)
    }
    
    func cancelationAction() {
        
    }
    
    func otherAction() {
        router.routNextVC()
    }
    
    func saveСhanges(setting: SettingsAutoSyncModel){
        interactor.onSaveSettings(setting: setting)
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
