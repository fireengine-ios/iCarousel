//
//  LocalMediaItems.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/26/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos

struct MetaAssetInfo {
    var asset: PHAsset
    var url: URL
    var fileSize = UInt64(0)
    var originalName = ""
    var md5: String {
        return "\(originalName)\(fileSize)"
    }
}

typealias LocalFilesCallBack = (_ localFiles: [WrapData]) -> Void

extension CoreDataStack {

    @objc func appendLocalMediaItems() {
        let localMediaStorage = LocalMediaStorage.default
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { (authorized, status) in
            if authorized {
                self.insertFromGallery()
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

    func insertFromGallery() {
        guard !inProcessAppendingLocalFiles else {
            return
        }
        
        inProcessAppendingLocalFiles = true
        
        let localMediaStorage = LocalMediaStorage.default

        let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
        let notSaved = listAssetIdIsNotSaved(allList: assetsList, context: backgroundContext)
    
        let start = Date()
        
        guard !notSaved.isEmpty else {
            inProcessAppendingLocalFiles = false
            print("All local files added in \(Date().timeIntervalSince(start)) seconds")
            NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
            return
        }
        print("All local files started  \((start)) seconds")
        save(items: notSaved, context: backgroundContext) { [weak self] in
            print("All local files added in \(Date().timeIntervalSince(start)) seconds")
            self?.inProcessAppendingLocalFiles = false
            NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
        }
    }

    func getLocalFilesForPhotoVideoPage(filesType: FileType, sortType: SortedRules,
                       pageRemoteItems: [Item], paginationEnd: Bool,
                       firstPage: Bool,
                       filesCallBack: @escaping LocalFilesCallBack) {
        
        log.debug("getLocalFilesForPhotoVideoPage()")
        let requestContext = newChildBackgroundContext
        
        
        let request = NSFetchRequest<MediaItem>()
        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                    in: requestContext)
        
        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
        
        if pageRemoteItems.isEmpty {
            if let localItems = try? requestContext.fetch(request),
                (localItems.count >= NumericConstants.numberOfLocalFilesPage || !inProcessAppendingLocalFiles) {
                
                log.debug("pageRemoteItems.isEmpty let localItems = try? backgroundContext.fetch(request)")
                let wrapedLocalItems = localItems.map{return WrapData(mediaItem: $0)}
                filesCallBack(wrapedLocalItems)
            } else {
               
                pageAppendedCallBack = { [weak self] localItems in
//                    log.info("pageRemoteItems.isEmpty pageAppendedCallBack")
//                    log.debug("pageRemoteItems.isEmpty pageAppendedCallBack")
                    filesCallBack([])
                    self?.pageAppendedCallBack = nil
//                    self?.getLocalFilesForPhotoVideoPage(filesType: filesType, sortType: sortType, pageRemoteItems: pageRemoteItems, paginationEnd: paginationEnd, firstPage: firstPage, filesCallBack: filesCallBack)
                }
            }
            return
        } else if pageRemoteItems.count == 1, paginationEnd, //if there same md5 but later - will be error
            let lastItem = pageRemoteItems.last {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, getSortingPredicateLastPage(sortType: sortType, lastItem: lastItem)])
            if let localItems = try? requestContext.fetch(request) {
                
                log.debug("pageRemoteItems.count == 1, paginationEnd ")
                if lastItem.isLocalItem {//
                    if (localItems.count >= NumericConstants.numberOfLocalFilesPage || !inProcessAppendingLocalFiles) {

                        log.debug("pageRemoteItems.count == 1, paginationEnd lastItem.isLocalItem localItems.count >= NumericConstants.numberOfLocalFilesPage || !inProcessAppendingLocalFiles")
                        let wrapedLocalItems = localItems.map{return WrapData(mediaItem: $0)}
                        filesCallBack(wrapedLocalItems)
                    } else {
                        pageAppendedCallBack = { [weak self] localItems in
                            
                            log.debug("pageRemoteItems.count == 1, paginationEnd pageAppendedCallBack")
                            filesCallBack([])
                            self?.pageAppendedCallBack = nil
//                            self?.getLocalFilesForPhotoVideoPage(filesType: filesType, sortType: sortType, pageRemoteItems: pageRemoteItems, paginationEnd: paginationEnd, firstPage: firstPage, filesCallBack: filesCallBack)
                        }
                    }
     
                } else {
                    log.info("pageRemoteItems.count == 1, paginationEnd not lastItem.isLocalItem ")
                    log.debug("pageRemoteItems.count == 1, paginationEnd not lastItem.isLocalItem ")
                    let wrapedLocalItems = localItems.map{return WrapData(mediaItem: $0)}
                    filesCallBack(wrapedLocalItems)
                }
            }
            
            return
        } else if firstPage {
            log.info("firstPage")
            log.debug("firstPage ")
            if let lastRemoteItem = pageRemoteItems.last {
                
                log.info("firstPage lastRemoteItem")
                log.debug("firstPage lastRemoteItem")
                var md5s = [String]()
                var uuids = [String]()
                pageRemoteItems.forEach{
                    md5s.append($0.md5)
                    let splitedUuid = $0.uuid.split(separator: "~")
                    if let localID = splitedUuid.first {
                        uuids.append(String(localID))
                    }
                }
                

                let basePredicateString = NSPredicate(format: "NOT (md5Value IN %@ OR localFileID IN %@)", md5s, uuids)
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, getSortingPredicateFirstPage(sortType: sortType, lastItem: lastRemoteItem), basePredicateString])
                if let localItems = try? requestContext.fetch(request) {
                    let wrapedLocalItems = localItems.map{return WrapData(mediaItem: $0)}
                    filesCallBack(wrapedLocalItems)
                }

            }
            return
            
        }

        var md5s = [String]()
        var uuids = [String]()
        pageRemoteItems.forEach{
            md5s.append($0.md5)
            let splitedUuid = $0.uuid.split(separator: "~")
            if let localID = splitedUuid.first {
                uuids.append(String(localID))
            }
        }

        let basePredicateString = NSPredicate(format: "NOT (md5Value IN %@ OR localFileID IN %@)", md5s, uuids)
        
        var datePredicate = NSPredicate()
        
        if let lastRemoteItem = pageRemoteItems.last, let firstItem = pageRemoteItems.first {
            datePredicate = getSortingPredicate(sortType: sortType, firstItem: firstItem, lastItem: lastRemoteItem)
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicateString, fileTypePredicate, datePredicate])
        
    
        
        if let localItems = try? requestContext.fetch(request), (localItems.count >= NumericConstants.numberOfLocalFilesPage || !inProcessAppendingLocalFiles) {
            log.info("let localItems = try? backgroundContext.fetch(request)")
            log.debug("let localItems = try? backgroundContext.fetch(request) ")
            let wrapedLocalItems = localItems.map{return WrapData(mediaItem: $0)}
            filesCallBack(wrapedLocalItems)
        } else {
            pageAppendedCallBack = { [weak self] localItems in
                log.info("let localItems = try? backgroundContext.fetch(request) pageAppendedCallBack")
                log.debug("let localItems = try? backgroundContext.fetch(request)  pageAppendedCallBack")
//                debugPrint("callback")
                filesCallBack([])
                self?.pageAppendedCallBack = nil
//                self?.getLocalFilesForPhotoVideoPage(filesType: filesType, sortType: sortType, pageRemoteItems: pageRemoteItems, paginationEnd: paginationEnd, firstPage: firstPage, filesCallBack: filesCallBack)
            }
            //we realize finishing or progress build here
        }

    }
    
