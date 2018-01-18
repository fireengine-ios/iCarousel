//
//  Favourites.swift
//  Depo
//
//  Created by Alexander Gurin on 7/20/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

typealias ListRemoveItems = ( [WrapData] ) -> Void

typealias ListRemoveAlbums = ( [AlbumItem] ) -> Void

typealias FailRemoteItems = () -> Void


class RemoteItemsService {
    
    var requestSize: Int
    
    var currentPage: Int
    
    let contentType: SearchContentType
    
    var fieldValue : FieldValue
    
    let remote = SearchService()
    
    private let queueOperations: OperationQueue
    
    private var isFull = false
    
    init(requestSize:Int, fieldValue:FieldValue) {
        
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
    
    func reloadItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        log.debug("RemoteItemsService reloadItems")

        currentPage = 0
        isFull = false
        queueOperations.cancelAllOperations()
//        CoreDataStack.default.deleteRemoteFiles()
        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail, newFieldValue: newFieldValue)
    }
    
    func nextItems(fileType : FieldValue, sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems? ) {
        log.debug("RemoteItemsService nextItems")

        self.fieldValue = fileType
        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    
    func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        log.debug("RemoteItemsService nextItems")

        if let unwrapedFieldValue = newFieldValue {
            fieldValue = unwrapedFieldValue
        }
        
        let serchParam = SearchByFieldParameters(fieldName: contentType,
                                                 fieldValue: fieldValue,
                                                 sortBy: sortBy,
                                                 sortOrder: sortOrder,
                                                 page: currentPage,
                                                 size: requestSize)
        
        nextItems(with: serchParam, success: success, fail: fail)
    }
    
    func nextItemsMinified(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        log.debug("RemoteItemsService nextItemsMinified")

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
    
    
    fileprivate func nextItems(with searchParameters: SearchByFieldParameters, success: ListRemoveItems?, fail:FailRemoteItems?) {
        log.debug("RemoteItemsService nextItems")

        let executingOrWaitingOperations = queueOperations.operations.filter {
            ($0 as? NextPageOperation)?.requestParam == searchParameters
        }
        guard executingOrWaitingOperations.isEmpty else {
            return
        }
        
        let nextPageOperation = NextPageOperation(requestParam: searchParameters, success: { list in
            self.currentPage = self.currentPage + 1
            print("Current page \(self): \(self.currentPage)")
            log.debug("Current page \(self): \(self.currentPage)")
            success?(list)
        }, fail: fail)
        
        queueOperations.addOperation(nextPageOperation)
    }
    
    func getSuggestion(text: String, success: @escaping ([SuggestionObject]) -> Void, fail: @escaping FailResponse) {
        log.debug("RemoteItemsService getSuggestion")

        let parametrs = SuggestionParametrs(withText: text)
        remote.suggestion(param: parametrs, success: { suggestList in
            log.debug("RemoteItemsService getSuggestion SearchService suggestion success")

            success((suggestList as! SuggestionResponse).list)
        }) { (error) in
            log.debug("RemoteItemsService getSuggestion SearchService suggestion fail")

            fail(error)
        }
    }
    
    func stopAllOperations() {
        queueOperations.cancelAllOperations()
    }
}

class NextPageOperation: Operation {
    
    let searchService: SearchService
    
    let requestParam: SearchByFieldParameters
    
    let success: ListRemoveItems?
    
    let fail:FailRemoteItems?
    
    var isRealCancel = false
    
    override func cancel() {
        isRealCancel = true
    }
    
