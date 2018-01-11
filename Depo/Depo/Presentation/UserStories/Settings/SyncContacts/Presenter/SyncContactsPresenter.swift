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

    var isBackUpAvailable: Bool = false
    
    //MARK: view out
    func viewIsReady() {
        view.setInitialState()
        startOperation(operationType: .getBackUpStatus)
    }
    
    func startOperation(operationType: SyncOperationType) {
        if isBackUpAvailable, operationType == .backup {
            let controller = PopUpController.with(title: TextConstants.errorAlerTitleBackupAlreadyExist,
                                                  message: TextConstants.errorAlertTextBackupAlreadyExist,
                                                  image: .error,
                                                  firstButtonTitle: TextConstants.errorAlertNopeBtnBackupAlreadyExist,
                                                  secondButtonTitle: TextConstants.errorAlertYesBtnBackupAlreadyExist,
                                                  secondAction: { [weak self] vc in
                                                    self?.interactor.startOperation(operationType: .backup)
                                                    vc.close()
            })
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
        } else {
            interactor.startOperation(operationType: operationType)
        }
    }
    
    //MARK: Interactor Output
    
    func showError(errorType: SyncOperationErrors) {
        view.setStateWithoutBackUp()
        isBackUpAvailable = false
    }
    
    func showProggress(progress: Int, forOperation operation: SyncOperationType) {
        view.showProggress(progress: progress, forOperation: operation)
    }
    
    func success(object: ContactSyncResposeModel, forOperation operation: SyncOperationType) {
        isBackUpAvailable = true
        view.success(object: object, forOperation: operation)
    }
    
    func onManageContacts() {
        router.goToManageContacts()
    }
    
    func showNoBackUp() {
        view.setStateWithoutBackUp()
    }
}
