//
//  PrivateShareFileInfoManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 10.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


indirect enum PrivateShareType: Equatable {
    case byMe
    case withMe
    case innerFolder(type: PrivateShareType, folderItem: PrivateSharedFolderItem)
    
    var rootType: PrivateShareType {
        return veryRootType(for: self)
    }
    
    var emptyViewType: EmptyView.ViewType {
        switch self {
            case .byMe:
                return .sharedBy
            case .withMe:
                return .sharedWith
            case .innerFolder:
                return .sharedInnerFolder
        }
    }
    
    //isSelectionAllowed is predefined by the veryRootType only
    var isSelectionAllowed: Bool {
        switch self {
            case .byMe:
                return true
                
            case .withMe:
                return false
                
            case .innerFolder:
                return veryRootType(for: self).isSelectionAllowed
        }
    }
    
    //floatingButtonTypes is predefined by the veryRootType + type itself
    var floatingButtonTypes: [FloatingButtonsType] {
        let typeAndRoot = (self, veryRootType(for: self))
        
        switch typeAndRoot {
            case (.byMe, _):
                return []
                
            case (.withMe, _):
                return []
                
            case (.innerFolder(_, let folder), let veryRootType):
                return floatingButtonTypes(innerFolderVeryRootType: veryRootType, permissions: folder.permissions.granted ?? [])
        }
    }
    
    private func floatingButtonTypes(innerFolderVeryRootType: PrivateShareType, permissions: [PrivateSharePermission]) -> [FloatingButtonsType] {
        switch innerFolderVeryRootType {
            case .byMe:
                return [.newFolder, .upload, .uploadFiles]
                
            case .withMe:
                if permissions.contains(.create) {
                    return [.newFolder, .upload, .uploadFiles]
                }
                return []
                
            case .innerFolder:
                assertionFailure("should not be the case, innerFolderVeryRootType must not be the innerFolder")
                return []
        }
    }
    
    private func veryRootType(for type: PrivateShareType) -> PrivateShareType {
        switch type {
            case .byMe, .withMe:
                return type
                
            case .innerFolder(type: let rootType, _):
                return veryRootType(for: rootType)
        }
    }
}


final class PrivateShareFileInfoManager {
    
    static func with(type: PrivateShareType, privateShareAPIService: PrivateShareApiService) -> PrivateShareFileInfoManager {
        let service = PrivateShareFileInfoManager()
        service.type = type
        service.privateShareAPIService = privateShareAPIService
        return service
    }
    
    private let queue = DispatchQueue(label: DispatchQueueLabels.privateShareFileInfoManagerQueue)
    private var privateShareAPIService: PrivateShareApiService!
    private let pageSize = Device.isIpad ? 64 : 32
    private var pagesLoaded = 0
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    private(set) var sorting: SortedRules = .timeUp
    private(set) var type: PrivateShareType = .byMe
    private(set) var sortedItems = SynchronizedArray<WrapData>()
    private(set) var selectedItems = SynchronizedSet<WrapData>()
    private(set) var splittedItems = SynchronizedArray<[WrapData]>()
    
    private var tempLoaded = [WrapData]()
    
    //MARK: - Life cycle
    
    private init() { }
    
    //MARK: - Public
    
    func loadNextPage(completion: @escaping ValueHandler<Bool>) {
        guard operationQueue.operations.filter({ !$0.isCancelled }).count == 0 else {
            completion(false)
            return
        }
        
        let operation = GetSharedItemsOperation(service: privateShareAPIService, type: type, size: pageSize, page: pagesLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder) { [weak self] (loadedItems, isFinished) in
            
            guard let self = self, isFinished, !loadedItems.isEmpty else {
                completion(false)
                return
            }
            
            self.pagesLoaded += 1
            
            let sorted = self.sortedItems.getArray() + self.sorted(items: loadedItems)
            self.sortedItems.replace(with: sorted, completion: nil)
            
            let splitted = self.splitted(sortedArray: sorted)
            
            self.splittedItems.replace(with: splitted) {
                completion(true)
            }
        }
        
        operationQueue.addOperation(operation)
    }
    
