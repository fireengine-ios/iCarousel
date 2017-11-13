//
//  SyncContactsSyncContactsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SyncContactsPresenter: SyncContactsModuleInput, SyncContactsViewOutput, SyncContactsInteractorOutput, CustomPopUpAlertActions {

    weak var view: SyncContactsViewInput!
    var interactor: SyncContactsInteractorInput!
    var router: SyncContactsRouterInput!
    
    let customPopUp = CustomPopUp()

    var backupAvailable: Bool = false
    
    //MARK: view out
    func viewIsReady() {
        view.setupInitialState()
    }
    
    func getDateLastUpdate(){
        interactor.getLastBackUpDate()
    }
    
    func startOperation(operationType: SyncOperationType){
        if operationType == .backup, backupAvailable {
            customPopUp.delegate = self
            customPopUp.showCustomAlert(withTitle: TextConstants.errorAlerTitleBackupAlreadyExist,
                                        withText: TextConstants.errorAlertTextBackupAlreadyExist,
                                        firstButtonText: TextConstants.errorAlertNopeBtnBackupAlreadyExist,
                                        secondButtonText: TextConstants.errorAlertYesBtnBackupAlreadyExist)
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
    
    //MARK: alert delegate
    
    func cancelationAction() {
        
    }
    
    func otherAction() {
        interactor.startOperation(operationType: .backup)
    }
}
