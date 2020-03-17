//
//  AutoSyncAutoSyncInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol AutoSyncInteractorOutput: class {
    
    func prepaire(syncSettings: AutoSyncSettings, albums: [AutoSyncAlbum])
    
    func checkPhotoPermissionsFailed()
    
    func onCheckPermissions(photoAccessGranted: Bool, locationAccessGranted: Bool)

}
