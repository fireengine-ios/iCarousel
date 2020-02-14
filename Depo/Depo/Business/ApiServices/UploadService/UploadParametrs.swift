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
    
    let rootFolder: String
    
    private let destitantionURL: URL
    
    private let isFavorite: Bool
    
//    var contentLenght: String {
//        return String(format: "%lu", item.fileSize)
//    }
    
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
    
    init(item: WrapData, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool) {
        
        self.item = item
        //self.uploadType = uploadType
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
        
        header = header + [
            HeaderConstant.ContentType           : item.uploadContentType,
            HeaderConstant.XMetaStrategy         : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice       : UIDevice.current.identifierForVendor?.uuidString ?? "",
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
    
    private (set) var range = 0..<0
    private (set) var fileData: Data? = Data()
    private var isSimple: Bool
    
    let rootFolder: String
    let tmpUUID: String
    
    let urlToLocalFile: URL? = nil
    

    var fileName: String {
        return item.name ?? "unknown"
    }
    
    var md5: String {
        return item.md5
    }

    
    init(item: WrapData, simple: Bool, interruptedUploadId: String?, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool) {
        
        self.item = item
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion
        self.isSimple = simple
        self.isFavorite = isFavorite

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
        
        header = header + [
            HeaderConstant.ContentType : item.uploadContentType,
            HeaderConstant.XMetaStrategy : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice : UIDevice.current.identifierForVendor?.uuidString ?? "",
            HeaderConstant.XObjectMetaFileName : item.name ?? tmpUUID,
            HeaderConstant.XObjectMetaFavorites : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder,
            HeaderConstant.XObjectMetaSpecialFolder : uploadTo.rawValue,
            HeaderConstant.Expect : "100-continue",
            HeaderConstant.XObjectMetaDeviceType : Device.deviceType,
            HeaderConstant.XObjectMetaIosMetadataHash : item.asset?.localIdentifier ?? "",
            HeaderConstant.ContentLength : "0"
        ]
        
        guard !isSimple else {
            return header
        }
        
        guard item.fileSize != 0, fileData?.count != 0 else {
            let attributes = item.toDebugAnalyticsAttributes()
            DebugAnalyticsService.log(event: .zeroContentLength, attributes: attributes)
            let errorMessage = "File size is 0. Check Answers event."
            debugLog(errorMessage)
            assertionFailure(errorMessage)
            return [:]
        }
        
        let contentRangeValue = "bytes \(range.lowerBound)-\(range.upperBound - 1)/\(item.fileSize)"
        
        header = header + [
            HeaderConstant.ContentLength : "\(item.fileSize)",
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
        isSimple = false
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
