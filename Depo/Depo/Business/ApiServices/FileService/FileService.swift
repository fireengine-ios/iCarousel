//
//  FileService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

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
        let path: String = String(format: RouteRequests.FileSystem.create, rootFolderName )
        return URL(string: path, relativeTo: super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        let name = folderName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? folderName
        return super.header + ["Folder-Name": name]
    }
}


class CreateFolderResponse: ObjectRequestResponse {
    var folder: WrapData?
    
    override func mapping() {
        guard let json = json else { 
            return 
        }
        
        folder = WrapData(remote: SearchItemResponse(withJSON: json))
    }
}

class DeleteFiles: BaseRequestParametrs {

    let items: [String]
    
    override var requestParametrs: Any {
        return items
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.FileSystem.delete, relativeTo: super.patch)!
    }
    
    init(items: [String]) {
        self.items = items
    }
}

class MoveToTrashFiles: BaseRequestParametrs {
   
    let items: [String]
    
    override var requestParametrs: Any {
        return items
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.FileSystem.trash, relativeTo: super.patch)!
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
        let str = String(format: RouteRequests.FileSystem.move, path)
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
        let str = String(format: RouteRequests.FileSystem.copy, path)
        return URL(string: str, relativeTo: super.patch)!
    }
    
    init(items: [String], path: String) {
        self.items = items
        self.path = path
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
        let path: String = String(format: RouteRequests.FileSystem.rename, uuid)
        return URL(string: path, relativeTo: super.patch)!
    }
    
    override var header: RequestHeaderParametrs {
        let name = newName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? newName
        return super.header + ["New-Name": name]
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
        return URL(string: RouteRequests.FileSystem.metaData, relativeTo: super.patch)!
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
        let str = String(format: RouteRequests.FileSystem.detail, uuid)
        return URL(string: str, relativeTo: super.patch)!
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
        return URL(string: RouteRequests.FileSystem.details, relativeTo: super.patch)!
    }
    
    init(uuids: [String] ) {
        uuid = uuids
        super.init()
    }
}


class FileList: BaseRequestParametrs {
    let sortBy: SortType
    let sortOrder: SortOrder
    let folderOnly: Bool
    let rootDir: String
    let page: Int
    let size: Int
    let status: ItemStatus
    
    init(rootDir: String = "", sortBy: SortType, sortOrder: SortOrder, page: Int, size: Int, folderOnly: Bool = false, status: ItemStatus) {
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.rootDir = rootDir
        self.page = page
        self.size = size
        self.folderOnly = folderOnly
        self.status = status
    }
    
    override var patch: URL {
        let folder = folderOnly ? "true": "false"
        let path: String
        
        if status == .trashed {
            path = String(format: RouteRequests.FileSystem.trashedList, rootDir,
                          sortBy.description, sortOrder.description,
                          page.description, size.description, folder)
        } else {
            path = String(format: RouteRequests.FileSystem.fileList, rootDir,
                          sortBy.description, sortOrder.description,
                          page.description, size.description, folder)
        }

        return URL(string: path, relativeTo: super.patch)!
    }
}

class DetailResponse: ObjectRequestResponse {
    
    override func mapping() {
        print("A")
    }
}

typealias FileOperation = () -> Void
typealias FolderOperation = (Item?) -> Void
typealias UpdateFileOperation = (WrapData) -> Void

class FileService: BaseRequestService {
    
    static let shared = FileService()
    
    
    private let downloadOperation = OperationQueue()
    private let dispatchQueue = DispatchQueue(label: DispatchQueueLabels.download)
    private var allOperationsCount : Int = 0
    private var completedOperationsCount : Int = 0
    
    private lazy var downloadDocumentService = DocumentDownloadService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    
    override init() {
        super.init()
        downloadOperation.maxConcurrentOperationCount = 1
    }
    
    func move(moveFiles: MoveFiles, success: FileOperation?, fail: FailResponse?) {
        debugLog("FileService moveFiles: \(moveFiles.items.joined(separator: ", "))")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePostRequest(param: moveFiles, handler: handler)
    }
    
    func copy(copyparam: CopyFiles, success: FileOperation?, fail: FailResponse?) {
        debugLog("FileService copyFiles: \(copyparam.items.joined(separator: ", "))")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePostRequest(param: copyparam, handler: handler)
    }
    
