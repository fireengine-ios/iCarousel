//
//  PrivateShareFileInfoManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 10.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

typealias DeltaIndexes = (inserted: [Int], deleted: [Int])
typealias ReloadCompletionHandler = ValueHandler<(reloadRequired: Bool, deltaIndexes: DeltaIndexes?)>

final class PrivateShareFileInfoManager {
    
    static func with(type: PrivateShareType, privateShareAPIService: PrivateShareApiService) -> PrivateShareFileInfoManager {
        let service = PrivateShareFileInfoManager()
        service.type = type
        service.privateShareAPIService = privateShareAPIService
        return service
    }
    
    private(set) var isNextPageLoading = false
    
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
    
    private(set) var rootFolder: SharedFileInfo?
    
    private var tempLoaded = [WrapData]()
    
    //MARK: - Life cycle
    
    private init() { }
    
    //MARK: - Public
    
    func loadNextPage(completion: @escaping ReloadCompletionHandler) {
        guard operationQueue.operations.filter({ !$0.isCancelled }).count == 0 else {
            completion((false, nil))
            return
        }
        
        isNextPageLoading = true
        let operation = GetSharedItemsOperation(service: privateShareAPIService, type: type, size: pageSize, page: pagesLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder) { [weak self] (_, loadedItems, isFinished) in
            
            guard let self = self else {
                completion((false, nil))
                return
            }
            
            guard isFinished, !loadedItems.isEmpty else {
                self.isNextPageLoading = false
                completion((false, nil))
                return
            }
            
            self.pagesLoaded += 1
            
            let sorted = self.sortedItems.getArray() + self.sorted(items: loadedItems)
            let indexes = self.getDeltaIndexes(objects: sorted)
            self.sortedItems.replace(with: sorted) { [weak self] in
                self?.queue.async {
                    self?.isNextPageLoading = false
                    completion((true, indexes))
                }
            }
        }
        
        operationQueue.addOperation(operation)
    }
    
    func reload(completion: @escaping ReloadCompletionHandler) {
        queue.sync {
            operationQueue.cancelAllOperations()
            
            selectedItems.removeAll()
            pagesLoaded = 0
            
            let operation = GetSharedItemsOperation(service: privateShareAPIService, type: type, size: pageSize, page: pagesLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder) { [weak self] rootFolder, loadedItems, isFinished in
                
                self?.rootFolder = rootFolder
                
                guard let self = self, isFinished else {
                    completion((false, nil))
                    return
                }
                
                guard !loadedItems.isEmpty else {
                    self.cleanAll()
                    completion((true, nil))
                    return
                }
                
                self.pagesLoaded += 1
                
                let sorted = self.sorted(items: loadedItems)
                let indexes = self.getDeltaIndexes(objects: sorted)
                self.sortedItems.replace(with: sorted) {
                    completion((true, indexes))
                }
            }
            
            operationQueue.addOperation(operation)
        }
    }
    
    func reloadCurrentPages(completion: @escaping ReloadCompletionHandler) {
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
        sortedItems.replace(with: changedSorted) {
            completion()
        }
    }
    
    func selectItem(at indexPath: IndexPath) {
        if let item = sortedItems[indexPath.row] {
            if let alreadySelected = selectedItems.getSet().first(where: { $0.uuid == item.uuid }) {
                selectedItems.remove(alreadySelected)
            }
            selectedItems.insert(item)
        }
    }
    
    func deselectItem(at indexPath: IndexPath) {
        if let item = sortedItems[indexPath.row] {
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
        
        sortedItems.replace(with: changedSorted, completion: completion)
    }
    
    func createDownloadUrl(item: WrapData, completion: @escaping ValueHandler<URL?>) {
        privateShareAPIService.createDownloadUrl(projectId: item.accountUuid, uuid: item.uuid) { response in
            switch response {
                case .success(let urlWrapper):
                    completion(urlWrapper.url)
                    
                case .failed(_):
                    completion(nil)
            }
        }
    }
    
    func rename(item: WrapData, name: String, completion: @escaping BoolHandler) {
        privateShareAPIService.renameItem(projectId: item.accountUuid, uuid: item.uuid, name: name) { [weak self] response in
            
            ItemOperationManager.default.didRenameItem(item)
            
            switch response {
                case .success:
                    SnackbarManager.shared.show(elementType: .rename, relatedItems: [item], handler: nil)
                    completion(true)
                    
                case .failed(let error):
                    SnackbarManager.shared.show(type: .critical, message: error.localizedDescription)
                    completion(false)
            }
        }
    }
    
    //MARK: - Private
    
    private func cleanAll() {
        selectedItems.removeAll()
        sortedItems.removeAll()
    }
    
    private func loadPages(till page: Int, completion: @escaping ReloadCompletionHandler) {
        let operation = GetSharedItemsOperation(service: privateShareAPIService, type: type, size: pageSize, page: pagesLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder) { [weak self] rootFolder, loadedItems, isFinished in
            
            self?.rootFolder = rootFolder
            
            guard let self = self, isFinished else {
                completion((false, nil))
                return
            }
            
            self.tempLoaded.append(contentsOf: self.sorted(items: loadedItems))
            self.pagesLoaded += 1
            
            guard self.pagesLoaded < page, !loadedItems.isEmpty else {
                let sorted = self.sorted(items: self.tempLoaded)
                let indexes = self.getDeltaIndexes(objects: sorted)
                self.sortedItems.replace(with: sorted) {
                    completion((true, indexes))
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
    
    private func getDeltaIndexes(objects: [WrapData]) -> (inserted: [Int], deleted: [Int]) {
        let original = sortedItems.getArray()
        
        let insertions = objects.filter { !original.contains($0) }.compactMap { objects.index(of: $0) }
        let deletions = original.filter { !objects.contains($0) }.compactMap { original.index(of: $0) }
        
        return (insertions, deletions)
    }
}
