//
//  SyncContactsSyncContactsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SyncContactsPresenter: SyncContactsModuleInput, SyncContactsViewOutput, SyncContactsInteractorOutput {

    weak var view: SyncContactsViewInput!
    var interactor: SyncContactsInteractorInput!
    var router: SyncContactsRouterInput!

    var backupAvailable: Bool = false
    
    //MARK: view out
    func viewIsReady() {
        view.setupInitialState()
    }
    
    func getDateLastUpdate(){
        interactor.getLastBackUpDate()
    }
    
    func startOperation(operationType: SyncOperationType){
        if backupAvailable, operationType == .backup {
            let controller = PopUpController.with(title: TextConstants.errorAlerTitleBackupAlreadyExist,
                                                  message: TextConstants.errorAlertTextBackupAlreadyExist,
                                                  image: .error,
                                                  firstButtonTitle: TextConstants.errorAlertNopeBtnBackupAlreadyExist,
                                                  secondButtonTitle: TextConstants.errorAlertYesBtnBackupAlreadyExist,
                                                  secondAction: { [weak self] vc in
                                                    self?.interactor.startOperation(operationType: .backup)
            })
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
            return
        }
        
        interactor.startOperation(operationType: operationType)
    }
    
    //MARK: interactor out
    
    func showError(errorType: SyncOperationErrors){
        
    }
    
    func showProggress(progress :Int, forOperation operation: SyncOperationType){
        view.showProggress(progress: progress, forOperation: operation)
    }
    
    func succes(object: ContactSyncResposeModel, forOperation operation: SyncOperationType){
        view.succes(object: object, forOperation: operation)
    }
    
    func lastBackUpDateResponse(response: Date?){
        backupAvailable = response == nil ? false : true
        view.setDateLastBacup(dateLastBacup: response)
    }
}
