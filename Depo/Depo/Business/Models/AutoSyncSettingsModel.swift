//
//  AutoSyncSettingsModel.swift
//  Depo
//
//  Created by Konstantin on 3/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


struct AutoSyncSetting {
    var syncItemType: AutoSyncItemType
    var option: AutoSyncOption
}

extension AutoSyncSetting: Equatable {
    static func ==(lhs: AutoSyncSetting, rhs: AutoSyncSetting) -> Bool {
        return lhs.option == rhs.option && lhs.syncItemType == rhs.syncItemType
    }
}


enum AutoSyncItemType {
    case photo
    case video
    
    var localizedText: String {
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
    
    var localizedText: String {
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


final class AutoSyncSettings {

    private struct SettingsKeys {
        private init() {}
        
        static let isAutoSyncEnabledKey = "isAutoSyncEnabled"
        static let isAutoSyncTimingEnabledKey = "isAutoSyncTimingEnabledKey"
        static let mobileDataPhotosKey = "mobileDataPhotos"
        static let mobileDataVideoKey = "mobileDataVideo"
        static let wifiPhotosKey = "wifiPhotos"
        static let wifiVideoKey = "wifiVideo"
    }
    
    
    private var storageVars: StorageVars = factory.resolve()
    
    var isAutoSyncEnabled: Bool {
        return isAutoSyncOptionEnabled && (photoSetting.option != .never || videoSetting.option != .never)
    }

    var photoSetting = AutoSyncSetting(syncItemType: .photo, option: .wifiAndCellular)
    var videoSetting = AutoSyncSetting(syncItemType: .video, option: .wifiOnly)
    
    var isAutoSyncOptionEnabled: Bool = true //auto sync switcher in settings is on/off
    
    var isAutosyncSettingsApplied: Bool {
        return storageVars.autoSyncSet
    }
    
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
            ///Because of interrupted sync via mobile network in the background
            videoSetting.option = .wifiOnly
        } else if wifiVideo {
            videoSetting.option = .wifiOnly
        } else {
            videoSetting.option = .never
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
                ///Because of interrupted sync via mobile network in the background
//                SettingsKeys.mobileDataVideoKey: (videoSetting.option == .wifiAndCellular),
                SettingsKeys.mobileDataVideoKey: false,
                SettingsKeys.wifiPhotosKey: (photoSetting.option == .wifiOnly),
                SettingsKeys.wifiVideoKey: (videoSetting.option == .wifiOnly)]
    }
}


//    MARK: - Migration from the old app
extension AutoSyncSettings {
    private struct MigrationKeys {
        private init() {}
        
        static let settingsUploadPhotosVideos = "SETTINGS_UPLOAD_PHOTOSVIDEOS"
        static let settingsUploadMediaType = "SETTINGS_UPLOAD_SYNC_MEDIA_TYPE"
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
    
    static var hasSettingsToMigrate: Bool {
        let oldValueAutoSyncState = UserDefaults.standard.integer(forKey: MigrationKeys.settingsUploadPhotosVideos)
        let oldValueMediaType = UserDefaults.standard.integer(forKey: MigrationKeys.settingsUploadMediaType)
        
        return MigrationEnableOption(rawValue: oldValueAutoSyncState) != nil &&
            MigrationSyncMediaType(rawValue: oldValueMediaType) != nil
    }
    
    static func createMigrated() -> AutoSyncSettings {
        let settings = AutoSyncSettings()
        settings.migrate()
        
        return settings
    }
    
    private func migrate() {
        defer {
            UserDefaults.standard.removeObject(forKey: MigrationKeys.settingsUploadPhotosVideos)
            UserDefaults.standard.removeObject(forKey: MigrationKeys.settingsUploadMediaType)
            
            storageVars.autoSyncSettings = self.asDictionary()
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
                videoSetting.option = .wifiOnly
            case .videos:
                photoSetting.option = .wifiOnly
                videoSetting.option = .wifiOnly
                ///Because of interrupted sync via mobile network in the background
//                videoSetting.option = .wifiAndCellular
            case .all:
                photoSetting.option = .wifiAndCellular
                videoSetting.option = .wifiOnly
                ///Because of interrupted sync via mobile network in the background
//                videoSetting.option = .wifiAndCellular
            case .none:
                photoSetting.option = .wifiOnly
                videoSetting.option = .wifiOnly
            }
        }
        
        storageVars.autoSyncSet = true
    }
}
