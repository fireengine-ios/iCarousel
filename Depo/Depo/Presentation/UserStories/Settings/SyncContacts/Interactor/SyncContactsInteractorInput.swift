//
//  SyncContactsSyncContactsInteractorInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SyncContactsInteractorInput {
    func startOperation(operationType: SyncOperationType)
    func trackScreen()
    func analyze()
    func performOperation(forType type: SYNCMode)
    func getUserStatus()
    func getStoredContactsCount() -> Int
}
