//
//  SyncContactsSyncContactsPresenter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SyncContactsPresenter: BasePresenter, SyncContactsModuleInput, SyncContactsViewOutput, SyncContactsInteractorOutput {
    
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
                                                    self?.view.setOperationState(operationType: operationType)
                                                    vc.close()
            })
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
            
        } else {
            view.setOperationState(operationType: operationType)
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
    
    func success(response: ContactSync.SyncResponse, forOperation operation: SyncOperationType) {
        isBackUpAvailable = true
        view.success(response: response, forOperation: operation)
    }
    
    func analyzeSuccess(response: [ContactSync.AnalyzedContact]) {
        if response.count > 0 {
            router.goToDuplicatedContacts(with: response, moduleOutput: self)
        } else {
            let controller = PopUpController.with(title: "",
                                 message: TextConstants.errorAlertTextNoDuplicatedContacts,
                                 image: .none, buttonTitle: TextConstants.ok)
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
            interactor.startOperation(operationType: .cancel)
        }
    }
    
    func cancelSuccess() {
        if isBackUpAvailable, let view = view {
            view.setStateWithBackUp()
        } else {
            view.setStateWithoutBackUp()
        }
    }
    
    func onManageContacts() {
        router.goToManageContacts()
    }
    
    func onDeinit() {
        interactor.startOperation(operationType: .cancel)
    }
    
    func showNoBackUp() {
        view.setStateWithoutBackUp()
    }
    
    func asyncOperationStarted() {
        outputView()?.showSpiner()
    }
    
    func asyncOperationFinished() {
        outputView()?.hideSpiner()
    }
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

extension SyncContactsPresenter: DuplicatedContactsModuleOutput {
    func cancelDeletingDuplicatedContacts() {
        interactor.startOperation(operationType: .cancel)
    }
    
    func deleteDuplicatedContacts() {
        interactor.startOperation(operationType: .deleteDuplicated)
    }
}
