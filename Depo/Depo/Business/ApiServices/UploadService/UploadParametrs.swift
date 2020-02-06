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
    
    let tmpUUId: String
    
    init(item: WrapData, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool) {
        
        self.item = item
        //self.uploadType = uploadType
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion

        self.isFavorite = isFavorite

        if item.isLocalItem {
            self.tmpUUId = "\(item.getTrimmedLocalID())~\(UUID().uuidString)"
        } else {
            self.tmpUUId = UUID().uuidString
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
            HeaderConstant.XObjectMetaFileName   : item.name ?? tmpUUId,
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
            .appending(tmpUUId))!
    }
    
    var timeout: TimeInterval {
        return 2000.0
    }
}

final class ResumableUploadEmpty: RequestParametrs {
    
    let tmpUUID: String
    let destitantionURL: URL
    
    let requestParametrs: Any = Data()
    
    var patch: URL {
        return URL(string: destitantionURL.absoluteString
            .appending("/")
            .appending(tmpUUID)
            .appending("?upload-type=resumable"))!
    }
    
    var timeout: TimeInterval {
        return 2000.0
    }
    
    
    var header: RequestHeaderParametrs {
        let header = RequestHeaders.authification() + [HeaderConstant.ContentLength : "\(0)"]
        return header
    }
    
    init(item: WrapData, destitantionURL: URL) {
        self.destitantionURL = destitantionURL
        
        if item.isLocalItem {
            self.tmpUUID = "\(item.getTrimmedLocalID())~\(UUID().uuidString)"
        } else {
            self.tmpUUID = UUID().uuidString
        }
    }
}

final class ResumableUpload: UploadRequestParametrs {

    private let item: WrapData
    private let uploadStrategy: MetaStrategy
    private let uploadTo: MetaSpesialFolder
    private let destitantionURL: URL
    private let isFavorite: Bool
    private let range: Range<Int>
    
    let rootFolder: String
    let tmpUUId: String
    
    let urlToLocalFile: URL? = nil
    private (set) var fileData: Data?

    var fileName: String {
        return item.name ?? "unknown"
    }
    
    var md5: String {
        return item.md5
    }

    
    init(item: WrapData, data: Data, range: Range<Int>, destitantion: URL, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String, isFavorite: Bool) {
        
        self.item = item
        self.fileData = data
        self.range = range
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion

        self.isFavorite = isFavorite

        if item.isLocalItem {
            self.tmpUUId = "\(item.getTrimmedLocalID())~\(UUID().uuidString)"
        } else {
            self.tmpUUId = UUID().uuidString
        }
    }
    
    var requestParametrs: Any {
        return Data()
    }

    
    var header: RequestHeaderParametrs {
        var header = RequestHeaders.authification()
        
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
            HeaderConstant.ContentType           : item.uploadContentType,
            HeaderConstant.XMetaStrategy         : uploadStrategy.rawValue,
            HeaderConstant.objecMetaDevice       : UIDevice.current.identifierForVendor?.uuidString ?? "",
//            HeaderConstant.XMetaRecentServerHash : "s",
            HeaderConstant.XObjectMetaFileName   : item.name ?? tmpUUId,
            HeaderConstant.XObjectMetaFavorites  : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder,
            HeaderConstant.XObjectMetaSpecialFolder : uploadTo.rawValue,
            HeaderConstant.Expect                : "100-continue",
            HeaderConstant.XObjectMetaDeviceType : Device.deviceType,
            HeaderConstant.XObjectMetaIosMetadataHash : item.asset?.localIdentifier ?? "",
            HeaderConstant.ContentLength         : "\(item.fileSize)",
            HeaderConstant.ContentRange          : contentRangeValue
        ]
        return header
    }
    
    var patch: URL {
        return URL(string: destitantionURL.absoluteString
            .appending("/")
            .appending(tmpUUId)
            .appending("?upload-type=resumable"))!
    }
    
    var timeout: TimeInterval {
        return 2000.0
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