    init(requestParam: SearchByFieldParameters, success:ListRemoveItems?, fail:FailRemoteItems?) {
        self.searchService = SearchService()
        self.requestParam = requestParam
        self.fail = fail
        self.success = success
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        let semaphore = DispatchSemaphore(value: 0)
        searchService.searchByField(param: requestParam, success: { [weak self] (response)  in
            
            guard let `self` = self else {
                return
            }
            
            if self.isRealCancel {
                self.fail?()
                semaphore.signal()
                return
            }
            
            guard let resultResponse = (response as? SearchResponse)?.list else {
                self.fail?()
                semaphore.signal()
                return
            }
            
            let list = resultResponse.flatMap { WrapData(remote: $0) }
            self.success?(list)
            semaphore.signal()
            
        }, fail: { [weak self]_ in
            self?.fail?()
            semaphore.signal()
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
    
    init(requestSize: Int, type:FieldValue = .imageAndVideo) {
        super.init(requestSize: requestSize, fieldValue: type)
    }
}

class LocalPhotoAndVideoService: RemoteItemsService {
    
    let localFileManager = FilesDataSource()
    
    init(type:FieldValue = .imageAndVideo) {
        super.init(requestSize: 100, fieldValue: type)
    }
    
//     func allItems(sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoveItems, fail:@escaping FailRemoteItems) {
//
//    }
}

class DocumentService: RemoteItemsService {
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .document)
    }
//    func allItems(sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoveItems, fail:@escaping FailRemoteItems) {
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
    
    func allStories(sortBy: SortType = .date, sortOrder: SortOrder = .desc, success: ListRemoveItems?, fail: FailRemoteItems?) {
        currentPage = 0
        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail: FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        log.debug("StoryService nextItems")
        
        let searchParam = SearchByFieldParameters(fieldName: .story,
                                                  fieldValue: .story,
                                                  sortBy: sortBy,
                                                  sortOrder: sortOrder,
                                                  page: currentPage,
                                                  size: requestSize)
                
        remote.searchByField(param: searchParam, success: { [weak self] response in
            guard let resultResponse = response as? SearchResponse else {
                log.debug("StoryService remote searchStories fail")
                fail?()
                return
            }
            
            log.debug("StoryService remote searchStories success")
            
            self?.currentPage += 1
            let list = resultResponse.list.flatMap{ Item(remote: $0) }
            success?(list)
            }, fail: { _ in
                    log.debug("StoryService remote searchStories fail")
    
                    fail?()
            })
    }
}

class FolderService: RemoteItemsService {
    
    let rootFolder: String
    let fileService = FileService()

    var foldersOnly: Bool
    
    init(requestSize: Int, rootFolder: String = "", onlyFolders: Bool = false) {
        self.foldersOnly = onlyFolders
        self.rootFolder = rootFolder
        super.init(requestSize: requestSize, fieldValue: .document)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        log.debug("FilesFromFolderService nextItems")

        fileService.filesList(rootFolder: rootFolder, sortBy: sortBy, sortOrder: sortOrder,
                              folderOnly: foldersOnly, remoteServicePage: currentPage,
                              success: success, fail: fail)
        currentPage += 1
    }
}

class FilesFromFolderService: RemoteItemsService {
    
    let rootFolder: String
    let fileService = FileService()
    
    init(requestSize: Int, rootFolder: String = "") {
        self.rootFolder = rootFolder
        super.init(requestSize: requestSize, fieldValue: .document)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        log.debug("AllFilesService nextItems")

        fileService.filesList(rootFolder: rootFolder, sortBy: sortBy, sortOrder: sortOrder, remoteServicePage: currentPage, success: success, fail: fail)
        currentPage += 1
    }
}

class AllFilesService: RemoteItemsService {
    
    let fileService = FileService()
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .imageAndVideo)
    }
    
    override func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail:FailRemoteItems?, newFieldValue: FieldValue? = nil) {
        fileService.filesList(sortBy: sortBy, sortOrder: sortOrder, remoteServicePage: currentPage, success: success, fail: fail)
        currentPage += 1
    }
}

class FacedRemoteItemsService {
    
    let fetchService: FetchService
    
    let remoteService: RemoteItemsService
        
    init(remoteService: RemoteItemsService) {
        self.remoteService = remoteService
        self.fetchService = FetchService(batchSize: 140)
    }
    
    func nextItems(sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail: FailRemoteItems?) {
        log.debug("FacedRemoteItemsService nextItems")

        remoteService.nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    func performFetch(sortingRules: SortedRules, filtes: [MoreActionsConfig.MoreActionsFileType]?) {
//        var resultFilters = filtes
//        fetchService.performFetch(sortingRules: sortingRules, filtes: resultFilters)
    }
}
