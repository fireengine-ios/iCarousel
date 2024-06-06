//
//  UploadParametrs.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class UploadBaseURL: BaseRequestParametrs {
    override var requestParametrs: Any {
        return Data()
    }
    
    override var patch: URL {
        return RouteRequests.uploadContainer
    }
}

class SimpleUpload: UploadRequestParametrs {
    
    private let item: WrapData
    private let uploadStrategy: MetaStrategy
    private let uploadTo: MetaSpesialFolder
    private let destitantionURL: URL
    private let isFavorite: Bool
    private let isCollage: Bool
    private let isPhotoPrint: Bool
    private let isFromAlbum: Bool
    
    let rootFolder: String
    let uploadType: UploadType?
    
    var fileName: String {
        return item.name ?? "unknown"
    }
    
    var md5: String {
        return item.md5
    }
    
    lazy var urlToLocalFile: URL? = {
        if let asset = self.item.asset {
            return LocalMediaStorage.default.copyAssetToDocument(asset: asset)
        } else if let localUrl = item.localFileUrl {
            return localUrl
        }
        
        return nil
    }()

    var fileData: Data? {
        return item.fileData
    }
    
    var fileSize: Int64 {
        if let url = urlToLocalFile,
           let resources = try? url.resourceValues(forKeys:[.fileSizeKey]),
            let fileSize = resources.fileSize {
            return Int64(fileSize)
        }
        
        return item.fileSize
    }
    
    let tmpUUID: String
    
    static func with(item: WrapData, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool, uploadType: UploadType?, isCollage: Bool, isPhotoPrint: Bool, isFromAlbum: Bool) -> SimpleUpload {
        return SimpleUpload(item: item, destitantion: destitantion, uploadStategy: uploadStategy, uploadTo: uploadTo, rootFolder: rootFolder, isFavorite: isFavorite, uploadType: uploadType, isCollage: isCollage, isPhotoPrint: isPhotoPrint, isFromAlbum: isFromAlbum)
    }
    
    private init(item: WrapData, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool, uploadType: UploadType?, isCollage: Bool, isPhotoPrint: Bool, isFromAlbum: Bool) {
        
        self.item = item
        self.uploadType = uploadType
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion
        self.isFavorite = isFavorite
        self.isCollage = isCollage
        self.isPhotoPrint = isPhotoPrint
        self.isFromAlbum = isFromAlbum
        
        switch uploadType {
            case .save:
                self.tmpUUID = item.uuid
            case .saveAs, .sharedWithMe:
                self.tmpUUID = "\(item.getTrimmedLocalID())~\(UUID().uuidString)"
            default:
                if item.isLocalItem {
                    self.tmpUUID = "\(item.getTrimmedLocalID())~\(UUID().uuidString)"
                } else {
                    self.tmpUUID = UUID().uuidString
            }
        }
    }
    
    
    var requestParametrs: Any {
        return Data()
    }
    
    var header: RequestHeaderParametrs {
        var header = RequestHeaders.authification()
        
        if item.fileSize == 0 {
            let attributes = item.toDebugAnalyticsAttributes()
            DebugAnalyticsService.log(event: .zeroContentLength, attributes: attributes)
            let errorMessage = "File size is 0. Check Answers event."
            debugLog(errorMessage)
            assertionFailure(errorMessage)
        }
        
        let appopriateUploadType = (uploadType == .autoSync) ? "AUTO_SYNC" : "MANUAL"
        let lifecycleState = ApplicationStateHelper.shared.isBackground ? "BG": "FG"
        let connectionStatus = ReachabilityService.shared.uploadConnectionTypeName
        
        let name = item.name ?? tmpUUID
        let fixed = name.precomposedStringWithCanonicalMapping
        let encodedName = fixed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name

        header = header + [
            HeaderConstant.connectionType        : connectionStatus,
            HeaderConstant.uploadType            : appopriateUploadType,
            HeaderConstant.applicationLifecycleState : lifecycleState,
            HeaderConstant.ContentType           : item.uploadContentType,
            HeaderConstant.XMetaStrategy         : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice       : Device.deviceId ?? "",
            HeaderConstant.XObjectMetaFileName   : encodedName,
            HeaderConstant.XObjectMetaFavorites  : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder,
            HeaderConstant.XObjectMetaSpecialFolder : uploadTo.rawValue,
            HeaderConstant.Expect                : "100-continue",
            HeaderConstant.XObjectMetaDeviceType : Device.deviceType,
            HeaderConstant.XObjectMetaIosMetadataHash : item.asset?.localIdentifier ?? "",
            HeaderConstant.ContentLength         : "\(fileSize)"
        ]
        
        if isCollage {
            header = header + [
                HeaderConstant.XObjectMetaFolderLabel: "COLLAGES"
            ]
        }
        
        if isPhotoPrint {
            header = header + [
                HeaderConstant.XObjectMetaFolderLabel: "PRINTED-PHOTOS"
            ]
        }
        
        if isFromAlbum {
            header = header + [
                HeaderConstant.XObjectMetaAlbumUuid: self.rootFolder
            ]
        }

        if let creationDate = item.asset?.creationDate {
            let milliseconds = Int64(creationDate.timeIntervalSince1970) * 1000
            header = header + [
                HeaderConstant.XObjectMetaTakenDate: String(milliseconds)
            ]
        }
      
        if item.asset?.mediaSubtypes == .photoScreenshot {
            header = header + [
                HeaderConstant.XObjectMetaFolderLabel: "SCREENSHOTS"
            ]
        }
        
        if item.asset?.playbackStyle == .imageAnimated {
            header = header + [
                HeaderConstant.XObjectMetaFolderLabel: "ANIMATIONS"
            ]
        }
        
        if item.asset?.mediaSubtypes == .photoPanorama {
            header = header + [
                HeaderConstant.XObjectMetaFolderLabel: "PANORAMA"
            ]
        }
        
        if item.asset?.mediaSubtypes == .videoTimelapse {
            header = header + [
                HeaderConstant.XObjectMetaFolderLabel: "TIME-LAPSE"
            ]
        }
        
        return header
    }
    
