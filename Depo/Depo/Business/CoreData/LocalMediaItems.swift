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
    
    func append(localMediaItems: [PHAsset], completion: @escaping ()->Void) {
//        let newBgcontext = backgroundContext//self.newChildBackgroundContext
        save(items: localMediaItems, context: backgroundContext, completion: {})
    }
    
    func remove(localMediaItems: [PHAsset], completion: @escaping ()->Void) {
        removeLocalMediaItems(with: localMediaItems.map { $0.localIdentifier })
    }

    func insertFromGallery(completion: VoidHandler?) {
        guard !inProcessAppendingLocalFiles else {
            return
        }
        
        inProcessAppendingLocalFiles = true
        
        let localMediaStorage = LocalMediaStorage.default

        let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
        
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
            completion?()
        }
    }

    func getLocalFilesForPhotoVideoPage(filesType: FileType, sortType: SortedRules,
                                        paginationEnd: Bool,
                                        firstPage: Bool,
                                        pageRemoteItems: [Item],
                                        notAllowedMD5: [String],
                                        notAllowedLocalIDs: [String],
                                        filesCallBack: @escaping LocalFilesCallBack) {
        
//        let requestContext = newChildBackgroundContext
//        
//        let request = NSFetchRequest<MediaItem>()
//        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
//                                                    in: requestContext)
//        
//        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
//        
//        
//        let cahchePredicate = NSPredicate(format:"NOT (md5Value IN %@)", notAllowedMD5)
//        //"NOT (md5Value IN %@ OR localFileID IN %@)", md5s, uuids)//AND?
//        let sortingPredicate: NSPredicate
//        
//        let compundedPredicate: NSCompoundPredicate
//        compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[fileTypePredicate, cahchePredicate])
//        
//
//        request.predicate = compundedPredicate
//        guard let localDataBaseItems = try? requestContext.fetch(request) else {
//            filesCallBack([])
//            return
//        }
//        
//        let arrayLocalItems = NSArray(array: localDataBaseItems)
//        
//        
//        if pageRemoteItems.isEmpty {
//            //
//            filesCallBack([])
//            //
//            if inProcessAppendingLocalFiles {
//            //local pagination here
//            }
//            
//        } else if firstPage {
//            debugPrint("!LOCAL FIRST PAGE")
//            
//            guard let lastRemoteItem = pageRemoteItems.last,
//            let localFiltered = arrayLocalItems.filtered(using: getSortingPredicateFirstPage(sortType: sortType, lastItem: lastRemoteItem)) as? [MediaItem],
//            !originalAssetsBeingAppended.assets(before: lastRemoteItem.metaDate, mediaType: filesType.convertedToPHMediaType).isEmpty else {
//                filesCallBack([])
//                return
//            }
//            
//            if inProcessAppendingLocalFiles {
//                if let lastAppendedToDBItemDate = localDataBaseItems.last?.creationDateValue as? Date,
//                    lastRemoteItem.metaDate > lastAppendedToDBItemDate {
//                    filesCallBack(localFiltered.map{WrapData(mediaItem: $0)})
//                } else if localFiltered.count >= 100 {
//                    filesCallBack(localFiltered.map{WrapData(mediaItem: $0)})
//                } else {
//                    pageAppendedCallBack = { [weak self] localItems in
//                        guard let `self` = self,
//                            let lastAppendedToDBItemDate = localItems.last?.metaDate,
//                            lastRemoteItem.metaDate < lastAppendedToDBItemDate
//                            else {
//                            filesCallBack([])
//                            return
//                        }
//                        self.pageAppendedCallBack = nil
//                        self.getLocalFilesForPhotoVideoPage(filesType: filesType, sortType: sortType, paginationEnd: paginationEnd, firstPage: firstPage, pageRemoteItems: pageRemoteItems, notAllowedMD5: notAllowedMD5, notAllowedLocalIDs: notAllowedLocalIDs, filesCallBack: filesCallBack)
//                    }
//                }
//            } else {
//                filesCallBack(localFiltered.map{WrapData(mediaItem: $0)})
//            }
//            
//        } else if pageRemoteItems.count == 1,
//            paginationEnd,
//            let lastItem = pageRemoteItems.last {
//            debugPrint("!LOCAL END PAGE")
//            guard let localFiltered = arrayLocalItems.filtered(using: getSortingPredicateLastPage(sortType: sortType, lastItem: lastItem)) as? [MediaItem],
//                !originalAssetsBeingAppended.assets(afterDate: lastItem.metaDate, mediaType: filesType.convertedToPHMediaType).isEmpty else {
//                filesCallBack([])
//                return
//            }
// 
//            if inProcessAppendingLocalFiles {
//                if let lastAppendedToDBItemDate = localDataBaseItems.last?.creationDateValue,
//                     lastItem.metaDate < lastAppendedToDBItemDate as Date {
//                    filesCallBack(localFiltered.map{WrapData(mediaItem: $0)})
//                } else if localFiltered.count >= 100 {
//                    filesCallBack(localFiltered.map{WrapData(mediaItem: $0)})
//                } else {
//                    pageAppendedCallBack = { [weak self] localItems in
//                        guard let `self` = self,
//                            let lastAppendedToDBItemDate = localItems.last?.metaDate,
//                            lastItem.metaDate > lastAppendedToDBItemDate
//                            else {
//                            filesCallBack([])
//                            return
//                        }
//                        self.pageAppendedCallBack = nil
//                        self.getLocalFilesForPhotoVideoPage(filesType: filesType, sortType: sortType, paginationEnd: paginationEnd, firstPage: firstPage, pageRemoteItems: pageRemoteItems, notAllowedMD5: notAllowedMD5, notAllowedLocalIDs: notAllowedLocalIDs, filesCallBack: filesCallBack)
//                    }
//                }
//            } else {
//                filesCallBack(localFiltered.map{WrapData(mediaItem: $0)})
//            }
//        } else {
//            guard let lastRemoteItem = pageRemoteItems.last,
//                let firstRemoteItem = pageRemoteItems.first,
//                let localFiltered = arrayLocalItems.filtered(using: getSortingPredicate(sortType: sortType, firstItem: firstRemoteItem, lastItem: lastRemoteItem)) as? [MediaItem],
//                !originalAssetsBeingAppended.assets(beforeDate: lastRemoteItem.metaDate, afterDate: firstRemoteItem.metaDate, mediaType: filesType.convertedToPHMediaType).isEmpty else {
//                filesCallBack([])
//                return
//            }
//            
//            debugPrint("!LOCAL MIDDLE")
//            if inProcessAppendingLocalFiles {
//                if let lastAppendedToDBItemDate = localDataBaseItems.last?.creationDateValue as? Date,
//                firstRemoteItem.metaDate > lastAppendedToDBItemDate{
//                    debugPrint("!LOCAL MIDDLE files founded \(localFiltered.count), original count \(arrayLocalItems.count)")
//                    filesCallBack(localFiltered.map{WrapData(mediaItem: $0)})
//                } else {
//                    pageAppendedCallBack = { [weak self] localItems in
//                        guard let `self` = self,
//                            let lastAppendedToDBItemDate = localItems.last?.metaDate,
//                            firstRemoteItem.metaDate < lastAppendedToDBItemDate
//                             else {
//                            filesCallBack([])
//                            return
//                        }
//                        self.pageAppendedCallBack = nil
//                        self.getLocalFilesForPhotoVideoPage(filesType: filesType, sortType: sortType, paginationEnd: paginationEnd, firstPage: firstPage, pageRemoteItems: pageRemoteItems, notAllowedMD5: notAllowedMD5, notAllowedLocalIDs: notAllowedLocalIDs, filesCallBack: filesCallBack)
//                    }
//                }
//            } else {
//                filesCallBack(localFiltered.map{WrapData(mediaItem: $0)})
//            }
//        }
    }
    
    private func save(items: [PHAsset], context: NSManagedObjectContext, completion: @escaping ()->Void ) {
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
                            let wrapedItem =  WrapData(info: element)
                            _ = MediaItem(wrapData: wrapedItem, context: context)
                            
                            addedObjects.append(wrapedItem)
                        }
                    }
                    
                    self?.saveDataForContext(context: context, saveAndWait: true, savedCallBack: { [weak self] in
                        debugPrint("LOCAL_ITEMS: Saved to Context")
                        log.debug("LocalMediaItem saveDataForContext(")
                        self?.pageAppendedCallBack?(addedObjects)
                    })
                    
                    ItemOperationManager.default.addedLocalFiles(items: addedObjects)//TODO: Seems like we need it to update page after photoTake
                    print("LOCAL_ITEMS: page has been added in \(Date().timeIntervalSince(start)) secs")
                    self?.save(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
                }
            })
        }
    }
    
    private func listAssetIdIsNotSaved(allList: [PHAsset], context: NSManagedObjectContext) -> [PHAsset] {
        let currentlyInLibriaryIDs: [String] = allList.compactMap { $0.localIdentifier }
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        let alredySaved: [MediaItem] = executeRequest(predicate: predicate, context: context)
        
        let alredySavedIDs = alredySaved.compactMap { $0.localFileID }
        
        checkLocalFilesExistence(actualPhotoLibItemsIDs: currentlyInLibriaryIDs, context: context)
        
        return allList.filter { !alredySavedIDs.contains( $0.localIdentifier ) }
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
    
    func  allLocalItems() -> [WrapData] {
//        let context = mainContext
//        let predicate = NSPredicate(format: "localFileID != nil")
//        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
//        return items.flatMap { $0.wrapedObject }
        return []
    }
    
    func  allLocalItems(with localIds: [String]) -> [WrapData] {
//        let context = mainContext
//        let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@)", localIds)
//        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
//        return items.flatMap { $0.wrapedObject }
        return []
    }
    
    func  allLocalItems(withUUIDS uuids: [String]) -> [WrapData] {
        let context = mainContext
        let predicate = NSPredicate(format: "(uuidValue IN %@)", uuids)
        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
        return items.flatMap { $0.wrapedObject }
    }
    
    func hasLocalItemsForSync(video: Bool, image: Bool) -> Bool {
        let items = getUnsyncsedMediaItems(video: video, image: image)

        let currentUserID = SingletonStorage.shared.unigueUserID
        
        let filteredArray = items.filter {
            
            !$0.syncStatusesArray.contains(currentUserID)
        }
        
        return !filteredArray.isEmpty
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool) -> [WrapData] {
        let items = getUnsyncsedMediaItems(video: video, image: image)
        
        let sortedItems = items.sorted { item1, item2 -> Bool in
            item1.fileSizeValue < item2.fileSizeValue
        }
        let currentUserID = SingletonStorage.shared.unigueUserID
        
        let filtredArray = sortedItems.filter {
            
            !$0.syncStatusesArray.contains(currentUserID)
        }
        
        return filtredArray.flatMap { $0.wrapedObject }
    }
    
    private func getUnsyncsedMediaItems(video: Bool, image: Bool) -> [MediaItem] {
        let assetList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
        let currentlyInLibriaryLocalIDs: [String] = assetList.flatMap { $0.localIdentifier }
        
        var filesTypesArray = [Int16]()
        if (video) {
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image) {
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }
        
        let context = backgroundContext
        let predicate = NSPredicate(format: "(isLocalItemValue == true) AND (fileTypeValue IN %@) AND (localFileID IN %@)", filesTypesArray, currentlyInLibriaryLocalIDs)
        return executeRequest(predicate: predicate, context: context)
    }
    
    func checkLocalFilesExistence(actualPhotoLibItemsIDs: [String], context: NSManagedObjectContext) {
        context.perform { [weak self] in
            guard let `self` = self else {
                return
            }
            let predicate = NSPredicate(format: "localFileID != Nil AND NOT (localFileID IN %@)", actualPhotoLibItemsIDs)
            let allNonAccurateSavedLocalFiles: [MediaItem] = self.executeRequest(predicate: predicate,
                                                                            context: context)
            allNonAccurateSavedLocalFiles.forEach {
                context.delete($0)
            }
            let items = allNonAccurateSavedLocalFiles.map { $0.wrapedObject }
            ItemOperationManager.default.deleteItems(items: items)
        }
    }
}
