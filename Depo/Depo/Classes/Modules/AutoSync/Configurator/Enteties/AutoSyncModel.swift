//
//  AutoSyncModel.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum AutoSyncCellType {
    case typeSwitcher
    case typeInformation
}

struct AutoSyncModel {
    let titleString: String
    let subTitleString: String
    let cellType: AutoSyncCellType
    let isSelected: Bool
    
    init(title: String, subTitle: String, type: AutoSyncCellType, selected: Bool) {
        titleString = title
        subTitleString = subTitle
        cellType = type
        isSelected = selected
    }
    
    init(model: AutoSyncModel, selected: Bool){
        titleString = model.titleString
        subTitleString = model.subTitleString
        cellType = model.cellType
        isSelected = selected
    }
    
}
