//
//  PrivateShareFileInfoManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 10.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


enum PrivateShareType {
    case byMe
    case withMe
}


final class PrivateShareFileInfoManager {
    
    static func with(type: PrivateShareType, privateShareAPIService: PrivateShareApiService) -> PrivateShareFileInfoManager {
        let service = PrivateShareFileInfoManager()
        service.type = type
        service.privateShareAPIService = privateShareAPIService
        return service
    }
    
    private var privateShareAPIService: PrivateShareApiService!
    private var type: PrivateShareType = .byMe
    private let queue = DispatchQueue(label: DispatchQueueLabels.privateShareFileInfoManagerQueue)
    private let pageSize = 100
    private var pageLoaded = 0
    private var sorting: SortedRules = .timeUp
    private var isPageLoading = false
    
    private(set) var loadedItems = SynchronizedArray<WrapData>()
    private(set) var selectedItems = SynchronizedSet<WrapData>()
    
    //MARK: - Life cycle
    
    private init() { }
    
    //MARK: - Public
    
    func loadNext(completion: @escaping ValueHandler<[IndexPath]>) {
        guard !isPageLoading else {
            return
        }
        
        queue.async(flags: .barrier) { [weak self] in
            self?.isPageLoading = true
            self?.loadNextPage { result in
                guard let self = self else {
                    return
                }
                
                switch result {
                    case .success(let filesInfo):
                        self.pageLoaded += 1
                        
                        let firstRowToAdd = self.loadedItems.count
                        let sortedItems = self.sorted(items: filesInfo.compactMap { WrapData(privateShareFileInfo: $0) })
                        self.loadedItems.append(sortedItems)
                        
                        //TODO: sections
                        var indexPathes = [IndexPath]()
                        for i in 0..<filesInfo.count {
                            indexPathes.append(IndexPath(row: firstRowToAdd+i, section: 0))
                        }
                        completion(indexPathes)
                        
                    case .failed(_):
                        completion([])
                }
                self.isPageLoading = false
            }
        }
    }
    
    func reload(completion: @escaping ValueHandler<[IndexPath]>) {
        queue.sync {
            selectedItems.removeAll()
            loadedItems.removeAll()
            pageLoaded = 0
            loadNext(completion: completion)
        }
    }
    
    func change(sortingRules: SortedRules, completion: @escaping VoidHandler) {
        guard sorting != sortingRules else {
            return
        }
        
        sorting = sortingRules
        loadedItems.modify { [weak self] array in
            guard let self = self else {
                completion()
                return []
            }
            completion()
            return self.sorted(items: array)
        }
    }
    
    func selectItem(at indexPath: IndexPath) {
        //TODO: sections
        if let item = loadedItems[indexPath.row] {
            selectedItems.insert(item)
        }
    }
    
    func deselectItem(at indexPath: IndexPath) {
        //TODO: sections
        if let item = loadedItems[indexPath.row] {
            selectedItems.remove(item)
        }
    }
    
    func deselectAll() {
        selectedItems.removeAll()
    }
    
    //MARK: - Private
    
    private func loadNextPage(completion: @escaping ResponseArrayHandler<SharedFileInfo>) {
        switch type {
            case .byMe:
                privateShareAPIService.getSharedByMe(size: pageSize, page: pageLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder, handler: completion)
            case .withMe:
                privateShareAPIService.getSharedByMe(size: pageSize, page: pageLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder, handler: completion)
        }
    }
    
    private func sorted(items: [WrapData]) -> [WrapData] {
        return WrapDataSorting.sort(items: items, sortType: sorting)
    }
}
