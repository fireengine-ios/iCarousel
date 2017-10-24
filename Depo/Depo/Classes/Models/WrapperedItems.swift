//
//  WrapperedItems.swift
//  Depo
//
//  Created by Alexander Gurin on 7/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Photos

typealias RemoteImage = (_ image: UIImage?) -> Swift.Void

typealias RemoteImageError = (_ error: Error?) -> Swift.Void

class LocalMediaContent {
    
    let asset: PHAsset
    let urlToFile: URL
    
    init(asset: PHAsset, urlToFile:URL) {
        self.asset = asset
        self.urlToFile = urlToFile
    }
}


enum PathForItem: Equatable {
    
    case remoteUrl(URL?)
    
    case localMediaContent(LocalMediaContent)
    
    static func ==(lhs: PathForItem, rhs: PathForItem) -> Bool {
        switch (lhs, rhs) {
        case (let .remoteUrl(url1), let .remoteUrl(url2)): return url1 == url2
        case (let .localMediaContent(asset1), let .localMediaContent(asset2)): return asset1.urlToFile == asset2.urlToFile
        default:
            return false
        }
    }
}


enum PreviewIconSize {
    case little
    case medium
    case large
}

enum ApplicationType: String {
    case rar = "rar"
    case zip = "zip"
    case unknown = "unknown"
    case doc = "doc"
    case txt = "txt"
    case html = "html"
    case xls = "xls"
    case pdf = "pdf"
    case ppt = "ppt"
}

enum FileType: Equatable {
    case unknown
    case image
    case video
    case audio
    case folder
    case photoAlbum
    case musicPlayList
    case application(ApplicationType)
    
    var isApplication: Bool {
        return true
    }
    
    var  isUnSupportedOpenType: Bool {
        
        return  self != .application(.zip) &&
                self != .application(.rar) &&
                self != .application(.unknown)
    }
    
    var typeWithDuration: Bool {
        return (self == .audio) || self == (.video)
    }
    
    
    init(type: String?, fileName: String?) {
        if let wrapType = type {
            if (wrapType.hasPrefix("image")) {
                self = .image
                return
            }
            if (wrapType.hasPrefix("video")) {
                self = .video
                return
            }
            if (wrapType.hasPrefix("audio")) {
                self = .audio
                return
            }
            if (wrapType.hasPrefix("album")) {
                
                if (wrapType.hasSuffix("music")) {
                    self = .musicPlayList
                    return
                }
                
                if (wrapType.hasSuffix("photo")) {
                    self = .photoAlbum
                    return
                }
            }
            
            if (wrapType.hasPrefix("text")){
                guard let prefix = wrapType.components(separatedBy: "/").last else {
                    self = .application(.unknown)
                    return
                }
                switch prefix {
                case "html":
                    self = .application(.html)
                    return
                case "plain":
                    self = .application(.txt)
                    return
                default:
                    self = .application(.unknown)
                }
                return
            }
            
            if (wrapType.hasPrefix("application")) {
                
                guard let prefix = wrapType.components(separatedBy: "/").last else {
                    self = .application(.unknown)
                    return
                }
                switch prefix {
                case "directory":
                    self = .folder
                    return
                case "pdf":
                    self = .application(.pdf)
                    return
                case "vnd.openxmlformats-officedocument.wordprocessingml.document":
                    self = .application(.doc)
                    return
                case "msword":
                    self = .application(.doc)
                    return
                case "vnd.openxmlformats-officedocument":
                    self = .application(.txt)
                    return
                case "vnd.openxmlformats-officedocument.spreadsheetml.sheet":
                    self = .application(.xls)
                    return
                case "vnd.ms-excel":
                    self = .application(.xls)
                    return
                case "octet-stream":
                    guard let name_ = fileName else{
                        self = .application(.unknown)
                        return
                    }
                    guard let ext = name_.components(separatedBy: ".").last else{
                        self = .application(.unknown)
                        return
                    }
                    switch ext {
                    case "zip":
                        self = .application(.zip)
                        return
                    case "rar":
                        self = .application(.rar)
                        return
                    default:
                        self = .application(.unknown)
                    }
                    return
                case "vnd.ms-powerpoint":
                    self = .application(.ppt)
                    return
                default:
                    self = .application(.unknown)
                }
                return
            }
        }
        
        self = .application(.unknown)
    }
    
    // Coredata Convert
    // TODO refactoring later
    
    init(value: Int16) {
        
        switch value {
        case 0:
            self = .unknown
        case 1:
            self = .image
        case 2:
            self = .video
        case 3:
            self = .audio
        case 4:
            self = .folder
        case 5:
            self = .photoAlbum
        case 6:
            self = .musicPlayList
        case 10:
            self = .application(.unknown)
        case 11:
            self = .application(.rar)
        case 12:
            self = .application(.zip)
        case 13:
            self = .application(.doc)
        case 14:
            self = .application(.txt)
        case 15:
            self = .application(.html)
        case 16:
            self = .application(.xls)
        case 17:
            self = .application(.pdf)
        case 18:
            self = .application(.ppt)
        default:
            self = .unknown
        }
    }
    
