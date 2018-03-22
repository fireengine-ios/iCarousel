//
//  AutoSyncSettingsModel.swift
//  Depo
//
//  Created by Konstantin on 3/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class AutoSyncSettings {
    
    private struct SettingsKeys {
        private init() {}
        
        static let isAutoSyncEnabledKey = "isAutoSyncEnabled"
        static let mobileDataPhotosKey = "mobileDataPhotos"
        static let mobileDataVideoKey = "mobileDataVideo"
        static let wifiPhotosKey = "wifiPhotos"
        static let wifiVideoKey = "wifiVideo"
    }
    
    
    private struct MigrationKeys {
        private init() {}
        
        static let settingsUploadPhotosVideos = "SETTINGS_UPLOAD_PHOTOSVIDEOS"
        static let settingsUploadMediaType = "SETTINGS_UPLOAD_SYNC_MEDIA_TYPE"
        static let migrationCompletedKey = "SETTINGS_UPLOAD_MIGRATION_COMPLETED"
    }
    
    private enum MigrationEnableOption: Int {
        case off = 1
        case on
        case auto
    }
    
    private enum MigrationSyncMediaType: Int {
        case all = 1
        case photos
        case videos
        case none
    }
    
    var isMigrationCompleted: Bool {
        return UserDefaults.standard.bool(forKey: MigrationKeys.migrationCompletedKey)
    }
    
    var isAutoSyncEnabled: Bool {
        return isAutoSyncOptionEnabled && (photoSetting.option != .never || videoSetting.option != .never)
    }
    var photoSetting = AutoSyncSetting(syncItemType: .photo, option: .wifiAndCellular)
    var videoSetting = AutoSyncSetting(syncItemType: .video, option: .wifiOnly)
    
    var isAutoSyncOptionEnabled: Bool = true //auto sync switcher in settings is on/off
    
    
    init() { }
    
    init(with dictionary: [String: Bool]) {
        isAutoSyncOptionEnabled = dictionary[SettingsKeys.isAutoSyncEnabledKey] ?? true
        
        let mobileDataPhotos = dictionary[SettingsKeys.mobileDataPhotosKey] ?? true
        let mobileDataVideo = dictionary[SettingsKeys.mobileDataVideoKey] ?? false
        
        let wifiPhotos = dictionary[SettingsKeys.wifiPhotosKey] ?? false
        let wifiVideo = dictionary[SettingsKeys.wifiVideoKey] ?? true
        
        
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
    
    func migrate() {
        defer {
            UserDefaults.standard.removeObject(forKey: MigrationKeys.settingsUploadPhotosVideos)
            UserDefaults.standard.removeObject(forKey: MigrationKeys.settingsUploadMediaType)
            UserDefaults.standard.set(true, forKey: MigrationKeys.migrationCompletedKey)
        }
        
        let oldValueAutoSyncState = UserDefaults.standard.integer(forKey: MigrationKeys.settingsUploadPhotosVideos)
        let oldValueMediaType = UserDefaults.standard.integer(forKey: MigrationKeys.settingsUploadMediaType)
        
        guard let oldAutoSyncState = MigrationEnableOption(rawValue: oldValueAutoSyncState),
            let oldMediaType = MigrationSyncMediaType(rawValue: oldValueMediaType) else {
                return
        }
        
        isAutoSyncOptionEnabled = (oldAutoSyncState != .off)
        
        if isAutoSyncOptionEnabled {
            switch oldMediaType {
            case .photos:
                photoSetting.option = .wifiAndCellular
            case .videos:
                videoSetting.option = .wifiAndCellular
            case .all:
                photoSetting.option = .wifiAndCellular
                videoSetting.option = .wifiAndCellular
            case .none:
                photoSetting.option = .wifiOnly
                videoSetting.option = .wifiOnly
            }
        }
    }
    
    func disableAutoSync() {
        isAutoSyncOptionEnabled = false
        photoSetting.option = .wifiAndCellular
        videoSetting.option = .wifiOnly
    }
    
    func set(setting: AutoSyncSetting) {
        switch setting.syncItemType {
        case .photo:
            set(photoSyncSetting: setting)
        case .video:
            set(videoSyncSetting: setting)
        }
    }
    
    private func set(photoSyncSetting: AutoSyncSetting) {
        photoSetting = photoSyncSetting
    }
    
    private func set(videoSyncSetting: AutoSyncSetting) {
        videoSetting = videoSyncSetting
    }
    
    
    func asDictionary() -> [String: Bool] {
        return [SettingsKeys.isAutoSyncEnabledKey: isAutoSyncOptionEnabled,
                SettingsKeys.mobileDataPhotosKey: (photoSetting.option == .wifiAndCellular),
                SettingsKeys.mobileDataVideoKey: (videoSetting.option == .wifiAndCellular),
                SettingsKeys.wifiPhotosKey: (photoSetting.option == .wifiOnly),
                SettingsKeys.wifiVideoKey: (videoSetting.option == .wifiOnly)]
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
            return TextConstants.autoSyncSettingsOptionNever
        case .wifiOnly:
            return TextConstants.autoSyncSettingsOptionWiFi
        case .wifiAndCellular:
            return TextConstants.autoSyncSettingsOptionWiFiAndCellular
        }
    }
}
