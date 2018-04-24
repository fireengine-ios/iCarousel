//
//  LocalMediaItems.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/26/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos
import JDStatusBarNotification

typealias LocalFilesCallBack = (_ localFiles: [WrapData]) -> Void

extension CoreDataStack {

    @objc func appendLocalMediaItems(completion: VoidHandler?) {
        let localMediaStorage = LocalMediaStorage.default
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
        save(items: localMediaItems, context: newChildBackgroundContext, completion: completion)
    }
    
    func remove(localMediaItems: [PHAsset], completion: @escaping VoidHandler) {
        removeLocalMediaItems(with: localMediaItems.map { $0.localIdentifier })
        completion()
    }

    func insertFromGallery(completion: VoidHandler?) {
        guard !inProcessAppendingLocalFiles else {
            return
        }
        
        inProcessAppendingLocalFiles = true
        
        let localMediaStorage = LocalMediaStorage.default

        let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
        
        updateICloudStatus(for: assetsList, context: newChildBackgroundContext)
        
        let notSaved = listAssetIdIsNotSaved(allList: assetsList, context: backgroundContext)
        originalAssetsBeingAppended.append(list: notSaved)///tempo assets
        
        let start = Date()
        
        guard !notSaved.isEmpty else {
            inProcessAppendingLocalFiles = false
            print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
            NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
            return
        }
        DispatchQueue.main.async {
            JDStatusBarNotification.show(withStatus: "LOCAL FILES BEING POCCESSED", styleName: "JDStatusBarStyleWarning")
            JDStatusBarNotification.showActivityIndicator(true, indicatorStyle: .gray)
        }
        
        print("All local files started  \((start)) seconds")
        nonCloudAlreadySavedAssets.dropAll()
        save(items: notSaved, context: backgroundContext) { [weak self] in
            DispatchQueue.main.async {
                JDStatusBarNotification.show(withStatus: "ALL DONE", styleName: "JDStatusBarStyleSuccess")
                JDStatusBarNotification.dismiss(animated: true)
            }
            self?.originalAssetsBeingAppended.dropAll()///tempo assets
            print("LOCAL_ITEMS: All local files have been added in \(Date().timeIntervalSince(start)) seconds")
            self?.inProcessAppendingLocalFiles = false
            NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
            
            self?.pageAppendedCallBack?([])
            completion?()
        }
    }
    