    func valueForCoreDataMapping() -> Int16 {
        switch self {
        case .unknown:
            return 0
        case .image:
            return 1
        case .video:
            return 2
        case .audio:
            return 3
        case .folder:
            return 4
        case .photoAlbum:
            return 5
        case .musicPlayList:
            return 6
        
        case .application(.unknown):
            return 10
        case .application(.rar):
            return 11
        case .application(.zip):
            return 12
        case .application(.doc):
            return 13
        case .application(.txt):
            return 14
        case .application(.html):
            return 15
        case .application(.xls):
            return 16
        case .application(.pdf):
            return 17
        case .application(.ppt):
            return 18
        }
    }
    
    
    static func ==(lhs: FileType, rhs: FileType) -> Bool {
        switch (lhs,rhs) {
        case (.image,.image): return true
        case (.video,.video): return true
        case (.audio,.audio): return true
        case (.folder,.folder): return true
        case (.application, .application):
            switch (lhs) {
            case .application(let lhsType):
                switch (rhs) {
                case .application(let rhsType):
                    if lhsType == rhsType {
                        return true
                    }
                default:()
                }
            default:()
            }
            return false
        case (.photoAlbum,.photoAlbum): return true
        case (.musicPlayList,.musicPlayList): return true
        default:
            return false
        }
    }
}

enum SyncWrapperedStatus {
    case synced
    case notSynced
    case synchronizing
    case unknown
    
    init(value: Int16) {
        switch value {
        case 0:
            self = .notSynced
        case 1:
            self = .synchronizing
        case 2:
            self = .synced
        default:
            self = .unknown
        }
    }
    
    func valueForCoreDataMapping() -> Int16 {
        switch  self {
        case .notSynced:
            return 0
        case .synchronizing:
            return 1
        case .synced:
            return 2
        case .unknown:
            return 100
        }
    }
}

protocol  Wrappered  {
    
    var id: Int64? { get }
    
    var name: String? { get }
    
    var fileType: FileType { get }
    
    var fileSize: Int64 { get }
    
    var syncStatus: SyncWrapperedStatus { get set }
    
    var metaData: BaseMetaData? { get }
    
    var favorites: Bool { get }
    
    var isLocalItem: Bool { get }
    
    var creationDate: Date? { get }
    
    var lastModifiDate: Date? { get}
    
    var patchToPreview: PathForItem { get }
    
    var urlToFile: URL? { get }
    
    var duration: String? { get }
    
    var uuid: String { get }
    
    var md5: String { get set }
    
    var album: [String]? { get set}
}


class WrapData: BaseDataSourceItem, Wrappered {

    var coreDataObject: MediaItem?
    
    var id: Int64?

    let fileSize: Int64
    
    var favorites: Bool
    
    var patchToPreview: PathForItem
    
    var duration: String?
    
    var album: [String]?

    var metaData: BaseMetaData?
    
    /* for remote content*/
    private let tmpDownloadUrl: URL?
    
    var isUploading: Bool = false
    
    var urlToFile: URL? {
        return tmpDownloadUrl
    }
    
    var asset:PHAsset? {
        
        switch patchToPreview  {
            
        case let .localMediaContent(local):
            return local.asset
        case .remoteUrl(_):
            return nil
        }
    }
    
    init(musicForCreateStory: CreateStoryMusicItem) {
        id = musicForCreateStory.id
        tmpDownloadUrl = musicForCreateStory.path
        favorites = false
        patchToPreview = .remoteUrl(nil)
        // unuse parametrs
        fileSize =  Int64(0)
        super.init()
        md5 = "not use "
        
        fileType = .audio
        name = musicForCreateStory.fileName
        isLocalItem = false
        syncStatus = .notSynced
        creationDate = Date()
        lastModifiDate = Date()
    }
    
    init(baseModel: BaseMediaContent) {

        fileSize = baseModel.size
        let tmp  = LocalMediaContent(asset: baseModel.asset,
                                     urlToFile: baseModel.urlToFile)
        patchToPreview = .localMediaContent(tmp)
        tmpDownloadUrl = baseModel.urlToFile
        duration = WrapData.getDuration(duration: baseModel.asset.duration)
            
        favorites = false
        super.init()
        md5 = baseModel.md5

        name = baseModel.name
        fileType = baseModel.fileType
        isLocalItem = true
        creationDate = baseModel.dateOfCreation
        lastModifiDate = baseModel.lastModifiedDate
        syncStatus = .notSynced
    }
    
    override func getCellReUseID() -> String {
        
        switch fileType {
        case .video:
            return CollectionViewCellsIdsConstant.cellForVideo
        
        case .image:
            return CollectionViewCellsIdsConstant.cellForImage
            
        case .audio :
            return CollectionViewCellsIdsConstant.cellForAudio
            
        default:
            return CollectionViewCellsIdsConstant.cellForImage
        }
    }
    
