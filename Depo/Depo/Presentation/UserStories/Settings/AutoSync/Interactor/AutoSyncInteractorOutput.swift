//
//  AutoSyncAutoSyncInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol AutoSyncInteractorOutput: AnyObject {
    
    func prepaire(syncSettings: AutoSyncSettings, albums: [AutoSyncAlbum])
    
    func checkPhotoPermissionsFailed()
    
    func onCheckPermissions(photoAccessGranted: Bool, locationAccessGranted: Bool)

    // Contact
    func operationFinished()
    func showError(error: String)
    func prepaire(syncSettings: PeriodicContactsSyncSettings)
    func permissionSuccess()
    func permissionFail()
}
