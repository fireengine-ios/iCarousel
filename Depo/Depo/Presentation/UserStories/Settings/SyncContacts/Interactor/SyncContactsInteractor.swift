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
            output.cancellSuccess()
        case .getBackUpStatus:
            loadLastBackUp()
        case .analyze:
            analyze()
        case .deleteDuplicated:
            deleteDuplicated()
        }
    }
    
    func performOperation(forType type: SYNCMode) {
        contactsSyncService.executeOperation(type: type, progress: { [weak self] progressPercentage, type in
                DispatchQueue.main.async { [weak self] in
                    self?.output.showProggress(progress: progressPercentage, forOperation: type)
                }
            }, finishCallback: { (result, type) in
                DispatchQueue.main.async { [weak self] in
                    self?.output.success(response: result, forOperation: type)
                }
        }, errorCallback: { errorType, type in
            DispatchQueue.main.async { [weak self] in
                self?.output.showError(errorType: errorType)
            }
        })
    }
    
    private func loadLastBackUp() {
        output.asyncOperationStarted()
        contactsSyncService.getBackUpStatus(completion: { [weak self] (model) in
            self?.output.success(response: model, forOperation: .getBackUpStatus)
            self?.output.asyncOperationFinished()
        }, fail: { [weak self] in
            self?.output.showNoBackUp()
            self?.output.asyncOperationFinished()
        })
    }
    
    private func analyze() {
        contactsSyncService.analyze(progressCallback: { [weak self] (progressPercentage, type) in
            DispatchQueue.main.async { [weak self] in
                self?.output.showProggress(progress: progressPercentage, forOperation: type)
            }
        }, finishCallback: { (response) in
            DispatchQueue.main.async { [weak self] in
                self?.output.analyzeSuccess(response: response)
            }
        }) { (errorType, type) in
            DispatchQueue.main.async { [weak self] in
                self?.output.showError(errorType: errorType)
            }
        }
    }
    
    private func deleteDuplicated() {
        
    }
}


