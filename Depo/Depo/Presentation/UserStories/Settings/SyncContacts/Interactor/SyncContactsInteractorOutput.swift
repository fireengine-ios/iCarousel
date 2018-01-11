//
//  SyncContactsSyncContactsInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SyncContactsInteractorOutput: class {
    func showError(errorType: SyncOperationErrors)
    func showProggress(progress :Int, forOperation operation: SyncOperationType)
    func success(object: ContactSyncResposeModel, forOperation operation: SyncOperationType)
    func showNoBackUp()
}
