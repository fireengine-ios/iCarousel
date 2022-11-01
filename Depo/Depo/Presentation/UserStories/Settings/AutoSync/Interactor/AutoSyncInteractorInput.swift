//
//  AutoSyncAutoSyncInteractorInput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol AutoSyncInteractorInput {
    func prepareCellModels()

    func onSave(settings: AutoSyncSettings, albums: [AutoSyncAlbum], fromSettings: Bool)
    
    func trackScreen(fromSettings: Bool)
    func trackTurnOnAutosync()
    func trackSettings(_ settings: AutoSyncSetting, fromSettings: Bool)
    
    func checkPermissions()
    
    // Contact
    func prepareCellModelsContact()
    func checkPermissionContact()
    func onSaveContact(settings: PeriodicContactsSyncSettings)
}
