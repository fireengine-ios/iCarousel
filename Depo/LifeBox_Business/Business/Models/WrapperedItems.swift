//
//  WrapperedItems.swift
//  Depo
//
//  Created by Alexander Gurin on 7/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Photos
import SDWebImage
import SwiftyJSON
import MobileCoreServices

typealias Item = WrapData
typealias UploadServiceBaseUrlResponse = (_ resonse: UploadBaseURLResponse?) -> Void
typealias FileUploadOperationSucces = (_ item: WrapData) -> Void
typealias RemoteImage = (_ image: UIImage?) -> Void
typealias RemoteData = (_ image: Data?) -> Void
typealias RemoteImageError = (_ error: Error?) -> Void

class LocalMediaContent {
    
    let asset: PHAsset
    let urlToFile: URL
    
    init(asset: PHAsset, urlToFile: URL) {
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


enum PreviewSize {
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
    case pptx = "pptx"
    case usdz = "usdz"
    case csv = "csv"
    
//    func bigIconImage() -> UIImage? {
//        switch self {
//        case .rar, .zip:
//            return #imageLiteral(resourceName: "fileBigIconAchive")
//        case .doc:
//            return #imageLiteral(resourceName: "fileBigIconDoc")
//        case .txt:
//            return #imageLiteral(resourceName: "fileBigIconTxt")
//        case .xls:
//            return #imageLiteral(resourceName: "fileBigIconXls")
//        case .pdf:
//            return #imageLiteral(resourceName: "fileBigIconPdf")
//        case .ppt:
//            return #imageLiteral(resourceName: "fileBigIconPpt")
//        default:
//            return nil
//        }
//    }
//    
//    func smallIconImage() -> UIImage? {
//        switch self {
//        case .rar:
//            return #imageLiteral(resourceName: "fileIconRar")
//        case .zip:
//            return #imageLiteral(resourceName: "fileIconZip")
//        case .doc:
//            return #imageLiteral(resourceName: "fileIconDoc")
//        case .txt:
//            return #imageLiteral(resourceName: "fileIconTxt")
//        case .xls:
//            return #imageLiteral(resourceName: "fileIconXls")
//        case .pdf:
//            return #imageLiteral(resourceName: "fileIconPdf")
//        case .ppt:
//            return #imageLiteral(resourceName: "fileIconPpt")
//        default:
//            return #imageLiteral(resourceName: "fileIconUnknown")
//        }
//    }
}

enum FileType: Hashable, Equatable {
    case unknown
    case image
    case video
    case audio
    case folder
    case musicPlayList
    case allDocs
    case application(ApplicationType)
    case imageAndVideo

    
    var convertedToSearchFieldValue: FieldValue {
        
        switch self {
//        case unknown:
//        case folder:
        case .image:
            return .image
        case .video:
            return .video
        case .audio:
            return .audio
        case .musicPlayList:
            return .playLists
        case .allDocs:
            return .document
        case .application(_):
            return .document //FIXME: temporary documents
        case .imageAndVideo:
            return .imageAndVideo
        default:
            return .all
        }
        
    }
    
    var convertedToPHMediaType: PHAssetMediaType {
        switch self {
        case .image:
            return .image
        case .video:
            return .video
        case .audio:
            return .audio
        default:
            return .unknown
        }
    }
    
    var isDocument: Bool {
        guard case let FileType.application(applicationType) = self else {
            return false
        }
        return applicationType.isContained(in: [.doc, .txt, .html, .xls, .pdf, .ppt, .pptx, .usdz, .csv])
    }
    
    var isDocumentPageItem: Bool {
        switch self {
        case .application(_):
            return true
        default:
            return false
        }
    }
    
    var  isSupportedOpenType: Bool {
        
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
            }
            
            if (wrapType.hasPrefix("text")) {
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
            
            if wrapType.hasPrefix("model") {
                guard let prefix = wrapType.components(separatedBy: "/").last else {
                    self = .application(.unknown)
                    return
                }
                
                switch prefix {
                case "vnd.pixar.usd", "usd":
                    self = .application(.usdz)
                default:
                    self = .application(.unknown)
                }
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
                case "csv":
                    self = .application(.csv)
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
                    guard let name_ = fileName else {
                        self = .application(.unknown)
                        return
                    }
                    guard let ext = name_.components(separatedBy: ".").last else {
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
                    case "usdz":
                        self = .application(.usdz)
                        return
                    default:
                        self = .application(.unknown)
                    }
                    return
                case "zip", "x-zip-compressed", "tar", ".7z":
                    self = .application(.zip)
                    return
                case "vnd.ms-powerpoint":
                    self = .application(.ppt)
                    return
                case "vnd.openxmlformats-officedocument.presentationml.presentation":
                    self = .application(.pptx)
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
        case 19:
            self = .application(.pptx)
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
        case .application(.pptx):
            return 19
        case .allDocs:
            return 20
        default:
            return 0
        }
    }
    
    
    static func ==(lhs: FileType, rhs: FileType) -> Bool {
        switch (lhs, rhs) {
        case (.image, .image): return true
        case (.video, .video): return true
        case (.audio, .audio): return true
        case (.folder, .folder): return true
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
        case (.musicPlayList, .musicPlayList): return true
            
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


enum ItemStatus: String, Codable {
    case active = "ACTIVE"
    case uploaded = "UPLOADED"
    case transcoding = "TRANSCODING"
    case transcodingFailed = "TRANSCODING_FAILED"
    case trashed = "TRASHED"
    case deleted = "DELETED"
    case unknown = "UNKNOWN"
    
    init(string: String?) {
        if let statusString = string, let status = ItemStatus(rawValue: statusString) {
            self = status
        } else {
            self = .unknown
        }
    }
    
    init(value: Int16) {
        switch value {
        case 0: self = .active
        case 1: self = .uploaded
        case 2: self = .transcoding
        case 3: self = .transcodingFailed
        case 4: self = .trashed
        case 5: self = .deleted
        default: self = .unknown
        }
    }
    
    func valueForCoreDataMapping() -> Int16 {
        switch self {
        case .active: return 0
        case .uploaded: return 1
        case .transcoding: return 2
        case .transcodingFailed: return 3
        case .trashed: return 4
        case .deleted: return 5
        case .unknown: return 7
        }
    }
    
    var isTranscoded: Bool {
        return isContained(in: [.active, .trashed])
    }
}


protocol  Wrappered {
    
    var id: Int64? { get }
    
    var name: String? { get }
    
    var fileType: FileType { get }
    
    var fileSize: Int64 { get }
    
    var syncStatus: SyncWrapperedStatus { get set }
    
    var metaData: BaseMetaData? { get }
    
    var favorites: Bool { get }
    
    var isLocalItem: Bool { get }
    
    var creationDate: Date? { get }
    
    var lastModifiDate: Date? { get }
    
    var patchToPreview: PathForItem { get }
    
    var urlToFile: URL? { get }
    
    var fileData: Data? { get }
    
    var duration: String? { get }
    
    var uuid: String { get }
    
    var md5: String { get set }
    
    var albums: [String]? { get set }
}

class WrapData: BaseDataSourceItem, Wrappered {
    
    var coreDataObjectId: NSManagedObjectID?
    
    var id: Int64?

    var fileSize: Int64
    
    var favorites: Bool
    
    var patchToPreview: PathForItem
    
    var duration: String?
    
    var durationValue: TimeInterval?
    
    var albums: [String]?

    var metaData: BaseMetaData?
    
    var status: ItemStatus
    
    var localFileUrl: URL?
    
    var urlToFile: URL?
    
    var mimeType: String?
    
    var fileData: Data?
    
    var privateSharePermission: SharedItemPermission?
    
    var asset: PHAsset? {
        switch patchToPreview {
        case let .localMediaContent(local):
            return local.asset
        case .remoteUrl(_):
            return nil
        }
    }
    
    var uploadContentType: String {
        if let contentType = mimeType {
            return contentType
        }
        
        switch fileType {
        case .image:
            if let type = urlToFile?.pathExtension.lowercased(), !type.isEmpty {
                return mimeType(from: type) ?? "image/\(type)"
            } else if let data = fileData {
                return ImageFormat.get(from: data).contentType
            }
            return "image/jpg"
        case .video:
            if let type = urlToFile?.pathExtension.lowercased(), !type.isEmpty {
                return mimeType(from: type) ?? "video/\(type)"
            }
            return "video/mp4"
            
        case .audio:
            if let type = urlToFile?.mimeType {
                return "audio/\(type)"
            }
            return "audio/mp3"
            
        case .application(_), .allDocs:
            if let type = urlToFile?.mimeType {
                return type
            }
            return "application/octet-stream"
            
        default:
            return "unknown"
        }
    }
    
    var isFolder: Bool?
    var isReadOnlyFolder: Bool {
        return isFolder == true && metaData?.specialFolderMeta != nil
    }
    
    var childCount: Int64?
    
    var metaDate: Date {
        if let unwrapedMetaDate = metaData?.takenDate {
            return unwrapedMetaDate
        } else if let unwrapedCreatedDate = creationDate {
            return unwrapedCreatedDate
        }
        return Date()
    }
    
    @available(*, deprecated: 1.0, message: "Use convenience init(info: AssetInfo) instead")
    convenience init(asset: PHAsset) {
        let info = LocalMediaStorage.default.fullInfoAboutAsset(asset: asset)
        self.init(baseModel: BaseMediaContent(curentAsset: asset, generalInfo: info))
    }

    convenience init(info: AssetInfo) {
        let baseModel = BaseMediaContent(curentAsset: info.asset, generalInfo: info)
        self.init(baseModel: baseModel)
    }
    
    //MARK:-
    
    init(baseModel: BaseMediaContent) {

        fileSize = baseModel.size
        let tmp = LocalMediaContent(asset: baseModel.asset,
                                     urlToFile: baseModel.urlToFile)
        patchToPreview = .localMediaContent(tmp)
        urlToFile = baseModel.urlToFile
        duration = WrapData.getDuration(duration: baseModel.asset.duration)
        durationValue = baseModel.asset.duration
            
        favorites = false
        status = .unknown
        super.init()
        md5 = baseModel.md5
        
        name = baseModel.originalName
        
//        if let fileName = name {
//            md5 = "\(WrapData.removeFirstSlash(text: fileName))\(fileSize)"
//        }
        
        fileType = baseModel.fileType
        isLocalItem = true
        creationDate = baseModel.dateOfCreation
        lastModifiDate = baseModel.lastModifiedDate
        syncStatus = .notSynced
        
        isFolder = false
        
        metaData = BaseMetaData()
        /// metaData filling
        metaData?.takenDate = baseModel.dateOfCreation
        metaData?.favourite = false
//        metaData?.album = mediaItem.metadata?.album
//        metaData?.artist = mediaItem.metadata?.artist
    
        metaData?.duration = baseModel.asset.duration
        
//        metaData?.genre = mediaItem.metadata?.genre ?? []
//        metaData?.height = Int(mediaItem.metadata?.height ?? 0)
        metaData?.title = baseModel.originalName
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
    
    init (remote: SearchItemResponse, previewSize: PreviewSize = .large) {
        metaData = remote.metadata
        favorites = remote.metadata?.favourite ?? false
        urlToFile = remote.tempDownloadURL
        patchToPreview = .remoteUrl(URL(string: ""))
        fileSize = remote.bytes ?? 0
        status = ItemStatus(string: remote.status)
        
        super.init(uuid: remote.uuid)
        md5 = remote.itemHash ?? "not hash "
        
        accountUuid = SingletonStorage.shared.accountInfo?.uuid ?? ""
        
        albums = remote.albums
        
        name = remote.name
        isLocalItem = false
        creationDate = remote.createdDate
        lastModifiDate = remote.lastModifiedDate
        fileType = FileType(type: remote.contentType, fileName: name)
        mimeType = remote.contentType
        isFolder = remote.folder
        syncStatus = .synced
        setSyncStatusesAsSyncedForCurrentUser()
        
        parent = remote.parent
        
        var url: URL?
        
        childCount = remote.childCount
        
        metaData = remote.metadata
        
        switch fileType { //Do we even need this????
        case .image, .audio, .video:
            duration = WrapData.getDuration(duration: remote.metadata?.duration)
            durationValue = remote.metadata?.duration
            switch previewSize {
            case .little : url = remote.metadata?.smalURl
            case .medium : url = remote.metadata?.mediumUrl
            case .large  : url = remote.metadata?.largeUrl
            }
//            if url == nil, fileType == .image {
//                url = remote.tempDownloadURL
//            }
        default:
            break
        }
        
        uuid = remote.uuid ?? ""//UUID().description
        
        
        favorites = remote.metadata?.favourite ?? false
        if let fileName = name {
            md5 = "\(fileName.removeAllPreFileExtentionBracketValues())\(fileSize)"
//            debugPrint(md5)
        }
        
        patchToPreview = .remoteUrl(url)
        id = remote.id
        isShared = remote.isShared
    }
    
    init(searchResponse: JSON) {
        let fileUUID = searchResponse[SearchJsonKey.uuid].string ?? ""
        fileSize = searchResponse[SearchJsonKey.bytes].int64 ?? 0
        patchToPreview = .remoteUrl(URL(string: ""))///????
        status = ItemStatus(string:searchResponse[SearchJsonKey.status].string)
        metaData = BaseMetaData(withJSON: searchResponse[SearchJsonKey.metadata])
        favorites = metaData?.favourite ?? false
        super.init(uuid: fileUUID)
        
        creationDate = searchResponse[SearchJsonKey.createdDate].date
        lastModifiDate = searchResponse[SearchJsonKey.lastModifiedDate].date
        id = searchResponse[SearchJsonKey.id].int64
        md5 = searchResponse[SearchJsonKey.hash].string ?? "not hash"
        name = searchResponse[SearchJsonKey.name].string
        uuid = fileUUID
        accountUuid = SingletonStorage.shared.accountInfo?.uuid ?? ""
        
        mimeType = searchResponse[SearchJsonKey.content_type].string
        fileType = FileType(type: mimeType, fileName: name)
        isFolder = searchResponse[SearchJsonKey.folder].bool
//        uploaderDeviceType = searchResponse[SearchJsonKey.uploaderDeviceType].string
        parent = searchResponse[SearchJsonKey.parent].string
        urlToFile = searchResponse[SearchJsonKey.tempDownloadURL].url
        
//        subordinates = searchResponse[SearchJsonKey.subordinates].array
        albums = searchResponse[SearchJsonKey.album].array?.flatMap { $0.string }
        childCount = searchResponse[SearchJsonKey.ChildCount].int64
        
        
        
        isLocalItem = false
        syncStatus = .synced
        setSyncStatusesAsSyncedForCurrentUser()
        
        var url: URL?
        let previewSize: PreviewSize = .medium///
        
        switch fileType {
        case .image, .audio, .video:
            duration = WrapData.getDuration(duration: metaData?.duration)
            durationValue = metaData?.duration
            switch previewSize {
            case .little : url = metaData?.smalURl
            case .medium : url = metaData?.mediumUrl
            case .large  : url = metaData?.largeUrl
            }
        default:
            break
        }
        
        if let fileName = name {
            md5 = "\(fileName.removeAllPreFileExtentionBracketValues())\(fileSize)"
//            debugPrint(md5)
        }
        
        patchToPreview = .remoteUrl(url)
    }
    
    convenience init (remote: SearchItemResponse, parendfolderUUID: String?) {
        self.init(remote: remote)
        if let unwrapedFolderUUID = parendfolderUUID {
            parent = unwrapedFolderUUID
        }
    }
    
    init(imageData: Data, isLocal: Bool) {
        fileData = imageData
        fileSize = Int64(imageData.count)
        favorites = false
        patchToPreview = .remoteUrl(nil)
        status = .unknown
        urlToFile = nil

        let creationDate = Date()
        super.init(uuid: nil, name: UUID().uuidString, creationDate: creationDate, lastModifiDate: creationDate, fileType: .image, syncStatus: .notSynced, isLocalItem: isLocal)
        
        if let fileName = name {
            md5 = "\(fileName)\(fileSize)"
        }
    }
   //TODO: Temporary logic
    init(videoData: Data, isLocal: Bool) {
        fileData = videoData
        fileSize = Int64(videoData.count)
        favorites = false
        patchToPreview = .remoteUrl(nil)
        status = .unknown
        urlToFile = nil

        let creationDate = Date()
        super.init(uuid: nil, name: UUID().uuidString, creationDate: creationDate, lastModifiDate: creationDate, fileType: .video, syncStatus: .notSynced, isLocalItem: isLocal)
        
        if let fileName = name {
            md5 = "\(fileName)\(fileSize)"
        }
    }

    init(importedDocumentURL: URL) {
        
        let fileManager = FileManager.default

        fileSize = fileManager.fileSize(at: importedDocumentURL) ?? 0
        let creationDate = fileManager.creationDate(at: importedDocumentURL) ?? Date()
        
        favorites = false
        patchToPreview = .remoteUrl(nil)
        status = .unknown
        urlToFile = importedDocumentURL
        localFileUrl = importedDocumentURL
        
        let fileName = importedDocumentURL.lastPathComponent
        let type = importedDocumentURL.mimeType
        let fileType = FileType(type: type, fileName: fileName)
        
        super.init(uuid: nil, name: fileName, creationDate: creationDate, lastModifiDate: creationDate, fileType: fileType, syncStatus: .notSynced, isLocalItem: true)
        
        mimeType = type
        md5 = "\(fileName)\(fileSize)"
    }
    
    init(privateShareFileInfo: SharedFileInfo, shareType: PrivateShareType = .sharedArea) {
        //TODO: status to enum in SharedFileInfo
        
        if let metadata = privateShareFileInfo.metadata {
            metaData = BaseMetaData(with: metadata)
        }
        
        fileSize = privateShareFileInfo.bytes ?? 0
        favorites = privateShareFileInfo.metadata?.isFavourite ?? false
//        let localStorage = LocalMediaStorage.default
//        if let assetId = privateShareFileInfo.metadata.originalHash,
//           localStorage.photoLibraryIsAvailible(),
//           let asset = localStorage.assetsCache.assetBy(identifier: assetId) ?? PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject {
//
//        } else {
            patchToPreview = .remoteUrl(metaData?.mediumUrl)
//        }
        status = privateShareFileInfo.fileInfoStatus ?? .active
        
        super.init(uuid: privateShareFileInfo.uuid,
                   name: privateShareFileInfo.name,
                   creationDate: privateShareFileInfo.createdDate,
                   lastModifiDate: privateShareFileInfo.lastModifiedDate,
                   fileType: privateShareFileInfo.fileType,
                   syncStatus: .synced,
                   isLocalItem: false)
        
        id = privateShareFileInfo.id
        accountUuid = privateShareFileInfo.accountUuid
        isFolder = privateShareFileInfo.folder
        if isFolder == true {
            fileType = .folder
        }
        childCount = privateShareFileInfo.childCount
        privateSharePermission = privateShareFileInfo.permissions
        privateShareType = shareType
        isShared = privateShareFileInfo.isFileSharedWithUser
    }
    
    func copyFileData(from item: WrapData) {
        uuid = item.uuid
        id = item.id
        name = item.name
        creationDate = item.creationDate
        lastModifiDate = item.lastModifiDate
        md5 = item.md5
        urlToFile = item.urlToFile
        status = item.status
        metaData?.copy(metaData: item.metaData)
    }
    
    class func getDuration(duration: Double?) -> String {
        guard let duration = duration else {
            return ""
        }
        
        let rounded = round(duration)
        
        let seconds = Int(rounded) % 60
        let minutes = Int(rounded) / 60
        
        if minutes < 100 {
            return String(format: "%02i:%02i", minutes, seconds)
        } else {
            return String(format: "%i:%02i", minutes, seconds)
        }
    }
    
    func getTrimmedLocalID() -> String {
        if isLocalItem, let localID = asset?.localIdentifier {
            return  localID.components(separatedBy: "/").first ?? localID
        } else if uuid.contains("~"){
            return uuid.components(separatedBy: "~").first ?? uuid
        }
        return uuid
    }
    
    func getFisrtUUIDPart() -> String {
        if uuid.contains("~") {
            return uuid.components(separatedBy: "~").first ?? uuid
        }
        return uuid
    }
    
    func getLocalID() -> String {
        if isLocalItem, let localID = asset?.localIdentifier {
            return localID
        }
        return uuid
    }
    
    /**
     Need this beacase old app shares name with slash
    */
    private class func removeFirstSlash(text: String) -> String {
        var tempoString = text
        if tempoString.hasPrefix("/") {
            tempoString.remove(at: tempoString.startIndex)
        }
        return tempoString
    }
    
    func hasExpiredUrl() -> Bool {
        let urlsToCheck = [urlToFile, metaData?.videoPreviewURL]
        for url in urlsToCheck {
            if let url = url, url.isExpired {
                return true
            }
        }
        
        return false
    }
    
    func hasExpiredPreviewUrl() -> Bool {
        let urlsToCheck = [urlToFile, metaData?.largeUrl, metaData?.mediumUrl, metaData?.smalURl]
        for url in urlsToCheck {
            if let url = url, url.isExpired {
                return true
            }
        }
        return false
    }
    
    func imageUrl(size: ImageSize) -> URL? {
        switch size {
        case .small:
            return metaData?.smalURl
        case .medium:
            return metaData?.mediumUrl
        case .large:
            return metaData?.largeUrl
        case .original:
            return urlToFile
        case .preview:
            if case PathForItem.remoteUrl(let url) = patchToPreview {
                return url
            } else {
                return nil
            }
        }
    }
}

extension WrapData {
    override func isEqual(_ object: Any?) -> Bool {
        guard let wrapData = object as? WrapData else {
            return false
        }
        
        return uuid == wrapData.uuid &&
            id == wrapData.id &&
            name == wrapData.name &&
            md5 == wrapData.md5 &&
            metaDate == wrapData.metaDate &&
            lastModifiDate == wrapData.lastModifiDate &&
            urlToFile?.byTrimmingQuery == wrapData.urlToFile?.byTrimmingQuery &&
            status == wrapData.status &&
            metaData == wrapData.metaData &&
            isShared == wrapData.isShared &&
            privateSharePermission == wrapData.privateSharePermission
    }

}


extension WrapData {
    func hasSupportedExtension() -> Bool {
        let type = (mimeType ?? uploadContentType) as CFString
        if let preferredIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, type, nil)?.takeUnretainedValue() {
            return UTTypeIsDeclared(preferredIdentifier)
        }
        
        return false
    }
    
    func mimeType(from fileExtension: String) -> String? {
        if let preferredIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeUnretainedValue() {
            let mime = UTTypeCopyPreferredTagWithClass(preferredIdentifier, kUTTagClassMIMEType)?.takeUnretainedValue() as String?
            debugPrint("MIME: \(mime ?? "UNKNOWN")")
            return mime
        }
        return nil
    }
}
