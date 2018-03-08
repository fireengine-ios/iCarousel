//
//  AutoSyncModel.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum AutoSyncCellType {
    case headerLike//same as switcher but larger
    case typeSwitcher
    case typeSwitherActivator
    case typeInformation
}

class AutoSyncModel {
    let titleString: String
    let subTitleString: String
    let cellType: AutoSyncCellType
    var isSelected: Bool
    
    init(title: String, subTitle: String, type: AutoSyncCellType, selected: Bool) {
        titleString = title
        subTitleString = subTitle
        cellType = type
        isSelected = selected
    }
    
    init(model: AutoSyncModel, selected: Bool) {
        titleString = model.titleString
        subTitleString = model.subTitleString
        cellType = model.cellType
        isSelected = selected
    }
    
}
