//
//  SyncContactsSyncContactsInteractor.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum SyncOperationType {
    case backup
    case restore
    case analyze
    case deleteDuplicated
    case getBackUpStatus
    case cancel
}

enum SyncOperationErrors {
    case accessDenied
    case failed
    case remoteServerError
    case networkError
    case internalError
}

class SyncContactsInteractor: SyncContactsInteractorInput {

    weak var output: SyncContactsInteractorOutput?
    
    let contactsSyncService = ContactsSyncService()
    
    func startOperation(operationType: SyncOperationType){
        switch operationType {
        case .backup:
            performOperation(forType: .backup)
        case .restore:
            performOperation(forType: .restore)
        case .cancel:
            contactsSyncService.cancel()
            output?.cancelSuccess()
        case .getBackUpStatus:
            loadLastBackUp()
        case .analyze:
            analyze()
        case .deleteDuplicated:
            deleteDuplicated()
        }
    }
    
    func performOperation(forType type: SYNCMode) {
        contactsSyncService.executeOperation(type: type, progress: { [weak self] (progressPercentage, type) in
                DispatchQueue.main.async {
                    self?.output?.showProggress(progress: progressPercentage, forOperation: type)
                }
            }, finishCallback: { [weak self] (result, type) in
                DispatchQueue.main.async {
                    self?.output?.success(response: result, forOperation: type)
                    CardsManager.default.stopOperationWithType(type: .contactBacupOld)
                    CardsManager.default.stopOperationWithType(type: .contactBacupEmpty)
                }
        }, errorCallback: { [weak self] (errorType, type) in
            DispatchQueue.main.async {
                self?.output?.showError(errorType: errorType)
            }
        })
    }
    
    private func loadLastBackUp() {
        output?.asyncOperationStarted()
        contactsSyncService.getBackUpStatus(completion: { [weak self] (model) in
            self?.output?.success(response: model, forOperation: .getBackUpStatus)
            self?.output?.asyncOperationFinished()
        }, fail: { [weak self] in
            self?.output?.showNoBackUp()
            self?.output?.asyncOperationFinished()
        })
    }
    
    private func analyze() {
        
        contactsSyncService.analyze(progressCallback: { [weak self] (progressPercentage, type) in
            DispatchQueue.main.async {
                self?.output?.showProggress(progress: progressPercentage, forOperation: type)
            }
        }, successCallback: { [weak self] (response) in
            DispatchQueue.main.async {
                self?.output?.analyzeSuccess(response: response)
            }
        }, cancelCallback: nil,
           errorCallback: { [weak self] (errorType, type) in
            DispatchQueue.main.async {
                self?.output?.showError(errorType: errorType)
            }
        })
    }
    
    private func deleteDuplicated() {
        contactsSyncService.deleteDuplicates()
    }
}
