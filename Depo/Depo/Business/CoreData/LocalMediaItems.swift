//
//  LocalMediaItems.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/26/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos

typealias LocalFilesCallBack = (_ localFiles: [WrapData]) -> Void

extension CoreDataStack {

    @objc func appendLocalMediaItems(completion: VoidHandler?) {
        let localMediaStorage = LocalMediaStorage.default
        
        guard !localMediaStorage.isWaitingForPhotoPermission else {
            return
        }
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { (authorized, status) in
            if authorized {
                self.insertFromGallery(completion: completion)
            }
            if status == .denied {
                self.deleteLocalFiles()
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
            let context = self.newChildBackgroundContext
            
            let alreadySavedMediaItems = self.executeRequest(predicate: NSPredicate(format: " (\(#keyPath(MediaItem.isLocalItemValue)) == true) AND (\(#keyPath(MediaItem.localFileID)) IN %@)", newAssets.map{$0.localIdentifier}), context: context)
            
            debugLog("new assets to add without trimming \(newAssets.count)")
            alreadySavedMediaItems.forEach { alreadySavedItem in
                newAssets.removeAll(where: {  $0.localIdentifier == alreadySavedItem.localFileID })
            }
            debugLog("new assets to add after trimming \(newAssets.count)")
                
            self.save(items: newAssets, context: context, completion: completion)
        }
    }
    
    func remove(localMediaItems: [PHAsset], completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        removeLocalMediaItems(with: localMediaItems.map { $0.localIdentifier }, completion: completion)
        
    }

    func insertFromGallery(completion: VoidHandler?) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion?()
            return
        }
        guard !inProcessAppendingLocalFiles else {
            return
        }
        debugLog("insertFromGallery")
        inProcessAppendingLocalFiles = true
        
        let localMediaStorage = LocalMediaStorage.default

        let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
        
        updateICloudStatus(for: assetsList, context: newChildBackgroundContext)
        
