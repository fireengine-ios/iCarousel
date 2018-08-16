//
//  MediaItemOperationsService.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Photos

typealias LocalFilesCallBack = (_ localFiles: [WrapData]) -> Void

typealias AppendingLocaclItemsFinishCallback = () -> Void
typealias AppendingLocaclItemsProgressCallback = (Float) -> Void
typealias AppendingLocalItemsPageAppended = ([Item])->Void

final class MediaItemOperationsService {
    
    static let shared = MediaItemOperationsService()
    
    let privateQueue = DispatchQueue(label: DispatchQueueLabels.mediaItemOperationsService, attributes: .concurrent)
    
    var pageAppendedCallBack: AppendingLocalItemsPageAppended?
    
    var inProcessAppendingLocalFiles = false
    
    var originalAssetsBeingAppended = AssetsCache()
    var nonCloudAlreadySavedAssets = AssetsCache()
    
    func clearDataBase() {
        deleteRemoteFiles()
    }
    
    func deleteRemoteFiles() {
        // Album has remote status by default for now
        let albumFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItemsAlbum.Identifier)
        
        let mediaItemFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicateRules = PredicateRules()
        guard let predicate = predicateRules.predicate(filters: [.localStatus(.nonLocal)]) else {
            return
        }
        mediaItemFetchRequest.predicate = predicate
        
