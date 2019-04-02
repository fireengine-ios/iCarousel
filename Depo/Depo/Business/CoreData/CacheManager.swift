//
//  CacheManager.swift
//  Depo
//
//  Created by Aleksandr on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//


/*
 //
 //adding files TO DB // managing cache
 //
 */

protocol CacheManagerDelegate: class {
    func didCompleteCacheActualization()
}

final class CacheManager {
    
    static let shared = CacheManager()
    
    private static let pageSize: Int = 1000
    private let photoVideoService = PhotoAndVideoService(requestSize: CacheManager.pageSize,
                                                         type: .imageAndVideo)
    private(set) var processingRemoteItems = false
    private(set) var processingLocalItems = false
    private(set) var isProcessing = false
    private(set) var isCacheActualized = false
    
    let delegates = MulticastDelegate<CacheManagerDelegate>()
    
    
    func actualizeCache(completion: VoidHandler?) {
        if !isProcessing {
            CardsManager.default.startOperationWith(type: .preparePhotosQuickScroll)
        }
        
        isCacheActualized = false
        isProcessing = true
        MediaItemOperationsService.shared.isNoRemotesInDB { [weak self] isNoRemotes in
            if isNoRemotes {
                self?.startAppendingAllRemotes(completion: { [weak self] in
                    self?.startAppendingAllLocals(completion: {
                        self?.isProcessing = false
                        self?.isCacheActualized = true
                        CardsManager.default.stopOperationWithType(type: .preparePhotosQuickScroll)
                        self?.delegates.invoke { $0.didCompleteCacheActualization() }
                        completion?()
                    })
                })
            } else {
                self?.startAppendingAllLocals(completion: {
                    self?.isProcessing = false
                    self?.isCacheActualized = true
                    CardsManager.default.stopOperationWithType(type: .preparePhotosQuickScroll)
                    self?.delegates.invoke { $0.didCompleteCacheActualization() }
                    completion?()
                })
            }
        }
    }
    
    private func startAppendingAllRemotes(completion: @escaping VoidHandler) {
        /// we save remotes everytime, no metter if acces to PH libriary denied
            guard !self.processingRemoteItems else {
                return
            }
        
            self.processingRemoteItems = true
            self.addNextRemoteItemsPage { [weak self] in
                self?.processingRemoteItems = false
//                self?.remotePageAdded?()
                completion()
            }
    }
    
    private func addNextRemoteItemsPage(completion: @escaping VoidHandler) {
        photoVideoService.nextItems(fileType: .imageAndVideo, sortBy: .imageDate, sortOrder: .desc, success: { [weak self] remoteItems in
            
            MediaItemOperationsService.shared.appendRemoteMediaItems(remoteItems: remoteItems) { [weak self] in
//                self?.remotePageAdded?()
                if remoteItems.count < CacheManager.pageSize {
                    self?.photoVideoService.currentPage = 0
                    completion()
                }
            }
            if remoteItems.count >= CacheManager.pageSize {
                self?.addNextRemoteItemsPage(completion: completion)
            }
            
        }) {
            completion()///// create some kind of system where we wait till the internet is back and send request again
        }
    }
    
    private func startAppendingAllLocals(completion: @escaping VoidHandler) {
        guard !self.processingLocalItems else {
            return
        }
        
        processingLocalItems = true
        MediaItemOperationsService.shared.appendLocalMediaItems { [weak self] in
            self?.processingLocalItems = false
            completion()
        }
    }
    //TODO: move method of QS DB update here.

    
}