        listAssetIdIsNotSaved(allList: assetsList, context: backgroundContext) { [weak self] notSavedAssets in
            guard let `self` = self else {
                return
            }

            self.originalAssetsBeingAppended.append(list: notSavedAssets)///tempo assets
            
            let start = Date()
            
            guard !notSavedAssets.isEmpty else {
                self.inProcessAppendingLocalFiles = false
                print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
                NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
                return
            }
            
            print("All local files started  \((start)) seconds")
            self.nonCloudAlreadySavedAssets.dropAll()
            self.save(items: notSavedAssets, context: self.backgroundContext) { [weak self] in
                self?.originalAssetsBeingAppended.dropAll()///tempo assets
                print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
                self?.inProcessAppendingLocalFiles = false
                NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
                self?.postiNotificationLocalPageAdded(latestItems: [])
                
                completion?()
            }
        }
    }
    
    private func postiNotificationLocalPageAdded(latestItems: [WrapData]) {
        let latestLocals = [CoreDataStack.notificationNewLocalPageAppendedFilesKey: latestItems]
        NotificationCenter.default.post(name: Notification.Name.notificationNewLocalPageAppended, object: nil, userInfo: latestLocals)
    }
    
    private func save(items: [PHAsset], context: NSManagedObjectContext, completion: @escaping VoidHandler ) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        guard !items.isEmpty else {
            print("LOCAL_ITEMS: no files to add")
            completion()
            return
        }
        
        debugLog("LOCAL_ITEMS: \(items.count) local files to add")
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
                    
                    self?.saveDataForContext(context: context, saveAndWait: true, savedCallBack: { [weak self] in
                        self?.postiNotificationLocalPageAdded(latestItems: addedObjects)
                        
                        ItemOperationManager.default.addedLocalFiles(items: addedObjects)//TODO: Seems like we need it to update page after photoTake
                        print("LOCAL_ITEMS: page has been added in \(Date().timeIntervalSince(start)) secs")
                        self?.save(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
                    })
                    

                }
            })
        }
    }
    
    private func updateICloudStatus(for assets: [PHAsset], context: NSManagedObjectContext) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return
        }
        privateQueue.async { [weak self] in
            self?.listAssetIdAlreadySaved(allList: assets, context: context, completion: { [weak self] alreadySavedAssets in
                guard let `self` = self else {
                    return
                }
                
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
            })
        }
    }
    
    func listAssetIdAlreadySaved(allList: [PHAsset], context: NSManagedObjectContext, completion: @escaping ([PHAsset]) -> Void) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return
        }
        
        let currentlyInLibriaryIDs: [String] = allList.map { $0.localIdentifier }
        
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        context.perform { [weak self] in
            let alredySaved = self?.executeRequest(predicate: predicate, context: context) ?? []
            let alredySavedIDs = alredySaved.flatMap { $0.localFileID }
            completion(allList.filter { alredySavedIDs.contains( $0.localIdentifier ) })
        }
    }
    
    private func listAssetIdIsNotSaved(allList: [PHAsset], context: NSManagedObjectContext, completion: @escaping ([PHAsset]) -> Void) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion([])
            return
        }
        let currentlyInLibriaryIDs: [String] = allList.map { $0.localIdentifier }
        
        checkLocalFilesExistence(actualPhotoLibItemsIDs: currentlyInLibriaryIDs)
        
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        context.perform { [weak self] in
            let alredySaved = self?.executeRequest(predicate: predicate, context: context) ?? []
            let alredySavedIDs = alredySaved.flatMap { $0.localFileID }
            completion(allList.filter { !alredySavedIDs.contains( $0.localIdentifier ) })
        }
    }
    
    func removeLocalMediaItems(with assetIdList: [String], completion: @escaping VoidHandler) {
        guard assetIdList.count > 0 else {
            return
        }
        let context = newChildBackgroundContext
        context.perform { [weak self] in
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

            self.saveDataForContext(context: context, savedCallBack: { [weak self] in
                ///Appearantly after recovery local ID may change, so temporary soloution is to check all files all over. and in the future chenge DataBase behavior heavily
                let assetsList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
                
                self?.checkLocalFilesExistence(actualPhotoLibItemsIDs: assetsList.flatMap{$0.localIdentifier}, completion: completion)
            })
        }
 
    }
    
    func allLocalItems(completion: @escaping LocalFilesCallBack) {
        let predicate = NSPredicate(format: "localFileID != nil")
        allLocalItems(with: predicate, completion: completion)
    }
    
    func allLocalItems(with localIds: [String], completion: @escaping LocalFilesCallBack) {
        let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@)", localIds)
        allLocalItems(with: predicate, completion: completion)
    }
    
    func allLocalItems(trimmedLocalIds: [String], completion: @escaping LocalFilesCallBack) {
        let predicate = NSPredicate(format: "(trimmedLocalFileID != nil) AND (trimmedLocalFileID IN %@)", trimmedLocalIds)
        allLocalItems(with: predicate, completion: completion)
    }
    
    private func allLocalItems(with predicate: NSPredicate, completion: @escaping LocalFilesCallBack) {
        let context = newChildBackgroundContext
        context.perform { [weak self] in
            let items: [MediaItem] = self?.executeRequest(predicate: predicate, context: context) ?? []
            completion(items.flatMap { $0.wrapedObject })
        }
    }
    
    func allLocalItems(with assets: [PHAsset], completion: @escaping LocalFilesCallBack) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion([])
            return
        }
        
        let context = newChildBackgroundContext
        context.perform { [weak self] in
            let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@)", assets.map { $0.localIdentifier })
            var items = self?.executeRequest(predicate: predicate, context: context) ?? []
            
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
            
            completion(localItems)
        }
    }
    
    func hasLocalItemsForSync(video: Bool, image: Bool, completion: @escaping  (_ has: Bool) -> Void) {
        getUnsyncsedMediaItems(video: video, image: image, completion: { items in
            let wrappedItems = items.flatMap { $0.wrapedObject }
            completion(!AppMigrator.migrateSyncStatus(for: wrappedItems).isEmpty)
        })
        
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool, completion: @escaping LocalFilesCallBack) {
        getUnsyncsedMediaItems(video: video, image: image, completion: { items in
            let sortedItems = items.sorted { $0.fileSizeValue < $1.fileSizeValue }
            let wrappedItems = sortedItems.flatMap { $0.wrapedObject }
            
            completion(AppMigrator.migrateSyncStatus(for: wrappedItems))
        })
    }
    
    private func getUnsyncsedMediaItems(video: Bool, image: Bool, completion: @escaping MediaItemsCallBack) {
        let assetList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
        let currentlyInLibriaryLocalIDs: [String] = assetList.flatMap { $0.localIdentifier }
        
        var filesTypesArray = [Int16]()
        if (video) {
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image) {
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }
        
        let context = newChildBackgroundContext
        context.perform { [weak self] in
            let predicate = NSPredicate(format: "(isLocalItemValue == true) AND (fileTypeValue IN %@) AND (localFileID IN %@) AND (SUBQUERY(objectSyncStatus, $x, $x.userID == %@).@count == 0)", filesTypesArray, currentlyInLibriaryLocalIDs, SingletonStorage.shared.uniqueUserID)
           completion(self?.executeRequest(predicate: predicate, context: context) ?? [])
        }
    }
    
    func checkLocalFilesExistence(actualPhotoLibItemsIDs: [String], completion: VoidHandler? = nil) {
        let newContext = newChildBackgroundContext
        newContext.perform { [weak self] in
            guard let `self` = self else {
                return
            }

            let predicate = NSPredicate(format: "localFileID != Nil AND NOT (localFileID IN %@)", actualPhotoLibItemsIDs)
            let allNonAccurateSavedLocalFiles = self.executeRequest(predicate: predicate, context: newContext)
            
            allNonAccurateSavedLocalFiles.forEach {
                newContext.delete($0)
            }
            self.saveDataForContext(context: newContext, savedCallBack: {
                /// put notification here that item deleted
                let items = allNonAccurateSavedLocalFiles.map { $0.wrapedObject }
                ItemOperationManager.default.deleteItems(items: items)
                completion?()
            })
        }
    }
}
