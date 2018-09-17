//
//  CacheManager.swift
//  Depo
//
//  Created by Aleksandr on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class CacheManager {///adding files TO DB // managing cache
    
    static let shared = CacheManager()
    
    var allLocalAdded = false
    
    private static let pageSize: Int = 1000
    private let photoVideoService = PhotoAndVideoService(requestSize: CacheManager.pageSize,
                                                         type: .imageAndVideo)
    var processingRemoteItems = false
//    private var photoVideosPageCounter: Int = 0
    
    //TODO: place  blocks here?
    var remotePageAdded: VoidHandler?
    
    
    func startAppendingAllRemotes() {// we save remotes everytime, no metter if acces to PH libriary denied
        MediaItemOperationsService.shared.isNoRemotesInDB(result: { [weak self] isNoRemotes in
            guard let `self` = self else {
                return
            }
            
            guard !self.processingRemoteItems else {
                return
            }
            self.processingRemoteItems = true
            self.addNextRemoteItemsPage { [weak self] in
                ///As soon as all remotes added - start adding locals
                self?.startAppendingAllLocals()
//                MediaItemOperationsService.shared.appendLocalMediaItems(completion: nil)
                self?.processingRemoteItems = false
                self?.remotePageAdded?()
            }
            
        })
    }
    
    private func addNextRemoteItemsPage(completion: @escaping VoidHandler) {
        photoVideoService.nextItems(fileType: .imageAndVideo, sortBy: .imageDate, sortOrder: .asc, success: { [weak self] remoteItems in
            
//            var itemsToAppend = [Item]()
//            var itemsToUpdate = [Item]()
//            
//            remoteItems.forEach {
//                
//            }
            
            MediaItemOperationsService.shared.appendRemoteMediaItems(remoteItems: remoteItems) { [weak self] in
                self?.remotePageAdded?()
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
    
    func startAppendingAllLocals() {
        allLocalAdded = false
        MediaItemOperationsService.shared.appendLocalMediaItems { [weak self] in
            self?.allLocalAdded = true
        }
    }

}
