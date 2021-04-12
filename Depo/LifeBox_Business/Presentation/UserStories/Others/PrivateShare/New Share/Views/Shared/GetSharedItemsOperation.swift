//
//  GetSharedItemsOperation.swift
//  Depo
//
//  Created by Konstantin Studilin on 15.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

typealias GetSharedItemsOperationCallBack = ValueHandler<((SharedFileInfo?, [WrapData], searchItemsTotalFounnd: Int?, Bool))>

final class GetSharedItemsOperation: Operation {
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private let privateShareAPIService: PrivateShareApiService
    
    private let type: PrivateShareType
    private let page: Int
    private let size: Int
    private let sortBy: SortType
    private let sortOrder: SortOrder
    private let completion: GetSharedItemsOperationCallBack
    
    private var task: URLSessionTask?
    private var loadedItems = [WrapData]()
    private var rootFolder: SharedFileInfo?
    private var isRequestFinished = false
    
    private var searchItemsFoundInTotal: Int?
    
    init(service: PrivateShareApiService, type: PrivateShareType, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, completion: @escaping GetSharedItemsOperationCallBack) {
        self.type = type
        self.privateShareAPIService = service
        self.completion = completion
        self.page = page
        self.size = size
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
    
    override func cancel() {
        super.cancel()
        
        task?.cancel()
        
        semaphore.signal()
    }
    
    override func main() {
        load()
        
        semaphore.wait()
        
        completion((rootFolder, loadedItems, searchItemsFoundInTotal, isRequestFinished))
    }
    
    private func load() {
        loadPage { [weak self] result in
            guard let self = self, !self.isCancelled else {
                return
            }
            
            self.isRequestFinished = true
            
            switch result {
                case .success(let filesInfo):
                    self.loadedItems = filesInfo.compactMap { WrapData(privateShareFileInfo: $0, shareType: self.type) }
                    self.semaphore.signal()
                    
                case .failed(_):
                    self.semaphore.signal()
            }
        }
    }
    
    private func loadPage(completion : @escaping ResponseArrayHandler<SharedFileInfo>) {
        switch type {
        case .myDisk:
            let accountUuid = SingletonStorage.shared.accountInfo?.uuid ?? ""
            let rootFolderUuid = ""
            task = privateShareAPIService.getFiles(projectId: accountUuid, folderUUID: rootFolderUuid, size: size, page: page, sortBy: sortBy, sortOrder: sortOrder) { [weak self] response in
                switch response {
                case .success(let fileSystem):
                    self?.rootFolder = fileSystem.parentFolderList.first(where: { $0.id == 0 })
                    completion(.success(fileSystem.fileList))
                case .failed(let error):
                    completion(.failed(error))
                }
            }
            
        case .sharedArea:
            let accountUuid = SingletonStorage.shared.accountInfo?.parentAccountInfo.uuid ?? ""
            let rootFolderUuid = ""
            task = privateShareAPIService.getFiles(projectId: accountUuid, folderUUID: rootFolderUuid, size: size, page: page, sortBy: sortBy, sortOrder: sortOrder) { [weak self] response in
                switch response {
                case .success(let fileSystem):
                    self?.rootFolder = fileSystem.parentFolderList.first(where: { $0.id == 0 })
                    completion(.success(fileSystem.fileList))
                case .failed(let error):
                    completion(.failed(error))
                }
            }
            
        case .byMe:
            task = privateShareAPIService.getSharedByMe(size: size, page: page, sortBy: sortBy, sortOrder: sortOrder, handler: completion)
            
        case .withMe:
            task = privateShareAPIService.getSharedWithMe(size: size, page: page, sortBy: sortBy, sortOrder: sortOrder, handler: completion)
            
        case .innerFolder(let type, let folder):
            switch type {
            case .trashBin:
                task = privateShareAPIService.trashedList(folderUUID: folder.uuid, sortBy: sortBy, sortOrder: sortOrder, page: page, size: size) { response in
                    switch response {
                    case .success(let fileSystem):
                        completion(.success(fileSystem.fileList))
                    case .failed(let error):
                        completion(.failed(error))
                    }
                }
            default:
                task = privateShareAPIService.getFiles(projectId: folder.accountUuid, folderUUID: folder.uuid, size: size, page: page, sortBy: sortBy, sortOrder: sortOrder) { response in
                    switch response {
                    case .success(let fileSystem):
                        completion(.success(fileSystem.fileList))
                    case .failed(let error):
                        completion(.failed(error))
                    }
                }
            }
        case .trashBin:
            task = privateShareAPIService.trashedList(folderUUID: "", sortBy: sortBy, sortOrder: sortOrder, page: page, size: size) { response in
                switch response {
                case .success(let fileSystem):
                    completion(.success(fileSystem.fileList))
                case .failed(let error):
                    completion(.failed(error))
                }
            }
            
        case .search(from: let rootType, let searchText):
            guard let diskType = rootType.searchDiskType else {
                task = nil
                completion(.failed(CustomErrors.text("unable to get disk type")))
                assertionFailure("disk type should be available for MyDisk and SharedArea only as of now")
                return
            }
            
            task = privateShareAPIService.search(text: searchText, diskType: diskType, page: page, size: size) { [weak self] searchResponnse in
                switch searchResponnse {
                case .success(let successSearchResponse):
                    self?.searchItemsFoundInTotal = successSearchResponse.foundItemsCount.allFiles
                    completion(.success(successSearchResponse.foundItems))
                case .failed(let error):
                    completion(.failed(error))
                }
            }
            
        }
    }
}
