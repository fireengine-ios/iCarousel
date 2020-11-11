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
    private var sorting: SortType = .date
    
    private(set) var loadedItems = SynchronizedArray<SharedFileInfo>()
    
    
    //MARK: - Life cycle
    
    private init() { }
    
    //MARK: - Public
    
    func loadNext(completion: @escaping BoolHandler) {
        queue.async(flags: .barrier) { [weak self] in
            self?.loadNextPage { result in
                guard let self = self else {
                    return
                }
                
                switch result {
                    case .success(let filesInfo):
                        self.pageLoaded += 1
                        self.loadedItems.append(filesInfo)
                        completion(!filesInfo.isEmpty)
                        
                    case .failed(_):
                        completion(false)
                }
            }
        }
    }
    
    func reload(completion: @escaping BoolHandler) {
        queue.sync {
            loadedItems.removeAll()
            pageLoaded = 0
            loadNext(completion: completion)
        }
    }
    
    func change(sortBy: SortType, completion: @escaping BoolHandler) {
        guard sortBy != sorting else {
            completion(true)
            return
        }
        
        sorting = sortBy
        reload(completion: completion)
    }
    
    //MARK: - Private
    
    private func loadNextPage(completion: @escaping ResponseArrayHandler<SharedFileInfo>) {
        switch type {
            case .byMe:
                privateShareAPIService.getSharedByMe(size: pageSize, page: pageLoaded, sortBy: sorting, sortOrder: .asc, handler: completion)
            case .withMe:
                privateShareAPIService.getSharedByMe(size: pageSize, page: pageLoaded, sortBy: sorting, sortOrder: .asc, handler: completion)
        }
    }
}
