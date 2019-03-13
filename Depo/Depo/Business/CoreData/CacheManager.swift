//
//  CacheManager.swift
//  Depo
//
//  Created by Aleksandr on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class CacheManager {///adding files TO DB // managing cache
    
    static let shared = CacheManager()
    

    
//    private static let firstPageSize: Int = 100
    private static let pageSize: Int = 1000
    private let photoVideoService = PhotoAndVideoService(requestSize: CacheManager.pageSize,
                                                         type: .imageAndVideo)
    var processingRemoteItems = false
    var allLocalAdded = false
    
    //TODO: place  blocks here?
//    var remotePageAdded: VoidHandler?
    var prepareDBCompletion: VoidHandler?
    
    func actualizeCache(completion: VoidHandler?) {
        MediaItemOperationsService.shared.isNoRemotesInDB { [weak self] isNoRemotes in
            if isNoRemotes {
                self?.startAppendingAllRemotes(completion: { [weak self] in
                    self?.startAppendingAllLocals(completion: {
                        self?.prepareDBCompletion?()
                        completion?()
                    })
                })
            } else {
                self?.startAppendingAllLocals(completion: {
                    self?.prepareDBCompletion?()
                    completion?()
                })
            }
        }
    }
    
    func startAppendingAllRemotes(completion: @escaping VoidHandler) {
        /// we save remotes everytime, no metter if acces to PH libriary denied
            guard !self.processingRemoteItems else {
                //completion()
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
    
    func startAppendingAllLocals(completion: @escaping VoidHandler) {
        allLocalAdded = false
        MediaItemOperationsService.shared.appendLocalMediaItems { [weak self] in
            self?.allLocalAdded = true
            CardsManager.default.stopOperationWithType(type: .preparePhotosQuickScroll)
            completion()
        }
    }
    //TODO: move method of QS DB update here.

    
}
