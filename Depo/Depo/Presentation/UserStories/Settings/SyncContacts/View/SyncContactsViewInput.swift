//
//  SyncContactsSyncContactsViewInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SyncContactsViewInput: class {
    func setInitialState()
    func setStateWithoutBackUp()
    func setStateWithBackUp()
    
    func showProggress(progress :Int, forOperation operation: SyncOperationType)
    func success(object: ContactSync.SyncResponse, forOperation operation: SyncOperationType)
}
