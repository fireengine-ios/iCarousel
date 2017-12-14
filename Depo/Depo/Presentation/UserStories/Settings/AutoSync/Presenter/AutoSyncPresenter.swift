//
//  AutoSyncAutoSyncPresenter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncPresenter: BasePresenter, AutoSyncModuleInput, AutoSyncViewOutput, AutoSyncInteractorOutput {
    
    weak var view: AutoSyncViewInput!
    var interactor: AutoSyncInteractorInput!
    var router: AutoSyncRouterInput!

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
        interactor.onSaveSettings(setting: setting)
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
