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

    func onSave(settings: AutoSyncSettings, selectedAlbums: [AutoSyncAlbum], fromSettings: Bool)
    
    func trackScreen(fromSettings: Bool)
    
    func checkPermissions()
}
