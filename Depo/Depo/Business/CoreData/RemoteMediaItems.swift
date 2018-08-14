//
//  RemoteMediaItems.swift
//  Depo
//
//  Created by Aleksandr on 8/10/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class CacheManager {///adding files TO DB // managing cache
    
    var allRemotesAdded = false
    var allLocalAdded = false
    
    private static let pageSize: Int = 1000
    private let photoVideoService = PhotoAndVideoService(requestSize: CacheManager.pageSize,
                                                         type: .imageAndVideo)
//    private var photoVideosPageCounter: Int = 0
    
    //TODO: place added blocks here?
    var remotePageAdded: VoidHandler?
    
    
    func startAppendingAllRemotes() {// we save remotes everytime, no metter if acces to PH libriary denied
        
        addNextRemoteItemsPage {
            
        }

    }
    
    private func addNextRemoteItemsPage(completion: @escaping VoidHandler) {
        photoVideoService.nextItems(fileType: .imageAndVideo, sortBy: .imageDate, sortOrder: .asc, success: { [weak self] remoteItems in
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

//class <#name#>: <#super class#> {
//    <#code#>
//}

extension CoreDataStack {
//    unc insertFromGallery(completion: VoidHandler?) {
//    guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
//    completion?()
//    return
//    }
//    guard !inProcessAppendingLocalFiles else {
//    return
//    }
//    inProcessAppendingLocalFiles = true
//
//    let localMediaStorage = LocalMediaStorage.default
//
//    let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
//
//    updateICloudStatus(for: assetsList, context: newChildBackgroundContext)
//
//    let notSaved = listAssetIdIsNotSaved(allList: assetsList, context: backgroundContext)
//    originalAssetsBeingAppended.append(list: notSaved)///tempo assets
//
//    let start = Date()
//
//    guard !notSaved.isEmpty else {
//    inProcessAppendingLocalFiles = false
//    print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
//    NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
//    return
//    }
//
//    print("All local files started  \((start)) seconds")
//    nonCloudAlreadySavedAssets.dropAll()
//    save(items: notSaved, context: backgroundContext) { [weak self] in
//    self?.originalAssetsBeingAppended.dropAll()///tempo assets
//    print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
//    self?.inProcessAppendingLocalFiles = false
//    NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
//
//    self?.pageAppendedCallBack?([])
//    completion?()
//    }
    func appendRemoteMediaItems(remoteItems: [Item], completion: @escaping VoidHandler) {
        let context = backgroundContext
        ///TODO: add check on existing files?
        // OR should we mark sync status and etc here. And also affect free app?
        
        guard !remoteItems.isEmpty else {
            print("REMOTE_ITEMS: no files to add")
            completion()
            return
        }
//        }
//
//        print("LOCAL_ITEMS: \(items.count) local files to add")
//        let start = Date()
//        let nextItemsToSave = Array(items.prefix(NumericConstants.numberOfLocalItemsOnPage))
//        privateQueue.async { [weak self] in
//
//            LocalMediaStorage.default.getInfo(from: nextItemsToSave, completion: { [weak self] info in
//                context.perform { [weak self] in
//                    var addedObjects = [WrapData]()
//                    let assetsInfo = info.filter { $0.isValid }
//                    assetsInfo.forEach { element in
//                        autoreleasepool {
//                            let wrapedItem = WrapData(info: element)
//                            _ = MediaItem(wrapData: wrapedItem, context: context)
//
//                            addedObjects.append(wrapedItem)
//                        }
//                    }
//
//                    self?.saveDataForContext(context: context, saveAndWait: true, savedCallBack: { [weak self] in
//                        self?.pageAppendedCallBack?(addedObjects)
//
//                        ItemOperationManager.default.addedLocalFiles(items: addedObjects)//TODO: Seems like we need it to update page after photoTake
//                        print("LOCAL_ITEMS: page has been added in \(Date().timeIntervalSince(start)) secs")
//                        self?.save(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
//                    })
//
//
//                }
//            })
//        }
    }
    
}
