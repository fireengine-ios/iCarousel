//
//  Favourites.swift
//  Depo
//
//  Created by Alexander Gurin on 7/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

typealias ListRemoteItems = ( [WrapData] ) -> Void

typealias ListRemoteAlbums = ( [AlbumItem] ) -> Void

typealias AlbumCoverPhoto = ( Item ) -> Void

typealias FailRemoteItems = VoidHandler


class RemoteItemsService {
    
    var requestSize: Int
    
    var currentPage: Int
    
    let contentType: SearchContentType
    
    var fieldValue: FieldValue
    
    let remote = SearchService(transIdLogging: true)
    
    private let queueOperations: OperationQueue
    
    private var isFull = false
    
    init(requestSize: Int, fieldValue: FieldValue) {
        
        switch fieldValue {
            case .favorite:
                contentType = .favorite
            case .cropy:
                contentType = .cropy
            case .albums:
                contentType = .album
            case .story:
                contentType = .story
            default:
                contentType = .content_type
        }
        
        self.fieldValue = fieldValue
        self.requestSize = requestSize
        currentPage = 0
        queueOperations = OperationQueue()
        queueOperations.maxConcurrentOperationCount = 1
    }
    
    func reloadItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("RemoteItemsService reloadItems")

        currentPage = 0
        isFull = false
        queueOperations.cancelAllOperations()
        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail, newFieldValue: newFieldValue)
    }
    
    func reloadUnhiddenItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("RemoteItemsService reloadUnhiddenItems")

        currentPage = 0
        isFull = false
        queueOperations.cancelAllOperations()
        nextUnhiddenItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail, newFieldValue: newFieldValue)
    }
    
    func nextUnhiddenItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("RemoteItemsService nextUnhiddenItems")
        if let unwrapedFieldValue = newFieldValue {
            fieldValue = unwrapedFieldValue
        }
        
        let serchParam = SearchByFieldParameters(fieldName: contentType,
                                                 fieldValue: fieldValue,
                                                 sortBy: sortBy,
                                                 sortOrder: sortOrder,
                                                 page: currentPage,
                                                 size: requestSize,
                                                 hidden: false)
        
        nextItems(with: serchParam, success: success, fail: fail)
    }
    
    func nextItems(fileType: FieldValue, sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems? ) {
        debugLog("RemoteItemsService nextItems")

        self.fieldValue = fileType
        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
        
    func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("RemoteItemsService nextItems")
        if let unwrapedFieldValue = newFieldValue {
            fieldValue = unwrapedFieldValue
        }
        
        let serchParam = SearchByFieldParameters(fieldName: contentType,
                                                 fieldValue: fieldValue,
                                                 sortBy: sortBy,
                                                 sortOrder: sortOrder,
                                                 page: currentPage,
                                                 size: requestSize,
                                                 hidden: true)
        
        nextItems(with: serchParam, success: success, fail: fail)
    }
    
    func nextItemsMinified(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("RemoteItemsService nextItemsMinified")

        if let unwrapedFieldValue = newFieldValue {
            fieldValue = unwrapedFieldValue
        }
        
        let serchParam = SearchByFieldParameters(fieldName: contentType,
                                                 fieldValue: fieldValue,
                                                 sortBy: sortBy,
                                                 sortOrder: sortOrder,
                                                 page: currentPage,
                                                 size: requestSize,
                                                 minified: true)
        
        nextItems(with: serchParam, success: success, fail: fail)
    }
    
    func cancellAllRequests() {
        queueOperations.cancelAllOperations()
    }
    
    fileprivate func nextItems(with searchParameters: SearchByFieldParameters, success: ListRemoteItems?, fail: FailRemoteItems?) {
        debugLog("RemoteItemsService nextItems")

        let executingOrWaitingOperations = queueOperations.operations.filter {
            ($0 as? NextPageOperation)?.requestParam == searchParameters
        }
        guard executingOrWaitingOperations.isEmpty else {
            return
        }
        
        let nextPageOperation = NextPageOperation(requestParam: searchParameters, success: { list in
            self.currentPage += 1
            print("Current page \(self): \(self.currentPage)")
            debugLog("Current page \(self): \(self.currentPage)")
            success?(list)
        }, fail: fail)
        
        queueOperations.addOperation(nextPageOperation)
    }
    
    func getSuggestion(text: String, success: @escaping ([SuggestionObject]) -> Void, fail: @escaping FailResponse) {
        debugLog("RemoteItemsService getSuggestion")

        let parametrs = SuggestionParametrs(withText: text)
        remote.suggestion(param: parametrs, success: { [weak self] response in
            debugLog("RemoteItemsService getSuggestion SearchService suggestion success")
            guard let suggestionResponse = response as? SuggestionResponse else {
                fail(ErrorResponse.failResponse(response))
                return
            }
            
            success(suggestionResponse.list)
            self?.remote.debugLogTransIdIfNeeded(headers: suggestionResponse.response?.allHeaderFields, method: "getSuggestion")
        }, fail: { [weak self] errorResponse in
            errorResponse.showInternetErrorGlobal()
            debugLog("RemoteItemsService getSuggestion SearchService suggestion fail")

            fail(errorResponse)
            
            self?.remote.debugLogTransIdIfNeeded(errorResponse: errorResponse, method: "getSuggestion")
        })
    }
    
    func stopAllOperations() {
        queueOperations.cancelAllOperations()
    }
}

