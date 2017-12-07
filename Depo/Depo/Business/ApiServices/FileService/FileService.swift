//
//  FileService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Photos

struct FilePatch  {
    static let fileList = "/api/filesystem?parentFolderUuid=%@&sortBy=%@&sortOrder=%@&page=%@&size=%@&folderOnly=%@"
    static let create = "/api/filesystem/createFolder?parentFolderUuid=%@"
    static let delete = "/api/filesystem/delete"
    static let rename = "/api/filesystem/rename/%@"
    static let move =   "/api/filesystem/move?targetFolderUuid=%@"
    static let copy =   "/api/filesystem/copy?targetFolderUuid=%@"
    static let details = "/api/filesystem/details"
    static let detail =  "/api/filesystem/detail/%@"
    
    static let metaData = "/api/filesystem/metadata"
}



class CreatesFolder: BaseRequestParametrs {
    
    let folderName: String
    let rootFolderName: String
    let isFavourite: Bool
    
    init(folderName: String, rootFolderName: String, isFavourite: Bool = false) {
        self.folderName = folderName
        self.rootFolderName = rootFolderName
        self.isFavourite = isFavourite
    }
    
    override var requestParametrs: Any {
        let dict: [String: Any] = [SearchJsonKey.metadata :[SearchJsonKey.favourite :(isFavourite ? "true" :"false")]]
        return dict
    }
    
    override var patch: URL {
        let path: String = String(format:FilePatch.create,rootFolderName )
        return URL(string: path, relativeTo:super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        return super.header + ["Folder-Name":folderName]
    }
}


class CreateFolderResponse: ObjectRequestResponse {
    
    override func mapping() {
        print("A")
    }
}

class DeleteFiles: BaseRequestParametrs {

    let items: [String]
    
    override var requestParametrs: Any {
        return items
    }
    
    override var patch: URL {
        return URL(string: FilePatch.delete, relativeTo: super.patch)!
    }
    
    init(items: [String]) {
        self.items = items
    }
}

class MoveFiles: BaseRequestParametrs {
    
    let items: [String]
    let path: String
    
    override var requestParametrs: Any {
        return items
    }
    
    override var patch: URL {
        let str = String(format: FilePatch.move, path)
        return URL(string: str, relativeTo: super.patch)!
    }
    
    init(items: [String], path: String) {
        self.items = items
        self.path = path
    }
}

class CopyFiles: BaseRequestParametrs {
    
    let items: [String]
    let path: String
    
    override var requestParametrs: Any {
        return items
    }
    
    override var patch: URL {
        let str = String(format: FilePatch.copy, path)
        return URL(string: str, relativeTo: super.patch)!
    }
    
    init(items: [String], path: String) {
        self.items = items
        self.path = path
    }
}


class UploadFile: BaseRequestParametrs {
    
    let urlToFile: URL
    
    init(url: URL) {
        urlToFile = url
    }
    
    override var patch: URL {
        return urlToFile
    }
}


class RenameFile: BaseRequestParametrs {
    
    let uuid: String
    let newName: String
    
    init(uuid: String, newName: String) {
        self.uuid = uuid
        self.newName = newName
    }
    
    override var requestParametrs: Any {
        return Data()
    }
    
    override var patch: URL {
        let path: String = String(format:FilePatch.rename, uuid)
        return URL(string: path, relativeTo:super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        return super.header + ["New-Name":newName]
    }
}

class MetaDataFile: BaseRequestParametrs {
    
    let favouritsItems: [String]
    let addToFavorit: Bool
    
    override var requestParametrs: Any {
        let param = addToFavorit ? "true" : "false"
        return [SearchJsonKey.fileList: favouritsItems,
                SearchJsonKey.metadata:[SearchJsonKey.favourite: param]]
    }
    
    override var patch: URL {
        return URL(string: FilePatch.metaData, relativeTo:super.patch)!
    }
    
    init(items: [String], addToFavourit: Bool) {
        self.favouritsItems = items
        self.addToFavorit = addToFavourit
    }
}

class FileDetail: BaseRequestParametrs {
    
    let uuid: String
    
    override var requestParametrs: Any {
        return Data()
    }
    
    override var patch: URL {
        let str = String(format: FilePatch.detail, uuid)
        return URL(string: str, relativeTo:super.patch)!
    }
    
