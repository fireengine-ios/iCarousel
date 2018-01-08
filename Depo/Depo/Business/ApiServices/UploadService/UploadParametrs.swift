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
        return URL(string: UploadServiceConstant.baseUrl, relativeTo:super.patch)!
    }
}

class Upload: UploadRequestParametrs {
    
    private let item: WrapData
    
    private let uploadStrategy: MetaStrategy
    
    private let uploadTo: MetaSpesialFolder
    
    let rootFolder: String
    
    private let destitantionURL: URL
    
    private let isFavorite: Bool
    
    var contentType: String {
        switch item.fileType {
            
        case .image :
            return "image/jpg"
            
        case .video :
            return "video/mp4"
            
        default:
            return "unknown"
        }
    }
    
    var contentLenght:String {
        return String(format: "%lu", item.fileSize)
    }
    
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

        if item.isLocalItem, item.uuid.count > 0 {
            self.tmpUUId = item.uuid
        } else {
            self.tmpUUId = UUID().description
        }
    }
    
    var requestParametrs: Any {
        return Data()
    }
    var header: RequestHeaderParametrs {
        var header  = RequestHeaders.authification()
        
        header = header + [ HeaderConstant.ContentType : contentType,
            HeaderConstant.XMetaStrategy         : uploadStrategy.rawValue,
            HeaderConstant.XMetaRecentServerHash : "s",
            HeaderConstant.XObjectMetaFileName   : item.name ?? tmpUUId,
            HeaderConstant.XObjectMetaFavorites  : isFavorite ? "true" : "false",
            HeaderConstant.XObjectMetaParentUuid : rootFolder
//            HeaderConstant.Etag                   : md5
            //                  HeaderConstant.ContentLength         : contentLenght,
            //                  HeaderConstant.XObjectMetaParentUuid : rootFolder,
            //                  HeaderConstant.XObjectMetaSpecialFolder:uploadTo.rawValue,
            //                  HeaderConstant.XObjectMetaAlbumLabel  : "",
            //                  HeaderConstant.XObjectMetaFolderLabel : "",
            //                  HeaderConstant.Expect                 : "100-continue",
        ]
        return header
    }
    
    var patch: URL {
        return URL(string: destitantionURL.absoluteString
            .appending("/")
            .appending(tmpUUId))!
    }
}

final class UploadDataParametrs: UploadDataRequestParametrs {
    
    let data: Data
    let url: URL
    var parentUuid: String = ""
    var isFavorites: Bool = false
    
    init(data: Data, url: URL) {
        self.data = data
        self.url = url
    }
    
    var requestParametrs: Any {
        return Data()
    }
    
    let tmpUUId = UUID().description
    
    var md5: String {
        return MD5().hexMD5fromData(data)
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification() + [
            HeaderConstant.ContentType: "image/jpg",
            HeaderConstant.XMetaStrategy: MetaStrategy.WithoutConflictControl.rawValue,
            HeaderConstant.XMetaRecentServerHash: "s",
//            HeaderConstant.Etag: md5,
            HeaderConstant.XObjectMetaFileName: tmpUUId,
            HeaderConstant.XObjectMetaParentUuid: parentUuid,
            HeaderConstant.XObjectMetaFavorites: isFavorites ? "true" : "false"
        ]
    }
    
    var patch: URL {
        return URL(string: url.absoluteString
            .appending("/")
            .appending(tmpUUId))!
    }
}


class UploadNotify: BaseRequestParametrs {
    
    let parentUUID: String
    
    let fileUUID: String
    
    init(parentUUID: String, fileUUID: String) {
        self.parentUUID = parentUUID
        self.fileUUID = fileUUID
        super.init()
    }
    
    override var patch: URL {
        let str = String(format: UploadServiceConstant.uploadNotify,
                         parentUUID, fileUUID)
        return URL(string: str, relativeTo:super.patch)!
    }
}