final class NextPageOperation: Operation {
    
    private var requestTask: URLSessionTask?
    private let searchService: SearchService
    
    let requestParam: SearchByFieldParameters
    
    private let success: ListRemoteItems?
    private let fail: FailRemoteItems?
    private let semaphore = DispatchSemaphore(value: 0)

    
    init(requestParam: SearchByFieldParameters, success: ListRemoteItems?, fail: FailRemoteItems?) {
        self.searchService = SearchService(transIdLogging: true)
        self.requestParam = requestParam
        self.fail = fail
        self.success = success
    }
    
    override func cancel() {
        super.cancel()
        
        requestTask?.cancel()
        
        semaphore.signal()
    }
    
    override func main() {
        requestTask = searchService.searchByField(param: requestParam, success: { [weak self] response  in
            DispatchQueue.toBackground { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                guard let resultResponse = (response as? SearchResponse)?.list else {
                    self.fail?()
                    self.semaphore.signal()
                    return
                }
                
                guard self.isExecuting else {
                    self.success?([])
                    self.semaphore.signal()
                    return
                }
                
                let list = resultResponse.compactMap { WrapData(remote: $0) }
                self.success?(list)
                
                self.searchService.debugLogTransIdIfNeeded(headers: (response as? SearchResponse)?.response?.allHeaderFields, method: "searchByField")
                
                self.semaphore.signal()
            }
        }, fail: { [weak self] errorResponse in
            
            /// temp error handling
            if UIApplication.topController() is FloatingContainerVC {
                UIApplication.showOnTabBar(errorMessage: errorResponse.description)
            } else {
                errorResponse.showInternetErrorGlobal()
            }
            
            self?.fail?()
            
            self?.searchService.debugLogTransIdIfNeeded(errorResponse: errorResponse, method: "searchByField")

            self?.semaphore.signal()
        })
        semaphore.wait()
    }
}


class MusicService: RemoteItemsService {
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .audio)
    }
}


class PhotoAndVideoService: RemoteItemsService {
    
    let localFileManager = FilesDataSource()
    
    init(requestSize: Int, type: FieldValue = .imageAndVideo) {
        super.init(requestSize: requestSize, fieldValue: type)
    }
}

class LocalPhotoAndVideoService: RemoteItemsService {
    
    let localFileManager = FilesDataSource()
    