    func reload(completion: @escaping ValueHandler<Bool>) {
        queue.sync {
            operationQueue.cancelAllOperations()
            
            selectedItems.removeAll()
            pagesLoaded = 0
            
            let operation = GetSharedItemsOperation(service: privateShareAPIService, type: type, size: pageSize, page: pagesLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder) { [weak self] (loadedItems, isFinished) in
                
                guard let self = self, isFinished else {
                    completion(false)
                    return
                }
                
                guard !loadedItems.isEmpty else {
                    self.cleanAll()
                    completion(true)
                    return
                }
                
                self.pagesLoaded += 1
                
                let sorted = self.sorted(items: loadedItems)
                self.sortedItems.replace(with: sorted, completion: nil)
                
                let splitted = self.splitted(sortedArray: sorted)
                
                self.splittedItems.replace(with: splitted) {
                    completion(true)
                }
            }
            
            operationQueue.addOperation(operation)
        }
    }
    
    func reloadCurrentPages(completion: @escaping ValueHandler<Bool>) {
         guard pagesLoaded > 0 else {
            reload(completion: completion)
            return
        }
        
        queue.sync {
            operationQueue.cancelAllOperations()
            let pagesToLoad = pagesLoaded
            
            tempLoaded.removeAll()
            pagesLoaded = 0
            
            loadPages(till: pagesToLoad, completion: completion)
        }
    }
    
    func change(sortingRules: SortedRules, completion: @escaping VoidHandler) {
        guard sorting != sortingRules else {
            return
        }
        
        sorting = sortingRules
        
        let changedSorted = sorted(items: sortedItems.getArray())
        sortedItems.replace(with: changedSorted, completion: nil)
        
        let changedSplitted = splitted(sortedArray: changedSorted)
        
        splittedItems.replace(with: changedSplitted) {
            completion()
        }
    }
    
    func selectItem(at indexPath: IndexPath) {
        if let item = splittedItems[indexPath.section]?[safe:indexPath.row] {
            if let alreadySelected = selectedItems.getSet().first(where: { $0.uuid == item.uuid }) {
                selectedItems.remove(alreadySelected)
            }
            selectedItems.insert(item)
        }
    }
    
    func deselectItem(at indexPath: IndexPath) {
        if let item = splittedItems[indexPath.section]?[safe:indexPath.row] {
            selectedItems.remove(item)
        }
    }
    
    func deselectAll() {
        selectedItems.removeAll()
    }
    
    func delete(uuids: [String], completion: @escaping VoidHandler) {
        guard !uuids.isEmpty else {
            return
        }
        
        let changedSorted = sortedItems.filter { !$0.uuid.isContained(in: uuids) }
        
        sortedItems.replace(with: changedSorted, completion: nil)
        
        let changedSplitted = splitted(sortedArray: changedSorted)
        
        splittedItems.replace(with: changedSplitted, completion: completion)
    }
    
    func createDownloadUrl(item: WrapData, completion: @escaping ValueHandler<URL?>) {
        guard let projectId = item.projectId else {
            completion(nil)
            return
        }
        
        privateShareAPIService.createDownloadUrl(projectId: projectId, uuid: item.uuid) { response in
            switch response {
                case .success(let urlWrapper):
                    completion(urlWrapper.url)
                    
                case .failed(_):
                    completion(nil)
            }
        }
    }
    
    //MARK: - Private
    
    private func cleanAll() {
        selectedItems.removeAll()
        sortedItems.removeAll()
        splittedItems.removeAll()
    }
    
