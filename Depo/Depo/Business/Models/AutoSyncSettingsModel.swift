//
//  AutoSyncSettingsModel.swift
//  Depo
//
//  Created by Konstantin on 3/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


struct AutoSyncSettings {
    
    static let isAutoSyncEnabledKey = "isAutoSyncEnabled"
    static let mobileDataPhotosKey = "mobileDataPhotos"
    static let mobileDataVideoKey = "mobileDataVideo"
    static let wifiPhotosKey = "wifiPhotos"
    static let wifiVideoKey = "wifiVideo"
    
    var isAutoSyncEnabled: Bool {
        return isAutoSyncOptionEnabled && (photoSetting.option != .never || videoSetting.option != .never)
    }
    var photoSetting = AutoSyncSetting(syncItemType: .photo, option: .wifiOnly)
    var videoSetting = AutoSyncSetting(syncItemType: .video, option: .wifiOnly)
    
    var isAutoSyncOptionEnabled: Bool = false //auto sync switcher in settings is on/off
    
    
    init() {
    }
    
    init(with dictionary: [String: Bool]) {
        isAutoSyncOptionEnabled = dictionary[AutoSyncSettings.isAutoSyncEnabledKey] ?? false
        
        let mobileDataPhotos = dictionary[AutoSyncSettings.mobileDataPhotosKey] ?? false
        let mobileDataVideo = dictionary[AutoSyncSettings.mobileDataVideoKey] ?? false
        
        let wifiPhotos = dictionary[AutoSyncSettings.wifiPhotosKey] ?? true
        let wifiVideo = dictionary[AutoSyncSettings.wifiVideoKey] ?? true
        
        
        //setup photo setting
        
        if mobileDataPhotos {
            photoSetting.option = .wifiAndCellular
        } else if wifiPhotos {
            photoSetting.option = .wifiOnly
        } else {
            photoSetting.option = .never
        }
        
        //setup video setting
        
        if mobileDataVideo {
            videoSetting.option = .wifiAndCellular
        } else if wifiVideo {
            videoSetting.option = .wifiOnly
        } else {
            videoSetting.option = .never
        }
    }
    
    mutating func disableAutoSync() {
        isAutoSyncOptionEnabled = false
        photoSetting = AutoSyncSetting(syncItemType: .photo, option: .wifiOnly)
        videoSetting = AutoSyncSetting(syncItemType: .video, option: .wifiOnly)
    }
    
    mutating func set(setting: AutoSyncSetting) {
        switch setting.syncItemType {
        case .photo:
            set(photoSyncSetting: setting)
        case .video:
            set(videoSyncSetting: setting)
        }
    }
    
    mutating private func set(photoSyncSetting: AutoSyncSetting) {
        photoSetting = photoSyncSetting
    }
    
    mutating private func set(videoSyncSetting: AutoSyncSetting) {
        videoSetting = videoSyncSetting
    }
    
    func asDictionary() -> [String: Bool] {
        var dict = [String: Bool]()
        dict[AutoSyncSettings.isAutoSyncEnabledKey] = isAutoSyncOptionEnabled
        dict[AutoSyncSettings.mobileDataPhotosKey] = (photoSetting.option == .wifiAndCellular)
        dict[AutoSyncSettings.mobileDataVideoKey] = (videoSetting.option == .wifiAndCellular)
        dict[AutoSyncSettings.wifiPhotosKey] = (photoSetting.option == .wifiOnly)
        dict[AutoSyncSettings.wifiVideoKey] = (videoSetting.option == .wifiOnly)
        return dict
    }
}


struct AutoSyncSetting: Equatable {

    var syncItemType: AutoSyncItemType
    var option: AutoSyncOption
    
    
    static func ==(lhs: AutoSyncSetting, rhs: AutoSyncSetting) -> Bool {
        return lhs.option == rhs.option && lhs.syncItemType == rhs.syncItemType
    }
}


enum AutoSyncItemType {
    case photo
    case video
    
    func text() -> String {
        switch self {
        case .photo:
            return TextConstants.autoSyncCellPhotos
        case .video:
            return TextConstants.autoSyncCellVideos
        }
    }
}


enum AutoSyncOption {
    case wifiOnly
    case wifiAndCellular
    case never
    
    func text() -> String {
        switch self {
        case .never:
            return "Never"
        case .wifiOnly:
            return "Wi-Fi"
        case .wifiAndCellular:
            return "Wi-Fi and Cellular"
        }
    }
}