    private func save(items: [PHAsset], context: NSManagedObjectContext, completion: @escaping VoidHandler ) {
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
                    
                    self?.saveDataForContext(context: context, saveAndWait: true, savedCallBack: { [weak self] in
                        self?.pageAppendedCallBack?(addedObjects)
                        
                        ItemOperationManager.default.addedLocalFiles(items: addedObjects)//TODO: Seems like we need it to update page after photoTake
                        print("LOCAL_ITEMS: page has been added in \(Date().timeIntervalSince(start)) secs")
                        self?.save(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
                    })
                    

                }
            })
        }
    }
    
    private func updateICloudStatus(for assets: [PHAsset], context: NSManagedObjectContext) {
        privateQueue.async { [weak self] in
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
                    let invalidItems = info.filter { !$0.isValid }.compactMap { $0.asset.localIdentifier }
                    print("iCloud: removing \(invalidItems.count) items")
                    self.removeLocalMediaItems(with: invalidItems)
                }
            })
        }
    }
    
    private func listAssetIdIsNotSaved(allList: [PHAsset], context: NSManagedObjectContext) -> [PHAsset] {
        let currentlyInLibriaryIDs: [String] = allList.compactMap { $0.localIdentifier }
        
        checkLocalFilesExistence(actualPhotoLibItemsIDs: currentlyInLibriaryIDs)
        
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)

        let alredySaved: [MediaItem] = executeRequest(predicate: predicate, context: context)
        
        let alredySavedIDs = alredySaved.compactMap { $0.localFileID }
        
        return allList.filter { !alredySavedIDs.contains( $0.localIdentifier ) }
    }
    
    private func listAssetIdAlreadySaved(allList: [PHAsset], context: NSManagedObjectContext) -> [PHAsset] {
        let currentlyInLibriaryIDs: [String] = allList.compactMap { $0.localIdentifier }
        
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        
        let alredySaved: [MediaItem] = executeRequest(predicate: predicate, context: context)
        
        let alredySavedIDs = alredySaved.compactMap { $0.localFileID }
        
        return allList.filter { alredySavedIDs.contains( $0.localIdentifier ) }
    }
    
    func removeLocalMediaItems(with assetIdList: [String]) {
        guard assetIdList.count > 0 else {
            return
        }
        let context = self.newChildBackgroundContext
        context.perform { [weak self] in
            guard let `self` = self else {
                return
            }
            let predicate = NSPredicate(format: "localFileID IN %@", assetIdList)
            let items:[MediaItem] = self.executeRequest(predicate: predicate, context: context)
            
            items.forEach { context.delete($0) }
            
            self.saveDataForContext(context: context, savedCallBack: nil)
        }
 
    }
    
    func allLocalItems() -> [WrapData] {
        let context = newChildBackgroundContext
        let predicate = NSPredicate(format: "localFileID != nil")
        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
        return items.flatMap { $0.wrapedObject }
    }
    
    func allLocalItems(with localIds: [String]) -> [WrapData] {
        let context = newChildBackgroundContext
        let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@)", localIds)
        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
        return items.flatMap { $0.wrapedObject }
    }
    
    func allLocalItems(with assets: [PHAsset]) -> [WrapData] {
        let context = newChildBackgroundContext
        
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
        let context = newChildBackgroundContext
        let predicate = NSPredicate(format: "(trimmedLocalFileID != nil) AND (trimmedLocalFileID IN %@)", trimmedLocalIds)
        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
        return items.flatMap { $0.wrapedObject }
    }
    
    func hasLocalItemsForSync(video: Bool, image: Bool, completion: @escaping  (_ has: Bool) -> Void) {
        getUnsyncsedMediaItems(video: video, image: image, completion: { items in
            let currentUserID = SingletonStorage.shared.uniqueUserID
            
            let filteredArray = items.filter { !$0.syncStatusesArray.contains(currentUserID) }
            
            completion(!filteredArray.isEmpty)
        })
        
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool, completion: @escaping (_ items: [WrapData]) -> Void) {
        getUnsyncsedMediaItems(video: video, image: image, completion: { items in
            let sortedItems = items.sorted { $0.fileSizeValue < $1.fileSizeValue }
            SingletonStorage.shared.getUniqueUserID(success: { userId in
                let filtredArray = sortedItems.filter { !$0.syncStatusesArray.contains(userId) }
                completion(filtredArray.compactMap { $0.wrapedObject })
            }, fail: {
                completion([])
            })
            
        })
    }
    
    private func getUnsyncsedMediaItems(video: Bool, image: Bool, completion: @escaping (_ items: [MediaItem]) -> Void) {
        let assetList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
        let currentlyInLibriaryLocalIDs: [String] = assetList.compactMap { $0.localIdentifier }
        
        var filesTypesArray = [Int16]()
        if (video) {
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image) {
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }
        
        let context = newChildBackgroundContext
        newChildBackgroundContext.perform { [weak self] in
            let predicate = NSPredicate(format: "(isLocalItemValue == true) AND (fileTypeValue IN %@) AND (localFileID IN %@)", filesTypesArray, currentlyInLibriaryLocalIDs)
           completion(self?.executeRequest(predicate: predicate, context: context) ?? [])
        }
        
        
    }
    
    func checkLocalFilesExistence(actualPhotoLibItemsIDs: [String]) {
        
        let newContext = newChildBackgroundContext
        
        newContext.perform { [weak self] in
            guard let `self` = self else {
                return
            }
            let predicate = NSPredicate(format: "localFileID != Nil AND NOT (localFileID IN %@)", actualPhotoLibItemsIDs)
            let allNonAccurateSavedLocalFiles: [MediaItem] = self.executeRequest(predicate: predicate,
                                                                            context: newContext)
            allNonAccurateSavedLocalFiles.forEach {
                newContext.delete($0)
            }
            self.saveDataForContext(context: newContext, savedCallBack: {
                /// put notification here that item deleted
                let items = allNonAccurateSavedLocalFiles.map { $0.wrapedObject }
                ItemOperationManager.default.deleteItems(items: items)
            })
        }
    }
}
