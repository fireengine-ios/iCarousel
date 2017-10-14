//
//  UploadService.swift
//  Depo
//
//  Created by Alexander Gurin on 1/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

enum UploadPriority {
   
    case low
    
    case normal
    
    case critical
}

class UploadBaseURL: BaseRequestParametrs {
    
    
    override var requestParametrs: Any {
        return Data()
    }
    
    override var patch: URL {
        return URL(string: UploadServiceConstant.baseUrl, relativeTo:super.patch)!
    }
}

typealias UploadServiceBaseUrlResponse  = (_ resonse: UploadBaseURLResponse?) -> Swift.Void

struct UploadServiceConstant {
    
    static let baseUrl = "/api/container/baseUrl"
    
    static let uploadNotify = "/api/notification/onFileUpload?parentFolderUuid=%@&fileName=%@"
    
}

class UploadBaseURLResponse: ObjectRequestResponse {
    
    var url: URL?
    
    var uniqueValueByBaseUrl: String = ""
    
    override func mapping() {
        url = json?["value"].url
        let list =  json?["value"].string?
            .components(separatedBy: "/")
            .filter{ $0.hasPrefix("AUTH_")}
        uniqueValueByBaseUrl = list?.first ?? ""
    }
}

enum MetaSpesialFolder: String {
    
    case MOBILE_UPLOAD = "MOBILE_UPLOAD"
    
    case CROPY = "CROPY"
    
    case none = ""
}

enum UploadType {
    
    case fromHomePage
    
    case autoSync
    
    case other
}

enum MetaStrategy: String {
    
    case ConflictControl = "0"
    
    case WithoutConflictControl = "1"
}

class Upload: UploadRequestParametrs {
    
    private let item: WrapData
    
    private let uploadType:UploadType
    
    private let uploadStrategy: MetaStrategy
    
    private let uploadTo: MetaSpesialFolder
    
    private let rootFolder: String
    
    private let destitantionURL: URL
    
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
    
    var urlToLocalFile: URL {
        return tmpLocation
    }
    
    lazy var tmpLocation: URL = {
       return LocalMediaStorage.default.copyAssetToDocument(asset: self.item.asset!)
    }()
    
    let  tmpUUId: String
    
    init(item: WrapData, destitantion: URL, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, rootFolder: String) {
        
        self.item = item
        self.uploadType = uploadType
        self.rootFolder = rootFolder
        self.uploadStrategy = uploadStategy
        self.uploadTo = uploadTo
        self.destitantionURL = destitantion
        self.tmpUUId = UUID().description
    }
    
     var requestParametrs: Any {
        return Data()
    }
    var header: RequestHeaderParametrs {
        var header  = RequestHeaders.authification()
        
        header = header + [ HeaderConstant.ContentType : contentType,
                  HeaderConstant.ContentLength         : contentLenght,
                  HeaderConstant.XMetaStrategy         : uploadStrategy.rawValue,
                  HeaderConstant.XMetaRecentServerHash : "s",
                  HeaderConstant.XObjectMetaFileName   : fileName,
                  HeaderConstant.XObjectMetaParentUuid : rootFolder,
                  HeaderConstant.XObjectMetaSpecialFolder:uploadTo.rawValue,
                  HeaderConstant.XObjectMetaAlbumLabel  : "",
                  HeaderConstant.XObjectMetaFolderLabel : "",
                  HeaderConstant.Expect                 : "100-continue",
                  HeaderConstant.Etag                   : md5]
        return header
    }
    