    init(uuid: String) {
        self.uuid = uuid
    }
}

class FileDetails: BaseRequestParametrs {
    
    let uuid: [String]
    
    override var requestParametrs: Any {
        return uuid
    }
    
    override var patch: URL {
        return URL(string: FilePatch.details, relativeTo:super.patch)!
    }
    
    init(uuids: [String] ) {
        uuid = uuids
        super.init()
    }
}


class FileList: BaseRequestParametrs{
    let sortBy: SortType
    let sortOrder: SortOrder
    let folderOnly: Bool
    let rootDir: String
    let page: Int
    let size: Int
    
    init(rootDir: String = "",  sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int, folderOnly: Bool = false) {
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.rootDir = rootDir
        self.page = page
        self.size = size
        self.folderOnly = folderOnly
    }
    
    override var patch: URL {
        let folder = folderOnly ? "true": "false"
        let path: String = String(format:FilePatch.fileList, rootDir,
                                  sortBy.description, sortOrder.description,
                                  page.description, size.description, folder)
        
        return URL(string: path, relativeTo:super.patch)!
    }
}

class DetailResponse: ObjectRequestResponse {
    
    override func mapping() {
        print("A")
    }
}

class DetailsResponse: ObjectRequestResponse {
    
    override func mapping() {
        print("A")
    }
}

typealias FileOperation = () -> Swift.Void

class FileService: BaseRequestService {
    
    let downloadOperation = OperationQueue()
    private let dispatchQueue = DispatchQueue(label: "Download Queue")
    
    func move(moveFiles: MoveFiles , success: FileOperation?, fail:FailResponse?) {
        let handler = BaseResponseHandler<ObjectRequestResponse,ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePostRequest(param: moveFiles, handler: handler)
    }
    
    func copy(copyparam: CopyFiles, success: FileOperation?, fail:FailResponse?) {
        let handler = BaseResponseHandler<ObjectRequestResponse,ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePostRequest(param: copyparam, handler: handler)
    }
    
    func delete(deleteFiles: DeleteFiles, success: FileOperation?, fail:FailResponse?) {
        let handler = BaseResponseHandler<ObjectRequestResponse,ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executeDeleteRequest(param: deleteFiles, handler: handler)
    }
    
    func createsFolder(createFolder: CreatesFolder, success: FileOperation?, fail:FailResponse?) {
        
        let handler = BaseResponseHandler<CreateFolderResponse,ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePostRequest(param: createFolder, handler: handler)
    }
    
    func rename(rename: RenameFile, success: FileOperation?, fail:FailResponse?) {
        
        let handler = BaseResponseHandler<SearchResponse,ObjectRequestResponse>(success: { y  in
            success?()
        }, fail: fail)
        executePostRequest(param: rename, handler: handler)
    }
    
    
    //MARK: download && upload
    
    func download(items: [WrapData], success: FileOperation?, fail:FailResponse?) {
        let allOperationsCount = items.count
        WrapItemOperatonManager.default.startOperationWith(type: .download, allOperations: allOperationsCount, completedOperations: 0)
        let downLoadRequests: [BaseDownloadRequestParametrs] = items.flatMap { BaseDownloadRequestParametrs(urlToFile: $0.urlToFile!, fileName: $0.name!, contentType: $0.fileType) }
        var completedOperationsCount = 0
        let operations = downLoadRequests.flatMap {
            DownLoadOperation(downloadParam: $0, success: {
                completedOperationsCount = completedOperationsCount + 1
                WrapItemOperatonManager.default.setProgressForOperationWith(type: .download,
                                                                            allOperations: allOperationsCount,
                                                                            completedOperations: completedOperationsCount)
            }, fail: { (error) in
                
            })
        }
        
        dispatchQueue.async {
            self.downloadOperation.addOperations(operations, waitUntilFinished: true)
            WrapItemOperatonManager.default.stopOperationWithType(type: .download)
            success?()
        }
    }
    
