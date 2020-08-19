//
//  UploadParametrs.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Crashlytics

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
        }
        
        return nil
    }()

    var fileData: Data? {
        return item.fileData
    }
    
    private var fileSize: Int64 {
        if let url = urlToLocalFile,
            let resources = try? url.resourceValues(forKeys:[.fileSizeKey]),
            let fileSize = resources.fileSize {
            return Int64(fileSize)
        }
        
        return item.fileSize
    }
    
    let tmpUUID: String
    
    init(item: WrapData, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool, uploadType: UploadType?) {
        
        self.item = item
        self.uploadType = uploadType
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion
        self.isFavorite = isFavorite

        if item.isLocalItem {
            self.tmpUUID = "\(item.getTrimmedLocalID())~\(UUID().uuidString)"
        } else {
            self.tmpUUID = UUID().uuidString
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

        header = header + [
            HeaderConstant.connectionType        : connectionStatus,
            HeaderConstant.uploadType            : appopriateUploadType,
            HeaderConstant.applicationLifecycleState : lifecycleState,
            HeaderConstant.ContentType           : item.uploadContentType,
            HeaderConstant.XMetaStrategy         : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice       : Device.deviceId ?? "",
//            HeaderConstant.XMetaRecentServerHash : "s",
            HeaderConstant.XObjectMetaFileName   : item.name ?? tmpUUID,
            HeaderConstant.XObjectMetaFavorites  : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder,
            HeaderConstant.XObjectMetaSpecialFolder : uploadTo.rawValue,
            HeaderConstant.Expect                : "100-continue",
            HeaderConstant.XObjectMetaDeviceType : Device.deviceType,
            HeaderConstant.XObjectMetaIosMetadataHash : item.asset?.localIdentifier ?? "",
            HeaderConstant.ContentLength         : "\(fileSize)"
        ]
        return header
    }
    
    var patch: URL {
        return URL(string: destitantionURL.absoluteString
            .appending("/")
            .appending(tmpUUID))!
    }
    
    var timeout: TimeInterval {
        return 2000.0
    }
}

class SaveUpload: UploadRequestParametrs {
//for now its a 99% copy of SimpleUpload.
    
    private let item: WrapData
    private let uploadStrategy: MetaStrategy
    private let uploadTo: MetaSpesialFolder
    private let destitantionURL: URL
    private let isFavorite: Bool
    
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
        }
        
        return nil
    }()
    
    var fileData: Data? {
        return item.fileData
    }
    
    let tmpUUID: String
    
    init(item: WrapData, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool, uploadType: UploadType?) {
        
        self.item = item
        self.uploadType = uploadType
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion
        self.isFavorite = item.favorites
        self.tmpUUID = item.uuid
        
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
        
        header = header + [
            HeaderConstant.connectionType        : connectionStatus,
            HeaderConstant.uploadType            : appopriateUploadType,
            HeaderConstant.applicationLifecycleState : lifecycleState,
            HeaderConstant.ContentType           : item.uploadContentType,
            HeaderConstant.XMetaStrategy         : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice       : Device.deviceId ?? "",
            //            HeaderConstant.XMetaRecentServerHash : "s",
            HeaderConstant.XObjectMetaFileName   : item.name ?? tmpUUID,
            HeaderConstant.XObjectMetaFavorites  : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder,
            HeaderConstant.XObjectMetaSpecialFolder : uploadTo.rawValue,
            HeaderConstant.Expect                : "100-continue",
            HeaderConstant.XObjectMetaDeviceType : Device.deviceType,
            HeaderConstant.XObjectMetaIosMetadataHash : item.asset?.localIdentifier ?? "",
            HeaderConstant.ContentLength         : "\(item.fileSize)"
        ]
        return header
    }
    
    var patch: URL {
        return URL(string: destitantionURL.absoluteString
            .appending("/")
            .appending(tmpUUID))!
    }
    
    var timeout: TimeInterval {
        return 2000.0
    }
}

//TODO: refactor this, too much of repeatable code
class SaveAsUpload: UploadRequestParametrs {
//for now its a 99% copy of SimpleUpload.
    
    private let item: WrapData
    private let uploadStrategy: MetaStrategy
    private let uploadTo: MetaSpesialFolder
    private let destitantionURL: URL
    private let isFavorite: Bool
    
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
        }
        
        return nil
    }()
    
    var fileData: Data? {
        return item.fileData
    }
    
    let tmpUUID: String
    
    init(item: WrapData, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool, uploadType: UploadType?) {
        
        self.item = item
        self.uploadType = uploadType
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion
        self.isFavorite = item.favorites
        self.tmpUUID = "\(item.getTrimmedLocalID())~\(UUID().uuidString)"
        
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
        
        header = header + [
            HeaderConstant.connectionType        : connectionStatus,
            HeaderConstant.uploadType            : appopriateUploadType,
            HeaderConstant.applicationLifecycleState : lifecycleState,
            HeaderConstant.ContentType           : item.uploadContentType,
            HeaderConstant.XMetaStrategy         : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice       : Device.deviceId ?? "",
            //            HeaderConstant.XMetaRecentServerHash : "s",
            HeaderConstant.XObjectMetaFileName   : item.name ?? tmpUUID,
            HeaderConstant.XObjectMetaFavorites  : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder,
            HeaderConstant.XObjectMetaSpecialFolder : uploadTo.rawValue,
            HeaderConstant.Expect                : "100-continue",
            HeaderConstant.XObjectMetaDeviceType : Device.deviceType,
            HeaderConstant.XObjectMetaIosMetadataHash : item.asset?.localIdentifier ?? "",
            HeaderConstant.ContentLength         : "\(item.fileSize)"
        ]
        return header
    }
    
    var patch: URL {
        return URL(string: destitantionURL.absoluteString
            .appending("/")
            .appending(tmpUUID))!
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
        
        header = header + [
            HeaderConstant.connectionType : connectionType,
            HeaderConstant.uploadType : currentUploadType,
            HeaderConstant.applicationLifecycleState : lifecycleState,
            HeaderConstant.ContentType : item.uploadContentType,
            HeaderConstant.XMetaStrategy : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice : Device.deviceId ?? "",
            HeaderConstant.XObjectMetaFileName : item.name ?? tmpUUID,
            HeaderConstant.XObjectMetaFavorites : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder,
            HeaderConstant.XObjectMetaSpecialFolder : uploadTo.rawValue,
            HeaderConstant.Expect : "100-continue",
            HeaderConstant.XObjectMetaDeviceType : Device.deviceType,
            HeaderConstant.XObjectMetaIosMetadataHash : item.asset?.localIdentifier ?? "",
            HeaderConstant.ContentLength : "0"
        ]
        
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
        return URL(string: destitantionURL.absoluteString
            .appending("/")
            .appending(tmpUUID)
            .appending("?upload-type=resumable"))!
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