    init(type: FieldValue = .imageAndVideo) {
        super.init(requestSize: 100, fieldValue: type)
    }
    
//     func allItems(sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoteItems, fail:@escaping FailRemoteItems) {
//
//    }
}

class DocumentService: RemoteItemsService {
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .document)
    }
//    func allItems(sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoteItems, fail:@escaping FailRemoteItems) {
//        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
//    }
}


class FavouritesService: RemoteItemsService {
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .favorite)
    }
}

class StoryService: RemoteItemsService {
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .story)
    }
    
    func allStories(sortBy: SortType = .date, sortOrder: SortOrder = .desc, success: ListRemoteItems?, fail: FailRemoteItems?) {
        currentPage = 0
        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("StoryService nextItems")
        
        let searchParam = SearchByFieldParameters(fieldName: .story,
                                                  fieldValue: .story,
                                                  sortBy: sortBy,
                                                  sortOrder: sortOrder,
                                                  page: currentPage,
                                                  size: requestSize,
                                                  hidden: false)
                
        remote.searchByField(param: searchParam, success: { [weak self] response in
            guard let resultResponse = response as? SearchResponse else {
                debugLog("StoryService remote searchStories fail")
                fail?()
                return
            }
            
            debugLog("StoryService remote searchStories success")
            
            self?.currentPage += 1
            let list = resultResponse.list.flatMap { Item(remote: $0) }
            success?(list)
            
            self?.remote.debugLogTransIdIfNeeded(headers: resultResponse.response?.allHeaderFields, method: "search")
        }, fail: { [weak self] errorResponse in
            errorResponse.showInternetErrorGlobal()
            debugLog("StoryService remote searchStories fail")
            fail?()
            
            self?.remote.debugLogTransIdIfNeeded(errorResponse: errorResponse, method: "search")
        })
    }
}

class FolderService: RemoteItemsService {
    
    let rootFolder: String
    let fileService = FileService.shared

    var foldersOnly: Bool
    
    init(requestSize: Int, rootFolder: String = "", onlyFolders: Bool = false) {
        self.foldersOnly = onlyFolders
        self.rootFolder = rootFolder
        super.init(requestSize: requestSize, fieldValue: .document)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("FolderService nextItems")

        fileService.filesList(rootFolder: rootFolder, sortBy: sortBy, sortOrder: sortOrder,
                              folderOnly: foldersOnly, remoteServicePage: currentPage, status: .active,
                              success: success, fail: fail)
        currentPage += 1
    }
}

class FilesFromFolderService: RemoteItemsService {
    
    let rootFolder: String
    let fileService = FileService.shared
    let status: ItemStatus
    
    init(requestSize: Int, rootFolder: String = "", status: ItemStatus) {
        self.rootFolder = rootFolder
        self.status = status
        super.init(requestSize: requestSize, fieldValue: .document)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("FilesFromFolderService nextItems")

        fileService.filesList(rootFolder: rootFolder, sortBy: sortBy, sortOrder: sortOrder,
                              remoteServicePage: currentPage, status: status,
                              success: success, fail: fail)
        currentPage += 1
    }
}

class AllFilesService: RemoteItemsService {
    
    let fileService = FileService.shared
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .imageAndVideo)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        debugLog("AllFilesService nextItems")
        
        fileService.filesList(sortBy: sortBy, sortOrder: sortOrder, remoteServicePage: currentPage, status: .active, success: success, fail: fail)
        currentPage += 1
    }
}

class FaceImageDetailService: AlbumDetailService {
    let albumUUID: String
    
    init(albumUUID: String, requestSize: Int) {
        self.albumUUID = albumUUID
        super.init(requestSize: requestSize)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?, newFieldValue: FieldValue?) {
        nextItems(albumUUID: albumUUID, sortBy: sortBy, sortOrder: sortOrder, success: { items in
            success?(items)

        }, fail: fail)
    }

}
