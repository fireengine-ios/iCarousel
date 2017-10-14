//
//  SettingsAutoSyncModel.swift
//  Depo
//
//  Created by Oleg on 11.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class SettingsAutoSyncModel {
    
    static let isAutoSyncEnableKey  = "isAutoSyncEnable"
    static let isSyncViaWifiKey     = "isSyncViaWifi"
    static let mobileDataPhotosKey  = "mobileDataPhotos"
    static let mobileDataVideoKey   = "mobileDataVideo"
    
    var isAutoSyncEnable: Bool = false
    var isSyncViaWifi: Bool = true
    var mobileDataPhotos: Bool = false
    var mobileDataVideo: Bool = false
    
    static let autoSyncEnableIndex: Int = 0
    //static let autoSyncViaWiFiIndex: Int = 1
    static let mobileDataPhotosIndex: Int = 3
    static let mobileDataVideoIndex: Int = 4

    func configurateWithDictionary(dictionary: [String: Bool]) {
        isAutoSyncEnable = dictionary[SettingsAutoSyncModel.isAutoSyncEnableKey] ?? false
        isSyncViaWifi = dictionary[SettingsAutoSyncModel.isSyncViaWifiKey] ?? true
        mobileDataPhotos = dictionary[SettingsAutoSyncModel.mobileDataPhotosKey] ?? false
        mobileDataVideo = dictionary[SettingsAutoSyncModel.mobileDataVideoKey] ?? false
    }
    
    func configurateDictionary() -> [String: Bool] {
        var dict = [String: Bool]()
        dict[SettingsAutoSyncModel.isAutoSyncEnableKey] = isAutoSyncEnable
        dict[SettingsAutoSyncModel.isSyncViaWifiKey] = isSyncViaWifi
        dict[SettingsAutoSyncModel.mobileDataPhotosKey] = mobileDataPhotos
        dict[SettingsAutoSyncModel.mobileDataVideoKey] = mobileDataVideo
        return dict
    }
    
    func getDataForTable() -> [AutoSyncModel]{
        var array = [AutoSyncModel]()
        array.append(AutoSyncModel.init(title: TextConstants.autoSyncNavigationTitle, subTitle: "", type: .headerLike, selected: isAutoSyncEnable))
        array.append(AutoSyncModel.init(title: TextConstants.autoSyncCellWiFiTile, subTitle: TextConstants.autoSyncCellWiFiSubTitle, type: .typeInformation, selected: isSyncViaWifi))
        array.append(AutoSyncModel.init(title: "", subTitle: TextConstants.autoSyncCellMobileDataSubTitle, type: .typeSwitherActivator, selected: true))
        array.append(AutoSyncModel.init(title: TextConstants.autoSyncCellPhotos, subTitle: "", type: .typeSwitcher, selected: mobileDataPhotos))
        array.append(AutoSyncModel.init(title: TextConstants.autoSyncCellVideos, subTitle: "", type: .typeSwitcher, selected: mobileDataVideo))
        return array
    }
    
}
