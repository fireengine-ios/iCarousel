//
//  SyncContactsSyncContactsViewOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SyncContactsViewOutput {
    func viewIsReady()
    func viewWillAppear()
    func startOperation(operationType: SyncOperationType)
    func onManageContacts()
}
