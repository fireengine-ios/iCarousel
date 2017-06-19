//
//  AutoSyncDataStorage.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoSyncDataStorage: NSObject {
    func getAutoSyncModels() -> [AutoSyncModel]{
        var array = [AutoSyncModel]()
        array.append(AutoSyncModel.init(title: TextConstants.autoSyncCellWiFiTile, subTitle: TextConstants.autoSyncCellWiFiSubTitle, type: .typeSwitcher, selected: true))
        array.append(AutoSyncModel.init(title: TextConstants.autoSyncCellMobileDataTitle, subTitle: TextConstants.autoSyncCellMobileDataSubTitle, type: .typeSwitcher, selected: true))
        array.append(AutoSyncModel.init(title: TextConstants.autoSyncCellPhotos, subTitle: "", type: .typeInformation, selected: true))
        array.append(AutoSyncModel.init(title: TextConstants.autoSyncCellVideos, subTitle: "", type: .typeInformation, selected: true))
        return array
    }
}
