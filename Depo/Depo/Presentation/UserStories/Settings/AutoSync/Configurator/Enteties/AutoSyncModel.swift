//
//  AutoSyncModel.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

typealias AutoSyncTableViewCell = UITableViewCell & AutoSyncSettingsCell

protocol AutoSyncCellDelegate: AnyObject {
    func didChange(model: AutoSyncModel)
}

protocol AutoSyncSettingsCell {
    func setup(with model: AutoSyncModel, delegate: AutoSyncCellDelegate?)
    func didSelect()
}

enum AutoSyncSettingsType {
    case autoSync
    case photo
    case video
    case albums
}

enum AutoSyncRowType {
    case switcher
    case header
    case settings
    case album
    
    func cellClass() -> AutoSyncTableViewCell.Type {
        switch self {
        case .switcher:
            return AutoSyncSwitcherTableViewCell.self
        case .settings:
            return AutoSyncSettingsTableViewCell.self
        case .header:
            return AutoSyncHeaderTableViewCell.self
        case .album:
            return AutoSyncAlbumTableViewCell.self
        }
    }
    
    static let cellTypes: [AutoSyncTableViewCell.Type] = [AutoSyncSwitcherTableViewCell.self,
                                                          AutoSyncSettingsTableViewCell.self,
                                                          AutoSyncHeaderTableViewCell.self,
                                                          AutoSyncAlbumTableViewCell.self]
}

final class AutoSyncAlbum {
    
    let uuid: String
    let name: String
    var isSelected: Bool
    let isMainAlbum: Bool
    
    init(asset: PHAssetCollection) {
        uuid = asset.localIdentifier
        name = asset.localizedTitle ?? ""
        isSelected = true
        isMainAlbum = asset.assetCollectionSubtype == .smartAlbumUserLibrary
    }
    
    init(mediaItemAlbum: MediaItemsAlbum) {
        uuid = mediaItemAlbum.localId ?? ""
        name = mediaItemAlbum.name ?? ""
        isSelected = mediaItemAlbum.isEnabled
        isMainAlbum = mediaItemAlbum.isMainLocalAlbum
    }
}

extension AutoSyncAlbum: Equatable {
    static func == (lhs: AutoSyncAlbum, rhs: AutoSyncAlbum) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

class AutoSyncModel: Equatable {
    let type: AutoSyncRowType
    
    init(type: AutoSyncRowType) {
        self.type = type
    }
    
    func equalTo(rhs: AutoSyncModel) -> Bool {
        return type == rhs.type
    }
    
    static func == (lhs: AutoSyncModel, rhs: AutoSyncModel) -> Bool {
        return lhs.equalTo(rhs: rhs)
    }
}

final class AutoSyncHeaderModel: AutoSyncModel {
    let headerType: AutoSyncHeaderType
    var setting: AutoSyncSetting?
    var isSelected: Bool
    
    init(type: AutoSyncHeaderType, setting: AutoSyncSetting?, isSelected: Bool) {
        self.headerType = type
        self.setting = setting
        self.isSelected = isSelected
        if type == .autosync {
            super.init(type: .switcher)
        } else {
            super.init(type: .header)
        }
    }
    
    override func equalTo(rhs: AutoSyncModel) -> Bool {
        if let rhs = rhs as? AutoSyncHeaderModel {
            return headerType == rhs.headerType
        }
        return super.equalTo(rhs: rhs)
    }
}

final class AutoSyncSettingModel: AutoSyncModel {
    var setting: AutoSyncSetting?
    
    init(type: AutoSyncRowType, setting: AutoSyncSetting?) {
        self.setting = setting
        super.init(type: type)
    }
}

final class AutoSyncAlbumModel: AutoSyncModel {
    var album: AutoSyncAlbum
    var isAllChecked = true //only for main album - if all sub-albums checked
    var isEnabled = true
    
    init(album: AutoSyncAlbum) {
        self.album = album
        super.init(type: .album)
    }
    
    override func equalTo(rhs: AutoSyncModel) -> Bool {
        if let rhs = rhs as? AutoSyncAlbumModel {
            return album.name == rhs.album.name
        }
        return super.equalTo(rhs: rhs)
    }
}


enum AutoSyncHeaderType: Int {
    case autosync
    case photo
    case video
    case albums
    
    var title: String {
        switch self {
        case .autosync:
            return TextConstants.autoSyncCellAutoSync
        case .photo:
            return TextConstants.autoSyncCellPhotos
        case .video:
            return TextConstants.autoSyncCellVideos
        case .albums:
            return TextConstants.autoSyncCellAlbums
        }
    }
    
    func subtitle(setting: AutoSyncSetting? = nil) -> String {
        guard let setting = setting else {
            return ""
        }
        return setting.option.localizedText
    }
    
}