    func delete(deleteFiles: DeleteFiles, success: FileOperation?, fail: FailResponse?) {
        debugLog("FileService deleteFiles: \(deleteFiles.items.joined(separator: ", "))")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
             success?()
        }, fail: fail)
        executeDeleteRequest(param: deleteFiles, handler: handler)
    }
    
    func moveToTrash(files: MoveToTrashFiles, success: FileOperation?, fail: FailResponse?) {
        debugLog("FileService deleteFiles: \(files.items.joined(separator: ", "))")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
             success?()
        }, fail: fail)
        executeDeleteRequest(param: files, handler: handler)
    }

    func createsFolder(createFolder: CreatesFolder, success: FolderOperation?, fail: FailResponse?) {
        debugLog("FileService createFolder \(createFolder.folderName)")
        
        let handler = BaseResponseHandler<CreateFolderResponse, ObjectRequestResponse>(success: { response  in
            let item = (response as? CreateFolderResponse)?.folder
            success?(item)
            ///used to be: success?()
        }, fail: fail)
        executePostRequest(param: createFolder, handler: handler)
    }
    
    func rename(rename: RenameFile, success: FileOperation?, fail: FailResponse?) {
        debugLog("FileService rename \(rename.newName)")
        
        let handler = BaseResponseHandler<SearchResponse, ObjectRequestResponse>(success: { _ in
            success?()
        }, fail: fail)
        executePostRequest(param: rename, handler: handler)
    }
    
    
    // MARK: download && upload
    
    private var error: ErrorResponse?
    
    private func showAccessAlert() {
        debugLog("CameraService showAccessAlert")
        DispatchQueue.main.async {
            let controller = PopUpController.with(title: TextConstants.cameraAccessAlertTitle,
                                                  message: TextConstants.cameraAccessAlertText,
                                                  image: .none,
                                                  firstButtonTitle: TextConstants.cameraAccessAlertNo,
                                                  secondButtonTitle: TextConstants.cameraAccessAlertGoToSettings,
                                                  secondAction: { vc in
                                                    vc.close {
                                                        UIApplication.shared.openSettings()
                                                    }
            })
            controller.open()
        }
    }
    
    func downloadDocument(items: [WrapData], success: FileOperation?, fail: FailResponse?) {
        guard !items.isEmpty else {
            return
        }
        
        downloadDocumentService.saveLocaly(remoteItems: items, onEachDownload: { [weak self] in
            guard let self = self else {
                success?()
                return
            }
            
            self.completedOperationsCount += 1
            CardsManager.default.setProgressForOperationWith(type: .download,
                                                             allOperations: self.allOperationsCount,
                                                             completedOperations: self.completedOperationsCount)
            
        }, onCompletion: { [weak self] isSaved, error in
            guard let self = self else {
                success?()
                return
            }
            
            if self.allOperationsCount == self.completedOperationsCount {
                self.trackDownloaded(lastQueueItems: items)
                CardsManager.default.stopOperationWith(type: .download)
                
                self.allOperationsCount = 0
                self.completedOperationsCount = 0
                
                if isSaved {
                    success?()
                } else if let error = error {
                    fail?(ErrorResponse.error(error))
                }
            }
        })
        
        allOperationsCount += items.count
        CardsManager.default.startOperationWith(type: .download,
                                                allOperations: allOperationsCount,
                                                completedOperations: completedOperationsCount)
        
    }

    
    func download(items: [WrapData], album: AlbumItem? = nil, success: FileOperation?, fail: FailResponse?) {
        debugLog("FileService download")
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            showAccessAlert()
            success?()
            return
        }
        let supportedItemsToDownload = items.filter { $0.hasSupportedExtension() }
        
        guard !supportedItemsToDownload.isEmpty else {
            fail?(ErrorResponse.string(TextConstants.errorUnsupportedExtension))
            return
        }
        
        if supportedItemsToDownload.count != items.count {
            UIApplication.showErrorAlert(message: TextConstants.errorUnsupportedExtension)
        }
        
        allOperationsCount = allOperationsCount + supportedItemsToDownload.count
        CardsManager.default.startOperationWith(type: .download, allOperations: allOperationsCount, completedOperations: 0)
        let downloadRequests: [BaseDownloadRequestParametrs] = supportedItemsToDownload.compactMap {
            guard let urlToFile = $0.urlToFile, let fileName = $0.name else {
                return nil
            }
            
            let url = urlToFile.isExpired ? urlToFile.byTrimmingQuery : urlToFile
            
            guard let downloadUrl = url else {
                return nil
            }
            
            return BaseDownloadRequestParametrs(urlToFile: downloadUrl, fileName: fileName, contentType: $0.fileType, albumName: album?.name, item: $0)
        }
        
        let operations = downloadRequests.compactMap { baseDownloadRequest in
            DownLoadOperation(downloadParam: baseDownloadRequest, success: { [weak self] in
                guard let `self` = self else {
                    return
                }
                if let unwrapItem = baseDownloadRequest.item {
                    switch unwrapItem.fileType {
                    case .video:
                        self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .download, eventLabel: .download(.video))
                    case .image:
                        self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .download, eventLabel: .download(.photo))
                    case .audio:
                        self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .download, eventLabel: .download(.music))
                    case .application(let applicationType):
                        switch applicationType {
                        case .pdf, .ppt, .xls, .txt, .doc, .pptx :
                           self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .download, eventLabel: .download(.document))
                        default:
                            break
                        }
                    default:
                        break
                    }
                }

                self.completedOperationsCount += 1
                CardsManager.default.setProgressForOperationWith(type: .download,
                                                                 allOperations: self.allOperationsCount,
                                                                 completedOperations: self.completedOperationsCount)
            }, fail: { [weak self] error in
                self?.error = error.isUnknownError ? ErrorResponse.string(TextConstants.errorUnsupportedExtension) : error
                /// HERE MUST BE ERROR HANDLER
                self?.completedOperationsCount += 1
            })
        }
        
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.downloadOperation.addOperations(operations, waitUntilFinished: true)
            
            if self.allOperationsCount == self.completedOperationsCount {
                self.trackDownloaded(lastQueueItems: items)
                CardsManager.default.stopOperationWith(type: .download)
            }
            
            if let error = self.error {
                fail?(error)
                self.error = nil
            } else {
                if self.allOperationsCount == self.completedOperationsCount {
                    self.allOperationsCount = 0
                    self.completedOperationsCount = 0
                    success?()
                }
            }
        }
    }
    
    func downloadToCameraRoll(downloadParam: BaseDownloadRequestParametrs, success: FileOperation?, fail: FailResponse?) {
        debugLog("FileService downloadToCameraRoll \(downloadParam.fileName)")
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            showAccessAlert()
            success?()
            return
        }
        executeDownloadRequest(param: downloadParam) { url, urlResponse, error in
            
            if let err = error {
                fail?(.error(err))
                return
            }

            if let httpResponse = urlResponse as? HTTPURLResponse,
                let location = url {
                if 199...299 ~= httpResponse.statusCode {
                    
                    let destination = Device.documentsFolderUrl(withComponent: downloadParam.fileName)
                    
                    let removeDestinationFile: () -> Void = {

                        do {
                            try FileManager.default.removeItem(at: destination)
                        } catch { }
                    }
                    
                    do {
                        try FileManager.default.moveItem(at: location, to: destination)
                    } catch {
                        
                        fail?(.string("Download move file error"))
                        return
                    }
                    
                    var type = PHAssetMediaType.unknown
                    
                    switch downloadParam.contentType {
                        case .image : type = .image
                        case .video : type = .video
                        default     : break
                    }
                    
                    if let downloadItem = downloadParam.item {
                        MediaItemOperationsService.shared.mediaItemByLocalID(trimmedLocalIDS: [downloadItem.getTrimmedLocalID()]) { mediaItems in
                            if !mediaItems.isEmpty {
                                removeDestinationFile()
                                success?()
                            } else {
                                LocalMediaStorage.default.appendToAlbum(fileUrl: destination,
                                                                         type: type,
                                                                         album: downloadParam.albumName,
                                                                         item: downloadParam.item,
                                                                         success: {
                                                                            removeDestinationFile()
                                                                            success?()
                                }, fail: { error in
                                    removeDestinationFile()
                                    fail?(error)
                                })
                            }
                        }
                        
                        ///For now we do not update local files by remotes
//                        CoreDataStack.shared.updateSavedItems(savedItems: [mediaItem],
//                                                               remoteItems: [item],
//                                                               context: CoreDataStack.shared.newChildBackgroundContext)
                        
                    } else {
                      fail?(.string("Incorrect response "))
                    }
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
    
    private func trackDownloaded(lastQueueItems: [Item]) {
        if self.allOperationsCount == self.completedOperationsCount {
            analyticsService.trackDimentionsEveryClickGA(screen: .allFiles, downloadsMetrics: lastQueueItems.count, uploadsMetrics: nil, isPaymentMethodNative: nil)
        }
    }
    
    func detail(uuids: String, success: FileOperation?, fail: FailResponse?) {
        let param = FileDetail(uuid: uuids)
        let handler = BaseResponseHandler<DetailResponse, ObjectRequestResponse>(success: {  detail  in
            print("s")
        }, fail: fail)
        executePutRequest(param: param,
                        handler: handler)
    }
    
    
    func updateDetail(uuids: String, success: UpdateFileOperation?, fail: FailResponse?) {
        let param = FileDetail(uuid: uuids)
        let handler = BaseResponseHandler<SearchItemResponse, ObjectRequestResponse>(success: {  detail  in
  
            guard let resultResponse = detail as? SearchItemResponse else {
                assertionFailure()
                let error = ErrorResponse.string("Unknown error")
                fail?(error)
                return
            }
            
            success?(WrapData(remote: resultResponse))
        
        }, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func details(uuids: [String], success: ListRemoteItems?, fail: FailResponse?) {
        
        let param = FileDetails(uuids: uuids)
        let handler = BaseResponseHandler<SearchResponse, ObjectRequestResponse>(success: { response in
            guard let resultResponse = (response as? SearchResponse)?.list else {
                let error = ErrorResponse.string("Unknown error")
                fail?(error)
                return
            }
            
            let list = resultResponse.compactMap { WrapData(remote: $0) }
//            CoreDataStack.shared.appendOnlyNewItems(items: list)
            success?(list)
        }, fail: fail)
        self.executePostRequest(param: param, handler: handler)
    }
    
    
    // Favourits && TAG
    
    func medaDataRequest(param: MetaDataFile, success: FileOperation?, fail: FailResponse?) {
        let handler = BaseResponseHandler<FileListResponse, ObjectRequestResponse>(success: { _ in
            success?()
        }, fail: fail)

        executePostRequest(param: param, handler: handler)
    }
    
    private var page = 0
    private let size = 100
    
    func filesList(rootFolder: String = "", sortBy: SortType, sortOrder: SortOrder,
                   folderOnly: Bool = false, remoteServicePage: Int, status: ItemStatus,
                   success: ListRemoteItems?, fail: FailRemoteItems?) {
        page = remoteServicePage
        let requestParam = FileList(rootDir: rootFolder,
                                    sortBy: sortBy,
                                    sortOrder: sortOrder,
                                    page: page,
                                    size: size,
                                    folderOnly: folderOnly,
                                    status: status)
        let handler = BaseResponseHandler<FileListResponse, ObjectRequestResponse>(success: { response in
            guard let resultResponse = (response as? FileListResponse)?.fileList else {
                fail?()
                return
            }
            success?(resultResponse)
        }, fail: { errorResponse in
            errorResponse.showInternetErrorGlobal()
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
    
    init(downloadParam: BaseDownloadRequestParametrs, success: FileOperation?, fail: FailResponse?) {
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
        SingletonStorage.shared.progressDelegates.add(self)
        FileService.shared.downloadToCameraRoll(downloadParam: param, success: {
            debugLog("FileService download \(self.param.fileName) success")
            self.customSuccess()
        }) { error in
            debugLog("FileService download \(self.param.fileName) fail: \(error.errorDescription ?? "")")
            self.customFail(error)
        }
        semaphore.wait()
        SingletonStorage.shared.progressDelegates.remove(self)
    }
    
    func customSuccess() {
        success?()
        semaphore.signal()
        if let item = param.item {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                ItemOperationManager.default.finishedDowloadFile(file: item)
            })
        }
    }
    
    func customFail(_ value: ErrorResponse) {
        fail?(value)
        semaphore.signal()
    }
}


extension DownLoadOperation: OperationProgressServiceDelegate {
    func didSend(ratio: Float, bytes: Int, for url: URL) {
        guard isExecuting else {
            return
        }
        
        if let item = param.item, param.urlToRemoteFile == url {
            CardsManager.default.setProgress(ratio: ratio, operationType: .download, object: item)
//            ItemOperationManager.default.setProgressForDownloadingFile(file: item, progress: ratio)
        }
    }
}