    init (remote: SearchItemResponse, previewIconSize: PreviewIconSize = .medium) {
        metaData = remote.metadata
        favorites = remote.metadata?.favourite ?? false
        tmpDownloadUrl = remote.tempDownloadURL
        patchToPreview = .remoteUrl(URL(string: ""))
        fileSize = remote.bytes ?? Int64(0)
        super.init()
        md5 = remote.hash ?? "not hash "
        
        name = remote.name
        isLocalItem = false
        creationDate = remote.createdDate
        lastModifiDate = remote.lastModifiedDate
        fileType = FileType(type: remote.contentType, fileName: name)
        syncStatus = .synced
        
        var url:URL?
        
        if (fileType == .image) {
            switch previewIconSize {
            case .little : url = remote.metadata?.smalURl
            case .medium : url = remote.metadata?.mediumUrl
            case .large  : url = remote.metadata?.largeUrl
            }
            if (url == nil) {
                url = remote.tempDownloadURL
            }
        }
        
        if (fileType == .audio) {
            duration = WrapData.getDuration(duration: remote.metadata?.duration)
        }
        
        if (fileType == .video){
            
            duration = WrapData.getDuration(duration: remote.metadata?.duration)
            
            switch previewIconSize {
            case .little : url = remote.metadata?.smalURl
            case .medium : url = remote.metadata?.mediumUrl
            case .large  : url = remote.metadata?.largeUrl
            }
            if (url == nil) {
                url = remote.tempDownloadURL
            }
        }
        
        uuid = remote.uuid ?? ""//UUID().description
        
        metaData = remote.metadata
        favorites = remote.metadata?.favourite ?? false
        
        md5 = remote.hash ?? ""
        patchToPreview = .remoteUrl(url)
        id = remote.id
    }
    
    
    init(mediaItem: MediaItem) {
        coreDataObject = mediaItem
        fileSize = mediaItem.fileSizeValue
        favorites = mediaItem.favoritesValue
        
        var url: URL? = nil
        if let url_ = mediaItem.urlToFileValue {
            url = URL(string: url_)
        }
        tmpDownloadUrl =  url
        
        if let assetId = mediaItem.localFileID,
           let url = mediaItem.urlToFileValue {
            
            let avalibleAsset = LocalMediaStorage.default.assetsCache.assetBy(identifier: assetId)
    
            if let asset = avalibleAsset {
                
                let urlToFile = URL(fileURLWithPath:  url)
                let tmp  = LocalMediaContent(asset: asset,
                                             urlToFile: urlToFile)
                patchToPreview = .localMediaContent(tmp)
            } else {
                // WARNIG: THIS CASE INCOREECTif 
                // add only for debud and test !!
                patchToPreview = .remoteUrl(nil)
            }

        } else {
            var previewUrl: URL? = nil
            if let previewUrlStr = mediaItem.patchToPreviewValue {
                previewUrl = URL(string: previewUrlStr)
            }
            patchToPreview = .remoteUrl(previewUrl)
        }
        
        id = mediaItem.idValue
        super.init()
        md5 = mediaItem.md5Value ?? "not md5"
        uuid = mediaItem.uuidValue ?? ""//UUID().description
        isLocalItem = mediaItem.isLocalItemValue
        name = mediaItem.nameValue
        creationDate = mediaItem.creationDateValue as Date?
        lastModifiDate = mediaItem.lastModifiDateValue as Date?
        syncStatus =  SyncWrapperedStatus(value: mediaItem.syncStatusValue)
        fileType = FileType(value: mediaItem.fileTypeValue)
        
        metaData = BaseMetaData()
        
        /// metaData filling
        metaData?.favourite = mediaItem.favoritesValue
        metaData?.album = mediaItem.metadata?.album
        metaData?.artist = mediaItem.metadata?.artist
        metaData?.duration = mediaItem.metadata?.duration
        metaData?.genre = mediaItem.metadata?.genre ?? []
        metaData?.height = mediaItem.metadata?.height
        metaData?.title = mediaItem.metadata?.title
        
        if let largeUrl = mediaItem.metadata?.largeUrl {
            metaData?.largeUrl = URL(string: largeUrl)
        }
        if let mediumUrl = mediaItem.metadata?.mediumUrl {
            metaData?.mediumUrl = URL(string: mediumUrl)
        }
        if let smalURl = mediaItem.metadata?.smalURl {
            metaData?.smalURl = URL(string: smalURl)
        }
    }
    
    private class func getDuration(duration: Double?) -> String {
        if let d = duration{
            var s: CGFloat = CGFloat(d)
            s = s / 1000
            let seconds = Int(s) % 60
            let minutes = Int(s) / 60
            
            if (minutes < 100){
                return String(format:"%02i:%02i", minutes,seconds)
            }else{
                return String(format:"%i:%02i", minutes,seconds)
            }
        }
        return ""
    }
}
