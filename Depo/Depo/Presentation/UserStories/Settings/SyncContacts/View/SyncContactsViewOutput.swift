//
//  SyncContactsSyncContactsViewOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SyncContactsViewOutput {

    /**
        @author Oleg
        Notify presenter that view is ready
    */

    func viewIsReady()
    
    func startOperation(operationType: SyncOperationType)
    
    func getDateLastUpdate()
    
}