    private func loadPages(till page: Int, completion: @escaping ValueHandler<Bool>) {
        let operation = GetSharedItemsOperation(service: privateShareAPIService, type: type, size: pageSize, page: pagesLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder) { [weak self] (loadedItems, isFinished) in
            
            guard let self = self, isFinished else {
                completion(false)
                return
            }
            
            self.tempLoaded.append(contentsOf: self.sorted(items: loadedItems))
            self.pagesLoaded += 1
            
            guard self.pagesLoaded < page, !loadedItems.isEmpty else {
                let sorted = self.sorted(items: self.tempLoaded)
                self.sortedItems.replace(with: sorted, completion: nil)
                
                let splitted = self.splitted(sortedArray: sorted)
                
                self.splittedItems.replace(with: splitted) {
                    completion(true)
                }
                
                return
            }
            
            self.loadPages(till: page, completion: completion)
        }
        
        operationQueue.addOperation(operation)
    }
    
    private func sorted(items: [WrapData]) -> [WrapData] {
        return WrapDataSorting.sort(items: items, sortType: sorting)
    }
    
    private func splitted(sortedArray: [WrapData]) -> [[WrapData]]  {
        let grouped: [String : [WrapData]]
        switch sorting {
        case .timeUp, .timeUpWithoutSection, .lastModifiedTimeUp, .timeDown, .timeDownWithoutSection, .lastModifiedTimeDown:
            grouped = Dictionary(grouping: sortedArray, by: { $0.creationDate?.getDateForSortingOfCollectionView() ?? Date().getDateForSortingOfCollectionView()
            })
            
        case .lettersAZ, .albumlettersAZ, .lettersZA, .albumlettersZA:
            grouped = Dictionary(grouping: sortedArray, by: { $0.name?.firstLetter ?? "" })
            
        case .sizeAZ, .sizeZA:
            grouped = ["plain" : sortedArray]//Dictionary(grouping: sortedArray, by: { $0.fileSize.bytesString })
            
        case .metaDataTimeUp, .metaDataTimeDown:
            grouped = Dictionary(grouping: sortedArray, by: { $0.creationDate?.getDateForSortingOfCollectionView() ?? Date().getDateForSortingOfCollectionView()
            })
        }
        
        let splitted: [[WrapData]] = grouped.sorted(by: { sorting.sortOder == .asc ? ($0.0 < $1.0) : ($0.0 > $1.0) }).compactMap { $0.value }
        
        return splitted
    }
}


final class GetSharedItemsOperation: Operation {
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    private let privateShareAPIService: PrivateShareApiService
    
    private let type: PrivateShareType
    private let page: Int
    private let size: Int
    private let sortBy: SortType
    private let sortOrder: SortOrder
    private let completion: ValueHandler<(([WrapData], Bool))>
    
    private var task: URLSessionTask?
    private var loadedItems = [WrapData]()
    private var isRequestFinished = false
    
    init(service: PrivateShareApiService, type: PrivateShareType, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, completion: @escaping ValueHandler<([WrapData], Bool)>) {
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
        
        completion((loadedItems, isRequestFinished))
    }
    
    private func load() {
        loadPage { [weak self] result in
            guard let self = self, !self.isCancelled else {
                return
            }
            
            self.isRequestFinished = true
            
            switch result {
                case .success(let filesInfo):
                    self.loadedItems = filesInfo.compactMap { WrapData(privateShareFileInfo: $0) }
                    self.semaphore.signal()
                    
                case .failed(_):
                    self.semaphore.signal()
            }
        }
    }
    
    private func loadPage(completion : @escaping ResponseArrayHandler<SharedFileInfo>) {
        switch type {
            case .byMe:
                task = privateShareAPIService.getSharedByMe(size: size, page: page, sortBy: sortBy, sortOrder: sortOrder, handler: completion)
                
            case .withMe:
                task = privateShareAPIService.getSharedWithMe(size: size, page: page, sortBy: sortBy, sortOrder: sortOrder, handler: completion)
                
            case .innerFolder(_, let folder):
                task = privateShareAPIService.getFiles(projectId: folder.projectId, folderUUID: folder.uuid, size: size, page: page, sortBy: sortBy, sortOrder: sortOrder) { response in
                    switch response {
                        case .success(let fileSystem):
                            completion(.success(fileSystem.fileList))
                        case .failed(let error):
                            completion(.failed(error))
                    }
                }
        }
    }
}
