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
    case innerFolder(id: String, name: String)
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
    
    private(set) var sortedItems = SynchronizedArray<WrapData>()
    private(set) var selectedItems = SynchronizedSet<WrapData>()
    private(set) var splittedItems = SynchronizedArray<[WrapData]>()
    
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
                        
                        let newItems = filesInfo.compactMap { WrapData(privateShareFileInfo: $0) }
                        
                        guard !newItems.isEmpty else {
                            self.isPageLoading = false
                            completion([])
                            return
                        }
                        
                        self.pageLoaded += 1
                        
                        let sorted = self.sortedItems.getArray() + self.sorted(items: newItems)
                        self.sortedItems.replace(with: sorted, completion: nil)
                        
                        let splitted = self.splitted(sortedArray: sorted)
                        
                        self.splittedItems.replace(with: splitted) { [weak self] in
                            self?.isPageLoading = false
                            completion([])
                        }
                        
                    case .failed(_):
                        self.isPageLoading = false
                        completion([])
                }
            }
        }
    }
    
    func reload(completion: @escaping ValueHandler<[IndexPath]>) {
        queue.sync {
            selectedItems.removeAll()
            sortedItems.removeAll()
            splittedItems.removeAll()
            pageLoaded = 0
            loadNext(completion: completion)
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
        if let item = splittedItems[indexPath.section]?[safe:indexPath.row]{
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
    
    //MARK: - Private
    
    private func loadNextPage(completion: @escaping ResponseArrayHandler<SharedFileInfo>) {
        switch type {
            case .byMe:
                privateShareAPIService.getSharedByMe(size: pageSize, page: pageLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder, handler: completion)
                
            case .withMe:
                privateShareAPIService.getSharedWithMe(size: pageSize, page: pageLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder, handler: completion)
                
            case .innerFolder(let folderUuid, _):
                privateShareAPIService.getFiles(folderUUID: folderUuid, size: pageSize, page: pageLoaded, sortBy: sorting.sortingRules, sortOrder: sorting.sortOder) { response in
                    switch response {
                        case .success(let fileSystem):
                            completion(.success(fileSystem.fileList))
                        case .failed(let error):
                            completion(.failed(error))
                    }
                }
        }
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
            grouped = Dictionary(grouping: sortedArray, by: { $0.fileSize.bytesString })
            
        case .metaDataTimeUp, .metaDataTimeDown:
            grouped = Dictionary(grouping: sortedArray, by: { $0.creationDate?.getDateForSortingOfCollectionView() ?? Date().getDateForSortingOfCollectionView()
            })
        }
        
        let splitted: [[WrapData]]
        if grouped.isEmpty {
            splitted = [sortedArray]
        } else {
            splitted = grouped.sorted(by: { $0.0 > $1.0 }).compactMap { $0.value }
        }
        
        return splitted
    }
}