        self.deleteObjects(fromFetches: [albumFetchRequest, mediaItemFetchRequest])
    }
    
    func deleteLocalFiles() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicateRules = PredicateRules()
        guard let predicate = predicateRules.predicate(filters: [.localStatus(.local)]) else {
            return
        }
        fetchRequest.predicate = predicate
        self.deleteObjects(fromFetch: fetchRequest)
        
    }
    
    func getLocalDuplicates(remoteItems: [Item], duplicatesCallBack: @escaping ([Item]) -> Void) {
        var remoteMd5s = [String]()
        var trimmedIDs = [String]()
        remoteItems.forEach {
            remoteMd5s.append($0.md5)
            trimmedIDs.append($0.getTrimmedLocalID())
        }
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        fetchRequest.predicate = NSPredicate(format: "(md5Value IN %@) OR (trimmedLocalFileID IN %@)", remoteMd5s, trimmedIDs)
        let sort = NSSortDescriptor(key: "creationDateValue", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        let context = CoreDataStack.default.newChildBackgroundContext
        context.perform {
            guard let localDuplicatesMediaItems = (try? context.fetch(fetchRequest)) as? [MediaItem] else {
                duplicatesCallBack([])
                return
            }
            var array = [Item]()
            array = localDuplicatesMediaItems.flatMap { WrapData(mediaItem: $0) }
            
            duplicatesCallBack(array)
            
        }
    }
    
    func getLocalFilteredItem(remoteOriginalItem: Item, localFilteredPhotosCallBack: @escaping (Item?) -> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        fetchRequest.predicate = NSPredicate(format: "(md5Value = %@) AND (isFiltered == true)", remoteOriginalItem.md5, remoteOriginalItem.getTrimmedLocalID())
        
        let context = CoreDataStack.default.newChildBackgroundContext
        context.perform {
            guard let localDuplicatesMediaItems = (try? context.fetch(fetchRequest)) as? [MediaItem] else {
                localFilteredPhotosCallBack(nil)
                return
            }
            var array = [Item]()
            array = localDuplicatesMediaItems.flatMap { WrapData(mediaItem: $0) }
            localFilteredPhotosCallBack(array.first)
        }
        
    }
    
    private func deleteObjects(fromFetches fetchRequests: [NSFetchRequest<NSFetchRequestResult>]) {
        for fetchRequest in fetchRequests {
            self.deleteObjects(fromFetch: fetchRequest)
        }
    }
    
    private func deleteObjects(fromFetch fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let context = CoreDataStack.default.newChildBackgroundContext
        context.perform { [weak self] in
            guard let fetchResult = try? context.fetch(fetchRequest),
                let unwrapedObjects = fetchResult as? [NSManagedObject],
                unwrapedObjects.count > 0 else {
                    
                    return
            }
            for object in unwrapedObjects {
                context.delete(object)
            }
            CoreDataStack.default.saveDataForContext(context: context, saveAndWait: true, savedCallBack: {
                debugPrint("Data base deleted objects")
            })
            
        }
    }
    
    // MARK: - MediaItemOperations
    
    
    
//    func updateSavedItems(savedItems: [MediaItem], remoteItems: [WrapData], context: NSManagedObjectContext) {
//        guard savedItems.count > 0 else {
//            return
//        }
//        context.perform { [weak self] in
//            for savedMediaItem in savedItems {
//                for remoteWrapedItem in remoteItems {
//                    if savedMediaItem.trimmedLocalFileID == remoteWrapedItem.getTrimmedLocalID() {
//                        if let unwrapedParent = remoteWrapedItem.parent {
//                            savedMediaItem.parent = unwrapedParent
//                        }
//                        if let unwrapedAlbumbs = remoteWrapedItem.albums {
//                            //LR-2356
//                            
//                            let albums = unwrapedAlbumbs.map({ albumUuid -> MediaItemsAlbum in
//                                MediaItemsAlbum(uuid: albumUuid, context: context)
//                            })
//                            
//                            
//                            savedMediaItem.albums = NSOrderedSet(array: albums)
//                        }
//                        savedMediaItem.urlToFileValue = remoteWrapedItem.urlToFile?.absoluteString
//                        savedMediaItem.metadata?.largeUrl = remoteWrapedItem.metaData?.largeUrl?.absoluteString
//                        savedMediaItem.metadata?.mediumUrl = remoteWrapedItem.metaData?.mediumUrl?.absoluteString
//                        savedMediaItem.metadata?.smalURl = remoteWrapedItem.metaData?.smalURl?.absoluteString
//                        savedMediaItem.favoritesValue = remoteWrapedItem.favorites
//                        
//                        savedMediaItem.syncStatusValue = remoteWrapedItem.syncStatus.valueForCoreDataMapping()
//                        
//                        break
//                    }
//                }
//            }
//            
//            CoreDataStack.default.saveDataForContext(context: context, savedCallBack: nil)
//        }
//    }
    
    func updateLocalItemSyncStatus(item: Item) {
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            let predicateForRemoteFile = NSPredicate(format: "trimmedLocalFileID == %@", item.getTrimmedLocalID())
            let alreadySavedMediaItems = self.executeRequest(predicate: predicateForRemoteFile, context: context)
            alreadySavedMediaItems.forEach({ savedItem in
                //for locals
                savedItem.syncStatusValue = item.syncStatus.valueForCoreDataMapping()
                
                if savedItem.objectSyncStatus != nil {
                    savedItem.objectSyncStatus = nil
                }
                
                var array = [MediaItemsObjectSyncStatus]()
                for userID in item.syncStatuses {
                    array.append(MediaItemsObjectSyncStatus(userID: userID, context: context))
                }
                savedItem.objectSyncStatus = NSSet(array: array)
                
                //savedItem.objectSyncStatus?.addingObjects(from: item.syncStatuses)
            })
            context.saveAsync()
            //old CoreDataStack.default.saveDataForContext(context: context, savedCallBack: nil)
        }
    }
    
    
    // MARK: MediaItem
    
    func mediaItemByLocalID(trimmedLocalIDS: [String]) -> [MediaItem] {
        let predicate = NSPredicate(format: "trimmedLocalFileID IN %@", trimmedLocalIDS)
        return executeRequest(predicate: predicate, context: CoreDataStack.default.newChildBackgroundContext)
    }
    
    func executeRequest(predicate: NSPredicate, context: NSManagedObjectContext) -> [MediaItem] {
        var result: [MediaItem] = []
        do {
            let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
            request.predicate = predicate
            result = try context.fetch(request)
        } catch {
            print("context.fetch failed with:", error.localizedDescription)
        }
        return result
    }
    
    // MARK: - Remote Items
    
    func appendRemoteMediaItems(remoteItems: [Item], completion: @escaping VoidHandler) {
        let context = CoreDataStack.default.newChildBackgroundContext
        ///TODO: add check on existing files?
        // OR should we mark sync status and etc here. And also affect free app?
        
        guard !remoteItems.isEmpty else {
            debugPrint("REMOTE_ITEMS: no files to add")
            completion()
            return
        }
        debugPrint("REMOTE_ITEMS: \(remoteItems.count) remote files to add")
        
        context.perform { 
            remoteItems.forEach { item in
                autoreleasepool {
                    _ = MediaItem(wrapData: item, context: context)
                }
            }
            CoreDataStack.default.saveDataForContext(context: context, savedCallBack: completion)
        }
        //      ItemOperationManager.default.addedLocalFiles(items: addedObjects)
        //WARNING:- DO we need notify ItemOperationManager here???
    }

    func getAllRemotesMediaItem() -> [MediaItem] {
        let predicate = NSPredicate(format: "isLocalItemValue = true")
        return executeRequest(predicate: predicate, context: CoreDataStack.default.newChildBackgroundContext)
    }
    
    func isNoRemotesInDB() -> Bool {
        return getAllRemotesMediaItem().isEmpty
    }
    
    // MARK: - LocalMediaItems
    
    @objc func appendLocalMediaItems(completion: VoidHandler?) {
        let localMediaStorage = LocalMediaStorage.default
        
        guard !localMediaStorage.isWaitingForPhotoPermission else {
            return
        }
        
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] _, status in
            switch status {
            case .denied:
                MediaItemOperationsService.shared.deleteLocalFiles()
            case .authorized:
                self?.insertFromGallery(completion: completion)
            case .restricted, .notDetermined:
                break
            }
        }
    }
    
    func append(localMediaItems: [PHAsset], completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        privateQueue.async { [weak self] in
            guard let `self` = self else {
                completion()
                return
            }
            ///check which are new
            var newAssets =  [PHAsset]()
            var assetsToUpdate =  [PHAsset]()
            localMediaItems.forEach {
                if LocalMediaStorage.default.assetsCache.assetBy(identifier: $0.localIdentifier) != nil {
                    //update
                    assetsToUpdate.append($0) ///for now its useless
                } else {
                    newAssets.append($0)
                }
            }
            LocalMediaStorage.default.assetsCache.append(list: newAssets)
            
            MediaItemOperationsService.shared.saveLocalMediaItemsPaged(items: newAssets, context: CoreDataStack.default.newChildBackgroundContext, completion: completion)
        }
    }
    
    func remove(localMediaItems: [PHAsset], completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        removeLocalMediaItems(with: localMediaItems.map { $0.localIdentifier }, completion: completion)
        
    }
    
    private func insertFromGallery(completion: VoidHandler?) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion?()
            return
        }
        guard !inProcessAppendingLocalFiles else {
            return
        }
        inProcessAppendingLocalFiles = true
        
        let localMediaStorage = LocalMediaStorage.default
        
        let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
        
        updateICloudStatus(for: assetsList)
        let context = CoreDataStack.default.newChildBackgroundContext
        let notSaved = listAssetIdIsNotSaved(allList: assetsList, context: context)
        originalAssetsBeingAppended.append(list: notSaved)///tempo assets
        
        let start = Date()
        
        guard !notSaved.isEmpty else {
            inProcessAppendingLocalFiles = false
            print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
            NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
            return
        }
        
        print("All local files started  \((start)) seconds")
        nonCloudAlreadySavedAssets.dropAll()
        saveLocalMediaItemsPaged(items: notSaved, context: context) { [weak self] in
            self?.originalAssetsBeingAppended.dropAll()///tempo assets
            print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
            self?.inProcessAppendingLocalFiles = false
            NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
            
            self?.pageAppendedCallBack?([])
            completion?()
        }
    }
    
    private func saveLocalMediaItemsPaged(items: [PHAsset], context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        guard !items.isEmpty else {
            print("LOCAL_ITEMS: no files to add")
            completion()
            return
        }
        
        print("LOCAL_ITEMS: \(items.count) local files to add")
        let start = Date()
        let nextItemsToSave = Array(items.prefix(NumericConstants.numberOfLocalItemsOnPage))
        privateQueue.async { [weak self] in
            
            LocalMediaStorage.default.getInfo(from: nextItemsToSave, completion: { [weak self] info in
                context.perform { [weak self] in
                    var addedObjects = [WrapData]()
                    let assetsInfo = info.filter { $0.isValid }
                    assetsInfo.forEach { element in
                        autoreleasepool {
                            let wrapedItem = WrapData(info: element)
                            _ = MediaItem(wrapData: wrapedItem, context: context)
                            
                            addedObjects.append(wrapedItem)
                        }
                    }
                    
                    CoreDataStack.default.saveDataForContext(context: context, saveAndWait: true, savedCallBack: { [weak self] in
                        self?.pageAppendedCallBack?(addedObjects)
                        
                        ItemOperationManager.default.addedLocalFiles(items: addedObjects)//TODO: Seems like we need it to update page after photoTake
                        print("LOCAL_ITEMS: page has been added in \(Date().timeIntervalSince(start)) secs")
                        self?.saveLocalMediaItemsPaged(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
                    })
                    
                    
                }
            })
        }
    }
    
    private func updateICloudStatus(for assets: [PHAsset]) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return
        }
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            self?.privateQueue.async { [weak self] in
                
                guard let `self` = self else {
                    return
                }
                
                let alreadySavedAssets = self.listAssetIdAlreadySaved(allList: assets, context: context)
                let start = Date()
                LocalMediaStorage.default.getCompactInfo(from: alreadySavedAssets, completion: { [weak self] info in
                    guard let `self` = self else {
                        return
                    }
                    print("iCloud: updated iCloud in \(Date().timeIntervalSince(start)) secs")
                    context.perform {
                        let invalidItems = info.filter { !$0.isValid }.map { $0.asset.localIdentifier }
                        print("iCloud: removing \(invalidItems.count) items")
                        self.removeLocalMediaItems(with: invalidItems, completion: {})
                    }
                })
            }
        }
    }
    
    private func listAssetIdIsNotSaved(allList: [PHAsset], context: NSManagedObjectContext) -> [PHAsset] {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return []
        }
        
        let currentlyInLibriaryIDs = allList.map { $0.localIdentifier }
        checkLocalFilesExistence(actualPhotoLibItemsIDs: currentlyInLibriaryIDs)
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        let alredySaved = executeRequest(predicate: predicate, context: context)
        let alredySavedIDs = alredySaved.flatMap { $0.localFileID }
        
        return allList.filter { !alredySavedIDs.contains( $0.localIdentifier ) }
    }
    
    func listAssetIdAlreadySaved(allList: [PHAsset], context: NSManagedObjectContext) -> [PHAsset] {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return []
        }
        
        let currentlyInLibriaryIDs = allList.map { $0.localIdentifier }
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        let alredySaved = executeRequest(predicate: predicate, context: context)
        let alredySavedIDs = alredySaved.flatMap { $0.localFileID }
        
        return allList.filter { alredySavedIDs.contains( $0.localIdentifier ) }
    }
    
    func removeLocalMediaItems(with assetIdList: [String], completion: @escaping VoidHandler) {
        guard assetIdList.count > 0 else {
            return
        }
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                completion()
                return
            }
            let predicate = NSPredicate(format: "localFileID IN %@", assetIdList)
            let items = self.executeRequest(predicate: predicate, context: context)
            
            
            
            let deletedItems = items.map{ WrapData(mediaItem: $0) }
            LocalMediaStorage.default.assetsCache.remove(identifiers: assetIdList)
            ItemOperationManager.default.deleteItems(items: deletedItems)
            items.forEach { context.delete($0) }
            
            CoreDataStack.default.saveDataForContext(context: context, savedCallBack: { [weak self] in
                ///Appearantly after recovery local ID may change, so temporary soloution is to check all files all over. and in the future chenge DataBase behavior heavily
                let assetsList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
                
                self?.checkLocalFilesExistence(actualPhotoLibItemsIDs: assetsList.map{$0.localIdentifier}, complition: completion)
            })
        }
        
    }
    
    func allLocalItems() -> [WrapData] {
        let context = CoreDataStack.default.newChildBackgroundContext
        let predicate = NSPredicate(format: "localFileID != nil")
        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
        return items.flatMap { $0.wrapedObject }
    }
    
