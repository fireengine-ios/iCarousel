//
//  AutoSyncAutoSyncInteractorInput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol AutoSyncInteractorInput {
    func prepareCellsModels()

    func onSaveSettings(setting: SettingsAutoSyncModel)
    
    func checkPermissionForPhoto()
}
