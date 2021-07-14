//
//  PeriodicContactSyncInteractorOutput.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol PeriodicContactSyncInteractorOutput: AnyObject {
    func operationFinished()
    func showError(error: String)
    
    func prepaire(syncSettings: PeriodicContactsSyncSettings)

    func permissionSuccess()
    func permissionFail()
}