    func downloadToCameraRoll(downloadParam: BaseDownloadRequestParametrs, success: FileOperation?, fail:FailResponse?) {
        
        executeDownloadRequest(param: downloadParam) { (url, urlResponse, error) in
            
            if let err = error {
                fail?(.error(err))
                return
            }

            if let httpResponse = urlResponse as? HTTPURLResponse,
                let location = url {
                if 199...299 ~= httpResponse.statusCode {
                    
                    let destination = Device.documentsFolderUrl(withComponent: downloadParam.fileName)
                    
                    let removeDestinationFile: () -> Swift.Void = {
                        
                        do {
                            try FileManager.default.removeItem(at: destination)
                        } catch { }
                    }
                    
                    do {
                        try FileManager.default.moveItem(at: location, to: destination)
                    } catch {
                        
                        fail?(.string("Downoad move file error"))
                        return
                    }
                    
                    var type = PHAssetMediaType.unknown
                    
                    switch downloadParam.contentType {
                        case .image : type = .image
                        case .video : type = .video
                        default     : break
                    }
                    
                    LocalMediaStorage.default.appendToAlboum(fileUrl: destination,
                                                       type: type,
                                                       album: nil, success: {
                        removeDestinationFile()
                        success?()
                        
                    }, fail: { (error) in
                        removeDestinationFile()
                        fail?(error)
                    })

                } else {
                    fail?(.string("Incorrect response "))
                    return
                }
            } else {
                fail?(.string("Incorrect response  "))
                return
            }
        }
    }
    
    func detail(uuids: String, success: FileOperation?, fail:FailResponse?) {
        let param = FileDetail(uuid: uuids)
        let handler = BaseResponseHandler<DetailResponse, ObjectRequestResponse>(success: {  detail  in
            print("s")
        }, fail: fail)
        executePutRequest(param: param,
                        handler: handler)
    }
    
    func details(uuids: [String], success: ListRemoveItems?, fail:FailResponse?) {
        
        let param = FileDetails(uuids: uuids)
        let handler = BaseResponseHandler<SearchResponse, ObjectRequestResponse>(success: { (responce) in
            guard let resultResponse = (responce as? SearchResponse)?.list else {
                let error = ErrorResponse.string("Unknown error")
                fail?(error)
                return
            }
            
            let list = resultResponse.flatMap { WrapData(remote: $0) }
            CoreDataStack.default.appendOnlyNewItems(items: list)
            success?(list)
        }, fail: fail)
        self.executePostRequest(param: param, handler: handler)
    }
    
    
    // Favourits && TAG
    
    func medaDataRequest(param: MetaDataFile, success: FileOperation?, fail:FailResponse?) {
        let handler = BaseResponseHandler<FileListResponse, ObjectRequestResponse>(success: { _ in
            success?()
        }, fail: fail)

        executePostRequest(param: param, handler: handler)
    }
    
    private var page = 0
    private let size = 100
    
    func filesList(rootFolder: String = "", sortBy: SortType, sortOrder: SortOrder,
                   folderOnly: Bool = false, remoteServicePage: Int,
                   success: ListRemoveItems?, fail: FailRemoteItems?) {
        page = remoteServicePage
        let requestParam = FileList(rootDir: rootFolder,
                                    sortBy: sortBy,
                                    sortOrder: sortOrder,
                                    page: page,
                                    size: size,
                                    folderOnly: folderOnly)
        let handler = BaseResponseHandler<FileListResponse, ObjectRequestResponse>(success: { (response) in
            guard let resultResponse = (response as? FileListResponse)?.fileList else {
                fail?()
                return
            }
            success?(resultResponse)
//            self.page += 1
        }, fail: { (error) in
            fail?()
        })
        
        executeGetRequest(param: requestParam, handler: handler)
    }
}

class DownLoadOperation: Operation {
    
    let success: FileOperation?
    
    let fail: FailResponse?
    
    let param: BaseDownloadRequestParametrs
    
    private let semaphore: DispatchSemaphore
    
    init(downloadParam: BaseDownloadRequestParametrs, success: FileOperation?, fail:FailResponse?) {
        self.param = downloadParam
        self.success = success
        self.fail = fail
        self.semaphore = DispatchSemaphore(value: 0)
        super.init()
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        FileService().downloadToCameraRoll(downloadParam: param, success: {
            self.customSuccess()
        }) { (error) in
            self.customFail(error)
        }
        semaphore.wait()
    }
    
    func customSuccess(){
        success?()
        semaphore.signal()
    }
    
    func customFail(_ value: ErrorResponse){
        fail?(value)
        semaphore.signal()
    }
}
