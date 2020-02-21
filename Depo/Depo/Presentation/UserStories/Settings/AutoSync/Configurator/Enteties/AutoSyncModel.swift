//
//  AutoSyncModel.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit


enum AutoSyncSettingsRowType: Int {
    case headerSlider
    case photoSetting
    case videoSetting
}


class AutoSyncModel {
    let titleString: String
    let subTitleString: String
    let cellType: AutoSyncSettingsRowType
    var syncSetting: AutoSyncSetting?
    var isSelected: Bool
    var height: CGFloat {
        if cellType != .headerSlider {
            return isSelected ? 228 : 68
        }
        
        return 44
    }
    
    
    init(title: String, subTitle: String, type: AutoSyncSettingsRowType, setting: AutoSyncSetting?, selected: Bool) {
        titleString = title
        subTitleString = subTitle
        cellType = type
        isSelected = selected
        syncSetting = setting
    }
    
    init(model: AutoSyncModel, selected: Bool) {
        titleString = model.titleString
        subTitleString = model.subTitleString
        cellType = model.cellType
        isSelected = selected
        syncSetting = model.syncSetting
    }
    
}
