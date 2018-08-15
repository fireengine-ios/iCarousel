//
//  CacheManager.swift
//  Depo
//
//  Created by Aleksandr on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class CacheManager {///adding files TO DB // managing cache
    
    static let shared = CacheManager()
    
    var allRemotesAdded = false
    var allLocalAdded = false
    
    private static let pageSize: Int = 1000
    private let photoVideoService = PhotoAndVideoService(requestSize: CacheManager.pageSize,
                                                         type: .imageAndVideo)
    private var processingRemoteItems = false
//    private var photoVideosPageCounter: Int = 0
    
    //TODO: place  blocks here?
    var remotePageAdded: VoidHandler?
    
    
    func startAppendingAllRemotes() {// we save remotes everytime, no metter if acces to PH libriary denied
        guard !processingRemoteItems else {
            return
        }
        processingRemoteItems = true
        addNextRemoteItemsPage { [weak self] in
            self?.processingRemoteItems = false
            self?.remotePageAdded?()
        }

    }
    
    private func addNextRemoteItemsPage(completion: @escaping VoidHandler) {
        photoVideoService.nextItems(fileType: .imageAndVideo, sortBy: .imageDate, sortOrder: .asc, success: { [weak self] remoteItems in
            
//            var itemsToAppend = [Item]()
//            var itemsToUpdate = [Item]()
//            
//            remoteItems.forEach {
//                
//            }
            
            CoreDataStack.default.appendRemoteMediaItems(remoteItems: remoteItems) { [weak self] in
                self?.remotePageAdded?()
                if remoteItems.count < CacheManager.pageSize {
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
        CoreDataStack.default.appendLocalMediaItems { [weak self] in
            self?.allLocalAdded = true
        }
    }

}

extension CoreDataStack {//Remote items protocol here?
    
    func appendRemoteMediaItems(remoteItems: [Item], completion: @escaping VoidHandler) {
        let context = backgroundContext
        ///TODO: add check on existing files?
        // OR should we mark sync status and etc here. And also affect free app?
        
        guard !remoteItems.isEmpty else {
            debugPrint("REMOTE_ITEMS: no files to add")
            completion()
            return
        }
        debugPrint("REMOTE_ITEMS: \(remoteItems.count) remote files to add")
        
        context.perform { [weak self] in
            remoteItems.forEach { item in
                autoreleasepool {
                 
                    _ = MediaItem(wrapData: item, context: context)
                    
                }
            }
            self?.saveDataForContext(context: context, savedCallBack: completion)
        }
//      ItemOperationManager.default.addedLocalFiles(items: addedObjects)
        //WARNING:- DO we need notify ItemOperationManager here???
    }
    
}
