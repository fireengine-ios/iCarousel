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
    case getBackUpStatus
    case cancelAllOperations
}

enum SyncOperationErrors {
    case accessDenied
    case failed
    case remoteServerError
    case networkError
    case internalError
}

class SyncContactsInteractor: SyncContactsInteractorInput {

    weak var output: SyncContactsInteractorOutput!
    
    let contactsSyncService = ContactsSyncService()
    
    func startOperation(operationType: SyncOperationType){
        switch operationType {
        case .backup:
            performOperation(forType: .backup)
        case .restore:
            performOperation(forType: .restore)
        case .cancelAllOperations:
            contactsSyncService.cancellCurrentOperation()
        case .getBackUpStatus:
            loadLastBackUp()
        }
    }
    
    func performOperation(forType type: SYNCMode) {
        contactsSyncService.executeOperation(type: type, progress: { [weak self] progressPercentage, type in
                DispatchQueue.main.async { [weak self] in
                    self?.output.showProggress(progress: progressPercentage, forOperation: type)
                }
            }, finishCallback: { result, type in
                DispatchQueue.main.async { [weak self] in
                    self?.output.success(object: result, forOperation: type)
                }
        }, errorCallback: { errortype, type in
            DispatchQueue.main.async { [weak self] in
                if self?.output != nil {
                    self?.output.showError(errorType: errortype)
                }
            }
        })
    }
    
    func loadLastBackUp() {
        contactsSyncService.getBackUpStatus(completion: { [weak self] (model) in
            self?.output.success(object: model, forOperation: .getBackUpStatus)
        }, fail: { [weak self] in
            self?.output.showNoBackUp()
        })
    }
}


