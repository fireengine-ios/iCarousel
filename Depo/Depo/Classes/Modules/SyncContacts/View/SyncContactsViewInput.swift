//
//  SyncContactsSyncContactsViewInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SyncContactsViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState()
    
    func setupStateWithoutBacup()
    func showProggress(progress :Int, forOperation operation: SyncOperationType)
    func succes(object: ContactSyncResposeModel, forOperation operation: SyncOperationType)
    func setDateLastBacup(dateLastBacup: Date?)
}
