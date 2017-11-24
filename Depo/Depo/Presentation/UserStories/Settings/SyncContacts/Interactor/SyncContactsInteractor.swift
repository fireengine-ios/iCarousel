//
//  SyncContactsSyncContactsInteractor.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum SyncOperationType{
    case backup
    case restore
    case canselAllOperations
}

enum SyncOperationErrors{
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
        case .canselAllOperations:
            contactsSyncService.cancellCurrentOperation()
        }
    }
    
    func getLastBackUpDate() {
        DispatchQueue.main.async { [weak self] in
            
            let time = self?.contactsSyncService.getPreviousBackupTime()
            var date: Date? = nil
            
            if (time != nil ){
                date = Date(timeIntervalSince1970: time!/1000)
            }
            
            self?.output.lastBackUpDateResponse(response: date)
        }
    }
    
    func performOperation(forType type: SYNCMode) {
        contactsSyncService.executeOperation(type: type, progress: { [weak self] progressPercentage, type in
                DispatchQueue.main.async { [weak self] in
                    if self?.output != nil {
                        self?.output.showProggress(progress: progressPercentage, forOperation: type)
                    }
                }
            }, finishCallback: { result, type in
                DispatchQueue.main.async { [weak self] in
                    if self?.output != nil {
                        self?.output.succes(object: result, forOperation: type)
                    }
                }
        }, errorCallback: { errortype, type in
            DispatchQueue.main.async { [weak self] in
                if self?.output != nil {
                    self?.output.showError(errorType: errortype)
                }
            }
        })
    }
}


