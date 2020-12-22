//
//  PeriodContactsSyncModel.swift
//  Depo
//
//  Created by Brothers Harhun on 20.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class PeriodContactsSyncModel {
    let titleString: String
    var syncSetting: PeriodicContactsSyncSetting?
    var isSelected: Bool
    
    init(title: String, setting: PeriodicContactsSyncSetting?, selected: Bool) {
        titleString = title
        isSelected = selected
        syncSetting = setting
    }
    
    init(model: PeriodContactsSyncModel, selected: Bool) {
        titleString = model.titleString
        isSelected = selected
        syncSetting = model.syncSetting
    }
    
}