//    func allLocalItems(with localIds: [String]) -> [WrapData] {
//        let context = CoreDataStack.default.newChildBackgroundContext
//        let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@)", localIds)
//        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
//        return items.flatMap { $0.wrapedObject }
//    }
    
    func allLocalItems(with assets: [PHAsset]) -> [WrapData] {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return []
        }
        let context = CoreDataStack.default.newChildBackgroundContext
        
        let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@)", assets.map { $0.localIdentifier })
        var items = executeRequest(predicate: predicate, context: context)
        
        /// sort items in the assets order
        let ordering = Dictionary(uniqueKeysWithValues: assets.enumerated().map { ($1.localIdentifier, $0) })
        items = items.sorted(by: { (firstItem, secondItem) -> Bool in
            if let firstLocalId = firstItem.localFileID, let firstIndex = ordering[firstLocalId] {
                if let secondLocalId = secondItem.localFileID, let secondIndex = ordering[secondLocalId] {
                    return firstIndex < secondIndex
                } else {
                    return false
                }
            }
            return false
        })
        
        var localItems = [WrapData]()
        for (item, asset) in zip(items, assets) {
            localItems.append(item.wrapedObject(with: asset))
        }
        
        return localItems
    }
    
    func allLocalItems(trimmedLocalIds: [String]) -> [WrapData] {
        let context = CoreDataStack.default.newChildBackgroundContext
        let predicate = NSPredicate(format: "(trimmedLocalFileID != nil) AND (trimmedLocalFileID IN %@)", trimmedLocalIds)
        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
        return items.flatMap { $0.wrapedObject }
    }
    
    func hasLocalItemsForSync(video: Bool, image: Bool, completion: @escaping  (_ has: Bool) -> Void) {
        getUnsyncsedMediaItems(video: video, image: image, completion: { items in
            let wrappedItems = items.flatMap { $0.wrapedObject }
            completion(!AppMigrator.migrateSyncStatus(for: wrappedItems).isEmpty)
        })
        
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool, completion: @escaping (_ items: [WrapData]) -> Void) {
        getUnsyncsedMediaItems(video: video, image: image, completion: { items in
            let sortedItems = items.sorted { $0.fileSizeValue < $1.fileSizeValue }
            let wrappedItems = sortedItems.flatMap { $0.wrapedObject }
            
            completion(AppMigrator.migrateSyncStatus(for: wrappedItems))
        })
    }
    
    private func getUnsyncsedMediaItems(video: Bool, image: Bool, completion: @escaping (_ items: [MediaItem]) -> Void) {
        let assetList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
        let currentlyInLibriaryLocalIDs = assetList.map { $0.localIdentifier }
        
        var filesTypesArray = [Int16]()
        if (video) {
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image) {
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }
        
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "(isLocalItemValue == true) AND (fileTypeValue IN %@) AND (localFileID IN %@) AND (SUBQUERY(objectSyncStatus, $x, $x.userID == %@).@count == 0)", filesTypesArray, currentlyInLibriaryLocalIDs, SingletonStorage.shared.uniqueUserID)
            completion(self?.executeRequest(predicate: predicate, context: context) ?? [])
        }
    }
    
    private func checkLocalFilesExistence(actualPhotoLibItemsIDs: [String], complition: VoidHandler? = nil) {
        CoreDataStack.default.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            let predicate = NSPredicate(format: "localFileID != Nil AND NOT (localFileID IN %@)", actualPhotoLibItemsIDs)
            let allNonAccurateSavedLocalFiles: [MediaItem] = self.executeRequest(predicate: predicate, context: context)
            allNonAccurateSavedLocalFiles.forEach {
                context.delete($0)
            }
            CoreDataStack.default.saveDataForContext(context: context, savedCallBack: {
                /// put notification here that item deleted
                let items = allNonAccurateSavedLocalFiles.map { $0.wrapedObject }
                ItemOperationManager.default.deleteItems(items: items)
                complition?()
            })
        }
    }
}
