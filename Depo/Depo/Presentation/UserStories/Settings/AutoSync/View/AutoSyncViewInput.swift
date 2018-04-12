//
//  AutoSyncAutoSyncViewInput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol AutoSyncViewInput: class {

    func setupInitialState()
    func prepaire(syncSettings: AutoSyncSettings)
    func disableAutoSync()
    func checkPermissionsSuccessed()
    func checkPermissionsFailedWith(error: String)
}