    var patch: URL {
        switch uploadType {
            case .sharedWithMe:
                return destitantionURL
                
            default:
                return URL(string: destitantionURL.absoluteString
                    .appending("/")
                    .appending(tmpUUID))!
        }
    }
    
    var timeout: TimeInterval {
        return 2000.0
    }
}


final class ResumableUpload: UploadRequestParametrs {
    
    private let item: WrapData
    private let uploadStrategy: MetaStrategy
    private let uploadTo: MetaSpesialFolder
    private let destitantionURL: URL
    private let isFavorite: Bool
    private var fileSize: Int?
    
    let uploadType: UploadType?
    
    private (set) var range = 0..<0
    private (set) var fileData: Data? = Data()
    private var isEmpty: Bool
    
    let rootFolder: String
    let tmpUUID: String
    
    let urlToLocalFile: URL? = nil
    

    var fileName: String {
        return item.name ?? "unknown"
    }
    
    var md5: String {
        return item.md5
    }

    
    init(item: WrapData, empty: Bool, fileSize: Int?, interruptedUploadId: String?, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool, uploadType: UploadType?) {
        
        self.item = item
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion
        self.isEmpty = empty
        self.isFavorite = isFavorite
        self.uploadType = uploadType
        self.fileSize = fileSize

        if let previousUploadId = interruptedUploadId {
            self.tmpUUID = previousUploadId
        } else {
            if item.isLocalItem {
                self.tmpUUID = "\(item.getTrimmedLocalID())~\(UUID().uuidString)"
            } else {
                self.tmpUUID = UUID().uuidString
            }
        }
    }
    
    var requestParametrs: Any {
        return Data()
    }

    
    var header: RequestHeaderParametrs {
        var header = RequestHeaders.authification()
        
        let currentUploadType = (uploadType == .autoSync) ? "AUTO_SYNC" : "MANUAL"
        let lifecycleState = ApplicationStateHelper.shared.isBackground ? "BG": "FG"
        let connectionType = ReachabilityService.shared.uploadConnectionTypeName
        
        let name = item.name ?? tmpUUID
        let fixed = name.precomposedStringWithCanonicalMapping
        let encodedName = fixed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name

        header = header + [
            HeaderConstant.connectionType : connectionType,
            HeaderConstant.uploadType : currentUploadType,
            HeaderConstant.applicationLifecycleState : lifecycleState,
            HeaderConstant.ContentType : item.uploadContentType,
            HeaderConstant.XMetaStrategy : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice : Device.deviceId ?? "",
            HeaderConstant.XObjectMetaFileName : encodedName,
            HeaderConstant.XObjectMetaFavorites : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder,
            HeaderConstant.XObjectMetaSpecialFolder : uploadTo.rawValue,
            HeaderConstant.Expect : "100-continue",
            HeaderConstant.XObjectMetaDeviceType : Device.deviceType,
            HeaderConstant.XObjectMetaIosMetadataHash : item.asset?.localIdentifier ?? "",
            HeaderConstant.ContentLength : "0"
        ]

        if let creationDate = item.asset?.creationDate {
            let milliseconds = Int64(creationDate.timeIntervalSince1970) * 1000
            header = header + [
                HeaderConstant.XObjectMetaTakenDate: String(milliseconds)
            ]
        }
        
        guard !isEmpty else {
            return header
        }
        
        guard let fileSize = fileSize, fileSize != 0, fileData?.count != 0 else {
            let attributes = item.toDebugAnalyticsAttributes()
            DebugAnalyticsService.log(event: .zeroContentLength, attributes: attributes)
            let errorMessage = "File size is 0. Check Answers event."
            debugLog(errorMessage)
            assertionFailure(errorMessage)
            return [:]
        }
        
        let contentRangeValue = "bytes \(range.lowerBound)-\(range.upperBound - 1)/\(fileSize)"
        
        header = header + [
            HeaderConstant.ContentLength : "\(fileSize)",
            HeaderConstant.ContentRange : contentRangeValue
        ]
        return header
    }
    
    var patch: URL {
        switch uploadType {
            case .sharedWithMe:
                //Currenly is not supported by BE
                assertionFailure()
                return URL(string: destitantionURL.absoluteString
                    .appending("&upload-type=resumable"))!
                
            default:
                return URL(string: destitantionURL.absoluteString
                    .appending("/")
                    .appending(tmpUUID)
                    .appending("?upload-type=resumable"))!
        }
    }
    
    var timeout: TimeInterval {
        return 2000.0
    }
    
    func update(chunk: DataChunk) {
        fileData = chunk.data
        range = chunk.range
        isEmpty = false
    }
}

class UploadNotify: BaseRequestParametrs {
    
    let parentUUID: String
    
    let fileUUID: String
    
    init(parentUUID: String, fileUUID: String) {
        if parentUUID.isEmpty {
            self.parentUUID = "ROOT_FOLDER"
        }else{
            self.parentUUID = parentUUID
        }
        //self.parentUUID = parentUUID
        self.fileUUID = fileUUID
        super.init()
    }
    
    override var patch: URL {
        let str = String(format: RouteRequests.uploadNotify,
                         parentUUID, fileUUID)
        return URL(string: str, relativeTo: super.patch)!
    }
}