//    private func perfor
    
    private func getSortingPredicate(sortType: SortedRules, firstItem: Item,  lastItem: Item) -> NSPredicate {
        switch sortType {
            case .timeUp, .timeUpWithoutSection:
                return NSPredicate(format: "creationDateValue > %@ AND creationDateValue < %@",
                                   (lastItem.creationDate ?? Date()) as NSDate, (firstItem.creationDate ?? Date()) as NSDate)
            case .timeDown, .timeDownWithoutSection:
                return NSPredicate(format: "creationDateValue < %@ AND creationDateValue > %@", (lastItem.creationDate ?? Date()) as NSDate, (firstItem.creationDate ?? Date()) as NSDate)
            case .lettersAZ, .albumlettersAZ:
                return NSPredicate(format: "nameValue > %@ AND nameValue < %@",
                                   lastItem.name ?? "", firstItem.name ?? "")
            case .lettersZA, .albumlettersZA:
                return NSPredicate(format: "nameValue < %@ AND nameValue > %@",
                                   lastItem.name ?? "", firstItem.name ?? "")
            case .sizeAZ:
                return NSPredicate(format: "fileSizeValue > %ui AND fileSizeValue < %ui",
                                   lastItem.fileSize, firstItem.fileSize)
            case .sizeZA:
                return NSPredicate(format: "fileSizeValue < %ui AND fileSizeValue > %ui",
                                   lastItem.fileSize, firstItem.fileSize)
            case .metaDataTimeUp:
                return NSPredicate(format: "creationDateValue > %@ AND creationDateValue < %@",
                                   lastItem.metaDate as NSDate, firstItem.metaDate as NSDate)
            case .metaDataTimeDown:
                return NSPredicate(format: "creationDateValue < %@ AND creationDateValue > %@",
                                   lastItem.metaDate as NSDate, firstItem.metaDate as NSDate)
            }
    }
    
    private func getSortingPredicateLastPage(sortType: SortedRules, lastItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue < %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue > %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue < %@", lastItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue > %@", lastItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue < %ui", lastItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue > %ui", lastItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue < %@", lastItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue > %@", lastItem.metaDate as NSDate)
        }
    }
    
    private func getSortingPredicateFirstPage(sortType: SortedRules, lastItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue > %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue < %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue > %@", lastItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue < %@", lastItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue > %ui", lastItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue < %ui", lastItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue > %@", lastItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue < %@", lastItem.metaDate as NSDate)
        }
    }
    
    private func save(items: [PHAsset], context: NSManagedObjectContext, completion: @escaping ()->Void ) {
        guard !items.isEmpty else {
            completion()
            return
        }

        let nextItemsToSave = Array(items.prefix(NumericConstants.numberOfLocalItemsOnPage))
        
        LocalMediaStorage.default.getInfo(from: nextItemsToSave, completion: { [weak self] assetsInfo in
            context.perform { [weak self] in
                var addedObjects = [WrapData]()
                assetsInfo.forEach { element in
                    autoreleasepool {
                        let wrapedItem =  WrapData(info: element)
                        log.debug("LocalMediaItem save(items: assetsInfo.forEach { element in")
                        _ = MediaItem(wrapData: wrapedItem, context: context)
                        
                        addedObjects.append(wrapedItem)
                    }
                }
                
                self?.saveDataForContext(context: context, saveAndWait: true)
                log.debug("LocalMediaItem saveDataForContext(")
                ItemOperationManager.default.addedLocalFiles(items: addedObjects)//TODO: Seems like we need it to update page after photoTake
                
                
                self?.pageAppendedCallBack?(addedObjects)
                
                print("local files added: \(assetsInfo.count)")
                
                self?.save(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
                
                
            }
        })
        
    }
    
    private func listAssetIdIsNotSaved(allList: [PHAsset], context: NSManagedObjectContext) -> [PHAsset] {
        let currentlyInLibriaryIDs: [String] = allList.flatMap { $0.localIdentifier }
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        let alredySaved: [MediaItem] = executeRequest(predicate: predicate, context: context)
        
        let alredySavedIDs = alredySaved.flatMap { $0.localFileID }
        
        checkLocalFilesExistence(actualPhotoLibItemsIDs: currentlyInLibriaryIDs, context: context)
        
        return allList.filter { !alredySavedIDs.contains( $0.localIdentifier ) }
    }
    
    func removeLocalMediaItems(with assetIdList: [String]) {
        guard assetIdList.count > 0 else {
            return
        }
        backgroundContext.perform { [weak self] in
            guard let `self` = self else {
                return
            }
//            let context = self.mainContext//newChildBackgroundContext
            
            let predicate = NSPredicate(format: "localFileID IN %@", assetIdList)
            let items:[MediaItem] = self.executeRequest(predicate: predicate, context: self.backgroundContext)
            
            items.forEach { self.backgroundContext.delete($0) }
            
            self.saveDataForContext(context: self.backgroundContext)
        }
        
        
        
    }
    
    func  allLocalItems() -> [WrapData] {
        let context = mainContext
        let predicate = NSPredicate(format: "localFileID != nil")
        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
        return items.flatMap { $0.wrapedObject }
    }
    
    func  allLocalItems(with localIds: [String]) -> [WrapData] {
        let context = mainContext
        let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@)", localIds)
        let items: [MediaItem] = executeRequest(predicate: predicate, context: context)
        return items.flatMap { $0.wrapedObject }
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool) -> [WrapData] {
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
        let items: [MediaItem] =  executeRequest(predicate: predicate, context: context)
        let sortedItems = items.sorted { item1, item2 -> Bool in
            item1.fileSizeValue < item2.fileSizeValue
        }
        let currentUserID = SingletonStorage.shared.unigueUserID
        
        let filtredArray = sortedItems.filter {
            
            !$0.syncStatusesArray.contains(currentUserID)
        }
        
        return filtredArray.flatMap { $0.wrapedObject }
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