    var patch: URL {
        return URL(string: destitantionURL.absoluteString
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


class UploadNotifyResponse: ObjectRequestResponse {
    
    var itemResponse : SearchItemResponse?
    
    override func mapping() {
        itemResponse = SearchItemResponse(withJSON: self.json)
    }
}


class UploadResponse: ObjectRequestResponse {
    
    var url: URL?
    
    var userUniqueValue: String?
    
    override func mapping() {
        
        if let st = json?["value"].string, isOkStatus {
            
            url = json?["value"].url
            
            userUniqueValue = st.components(separatedBy: "/")
                                .filter{ $0.hasPrefix("AUTH_")}
                                .first
        }
    }
}


class UloadSuccess: ObjectRequestResponse {
    
    override func mapping() {
        print("A")
    }
}

typealias FileUploadOperationSucces = (_ item: WrapData) -> Swift.Void


class UploadService: BaseRequestService {
    
    static let `default` = UploadService()
    
    private let dispatchQueue: DispatchQueue
    
    private let syncQueue: OperationQueue
    private let uploadQueue: OperationQueue
    
    override init() {
        
        uploadQueue = OperationQueue()
        uploadQueue.maxConcurrentOperationCount = 1
        
        syncQueue = OperationQueue()
        syncQueue.maxConcurrentOperationCount = 1
        
        dispatchQueue = DispatchQueue(label: "Upload Queue")
        super.init()
    }
    
    func uploadFileList(items: [WrapData], uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", success: FileOperationSucces?, fail: FailResponse? ) {
        WrapItemOperatonManager.default.startOperationWith(type: .upload, allOperations: items.count, completedOperations: 0)
        let allOperationCount = items.count
        var completedOperationCount = 0
        let operations: [UploadOperations] = items.flatMap {
            UploadOperations(item: $0, uploadType: uploadType, uploadStategy: uploadStategy, uploadTo: uploadTo, folder: folder, success: {
                completedOperationCount = completedOperationCount + 1
                WrapItemOperatonManager.default.setProgressForOperationWith(type: .upload, allOperations: allOperationCount, completedOperations: completedOperationCount)
            }, fail: { (error) in
                
            })
        }
        
        dispatchQueue.async {
            self.uploadQueue.addOperations(operations, waitUntilFinished: true)
            success?()
            WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
        }
    }
    
    func upload(uploadParam: Upload, success: FileOperationSucces?, fail: FailResponse? ) {
    
        executeUploadRequest(param: uploadParam,
                             response: { (data, response, error) in
                            
            if let httpResponse = response as? HTTPURLResponse {
                if 200...299 ~= httpResponse.statusCode {
                    success?()
                    return
                } else {
                    fail?(.httpCode(httpResponse.statusCode))
                    return
                }
            }
                                
            fail?(.string("Error upload"))
        })
    }
    
    func baseUrl(success: @escaping UploadServiceBaseUrlResponse, fail:FailResponse?) {
        
        let param = UploadBaseURL()
        let handler = BaseResponseHandler<UploadBaseURLResponse, ObjectRequestResponse>(success: { result in
           success(result as? UploadBaseURLResponse)
        }, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
    
    func uploadNotify(param: UploadNotify, success: @escaping SuccessResponse, fail:FailResponse?) {
        
        let handler = BaseResponseHandler<UploadNotifyResponse, ObjectRequestResponse>(success: success, fail: fail)
        
        executeGetRequest(param: param, handler: handler)
    }
    
    
    private class UploadOperations: Operation {
        
        let item: WrapData
        let uploadType: UploadType
        let uploadStategy: MetaStrategy
        let uploadTo: MetaSpesialFolder
        let folder: String
        let success: FileOperationSucces?
        let fail: FailResponse?
        
        private let semaphore: DispatchSemaphore
        
        init(item: WrapData, uploadType: UploadType, uploadStategy: MetaStrategy, uploadTo: MetaSpesialFolder, folder: String = "", success: FileOperationSucces?, fail: FailResponse?) {
            
            self.item = item
            self.uploadType = uploadType
            self.uploadTo = uploadTo
            self.uploadStategy = uploadStategy
            self.folder = folder
            self.success = success
            self.fail = fail
            self.semaphore = DispatchSemaphore(value: 0)
        }
        
        override func main() {
            
            if isCancelled {
                return
            }
            
            let customSucces: FileOperationSucces = {
                self.success?()
                self.semaphore.signal()
            }
            
            let customFail: FailResponse = { value in
                self.fail?(value)
                self.semaphore.signal()
            }
            
            baseUrl(success: { baseurlResponse in
                
                let uploadParam  = Upload(item: self.item,
                                         destitantion: (baseurlResponse?.url!)!,
                                         uploadType: self.uploadType,
                                         uploadStategy: self.uploadStategy,
                                         uploadTo: self.uploadTo,
                                         rootFolder: self.folder)
                self.upload(uploadParam: uploadParam, success: {
                    
                    let uploadNotifParam = UploadNotify(parentUUID: "",
                                                        fileUUID:uploadParam.tmpUUId )
                    
                    self.uploadNotify(param: uploadNotifParam, success: { baseurlResponse in
                
                        let url = uploadParam.urlToLocalFile
                        
                        do {
                            try FileManager.default.removeItem(at: url)
                            
                            if let response = baseurlResponse as? UploadNotifyResponse,
                                let uploadedFileDetail = response.itemResponse {
                                let wrapDataValue = WrapData(remote: uploadedFileDetail)
                                CoreDataStack.default.appendOnlyNewItems(items: [wrapDataValue])
                            }
                            
                        } catch {
                           print("not remove")
                        }
                        
                        customSucces()
                        
                    }, fail: customFail)
                    
                }, fail: customFail)
                
            }, fail: customFail)
            
            semaphore.wait()
        }
        
        private func baseUrl(success: @escaping UploadServiceBaseUrlResponse, fail:FailResponse?) {
            UploadService.default.baseUrl(success: success, fail: fail)
        }
        
        private func upload(uploadParam: Upload, success: FileOperationSucces?, fail: FailResponse? ) {
            UploadService.default.upload(uploadParam: uploadParam,
                                         success: success,
                                         fail: fail)
        }
        
        private func uploadNotify(param: UploadNotify, success: @escaping SuccessResponse, fail:FailResponse?) {
            
            UploadService.default.uploadNotify(param: param,
                                               success: success,
                                               fail: fail)
        }
        
    }
}

