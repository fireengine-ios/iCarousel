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

//enum DBSortType {
//    case dateUp(Date?)
//    case dateDown(Date?)
//    case lettersAZ(String?)
//    case lettersZA(String?)
//    case sizeAZ(UInt64?)
//    case sizeZA(UInt64?)
//    case metaDateTimeUp(Date?)
//    case metaDateTimeDown(Date?)
//}

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
        let newBgcontext = self.newChildBackgroundContext
        save(items: localMediaItems, context: newBgcontext, completion: {})
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
        let newBgcontext = self.newChildBackgroundContext
        let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
        let notSaved = self.listAssetIdIsNotSaved(allList: assetsList, context: newBgcontext)
    
        let start = Date()
        
        save(items: notSaved, context: newBgcontext) { [weak self] in
            print("All local files added in \(Date().timeIntervalSince(start)) seconds")
            self?.inProcessAppendingLocalFiles = false
            NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
        }
    }
//
//        DispatchQueue(label: "com.lifebox.localFles").async {
//            let localMediaStorage = LocalMediaStorage.default
//            let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
//            let newBgcontext = self.newChildBackgroundContext
//            let notSaved = self.listAssetIdIsNotSaved(allList: assetsList, context: newBgcontext)
//
//            let start = Date()
//            var addedObjects = [WrapData]()
//
//            let semaphore = DispatchSemaphore(value: 0)
//            var readyItemsCount = 0
////            while readyItemsCount < notSaved.count {
//                let nextItemsAmount = min(notSaved.count - readyItemsCount, NumericConstants.numberOfLocalItemsOnPage)
//                let pageItems = Array(notSaved[readyItemsCount..<nextItemsAmount])
//
//                localMediaStorage.getInfo(from: pageItems, completion: { (assetsInfo) in
//                    assetsInfo.forEach {
//                        let wrapedItem =  WrapData(info: $0)
//                        _ = MediaItem(wrapData: wrapedItem, context:newBgcontext)
//
//                        self.saveDataForContext(context: newBgcontext, saveAndWait: true)
//                        addedObjects.append(wrapedItem)
//                        readyItemsCount += nextItemsAmount
//                    }
//
//                    ItemOperationManager.default.addedLocalFiles(items: addedObjects)
//                    semaphore.signal()
//                })
//                semaphore.wait()
////            }
//
//            debugPrint("All images and videos have been saved in \(Date().timeIntervalSince(start)) seconds")
//            self.inProcessAppendingLocalFiles = false
//        }
//    }
//
    func getLocalFiles(filesType: FileType, sortType: /*DBSortType*/SortedRules,
                       pageUUIDS: [String], pageMD5s: [String],
                       firstRemoteItem: Item?,
                       lastRemoteItem: Item?, paginationEnd: Bool,
                       filesCallBack: @escaping LocalFilesCallBack ) {



    }
//
    func getLocalFilesForPhotoVideoPage(filesType: FileType, sortType: SortedRules,
                       pageRemoteItem: [Item], paginationEnd: Bool,
                       filesCallBack: @escaping LocalFilesCallBack ) {
        var md5s = [String]()
        var uuids = [String]()
        pageRemoteItem.forEach{
            md5s.append($0.md5)
            uuids.append($0.uuid)
        }
        
        let request = NSFetchRequest<MediaItem>()
        
        
        let basePredicateString = NSPredicate(format: "NOT (md5Value IN %@ OR uuidValue IN %@)", md5s, uuids )
        
        var datePredicate = NSPredicate()
        
        if let lastRemoteItem = pageRemoteItem.last {
            //convert to NSPredicate?
            datePredicate = NSPredicate(format: "creationDateValue > %@", lastRemoteItem.metaDate as NSDate)
//            NSPredicate(format: "creationDateValue > %@", lastRemoteItem.metaDate as NSDate)
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicateString, datePredicate])
        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                    in: backgroundContext)
        //NSPredicate(format: "%@ AND %@", basePredicateString, datePredicate )
        
        if let localItems = try? backgroundContext.fetch(request), (localItems.count >= 100 || !inProcessAppendingLocalFiles) {
            let wrapedLocalItems = localItems.map{return WrapData(mediaItem: $0)}
            filesCallBack(wrapedLocalItems)
        } else {
            pageAppendedCallBack = { [weak self] localItems in
                debugPrint("callback")
                filesCallBack(localItems)
                self?.pageAppendedCallBack = nil
            }
            //we realize finishing or progress build here
        }

    }
    
    
    
    private func save(items: [PHAsset], context: NSManagedObjectContext, completion: @escaping ()->Void ) {
        guard !items.isEmpty else {
            completion()
            return
        }

        let nextItemsToSave = Array(items.prefix(NumericConstants.numberOfLocalItemsOnPage))

        
        queue.async {
            LocalMediaStorage.default.getInfo(from: nextItemsToSave, completion: { [weak self] assetsInfo in

                var addedObjects = [WrapData]()
                assetsInfo.forEach {
                    let wrapedItem =  WrapData(info: $0)
                    _ = MediaItem(wrapData: wrapedItem, context: context)
                    
                    addedObjects.append(wrapedItem)
                }
                
                self?.saveDataForContext(context: context, saveAndWait: true)
                ItemOperationManager.default.addedLocalFiles(items: addedObjects)//TODO: Seems like we need it to update page after photoTake
                
                
                self?.pageAppendedCallBack?(addedObjects)
                
                print("local files added: \(assetsInfo.count)")
                
                self?.save(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
            })
        }
    }
    
    private func listAssetIdIsNotSaved(allList: [PHAsset], context: NSManagedObjectContext) -> [PHAsset] {
        let currentlyInLibriaryIDs: [String] = allList.flatMap{ $0.localIdentifier }
        let predicate = NSPredicate(format: "localFileID IN %@", currentlyInLibriaryIDs)
        let alredySaved: [MediaItem] = executeRequest(predicate: predicate, context: context)
        
        let alredySavedIDs = alredySaved.flatMap{ $0.localFileID }
        
        checkLocalFilesExistence(actualPhotoLibItemsIDs: currentlyInLibriaryIDs, context:context)
        
        return allList.filter { !alredySavedIDs.contains( $0.localIdentifier )}
    }
        
    /// maybe will be need
//    func localStorageContains(assetId: String) -> Bool {
//        
//        let context = mainContext
//        let predicate = NSPredicate(format: "localFileID == %@", assetId)
//        let items:[MediaItem] = executeRequest(predicate: predicate, context:context)
//        
//        return Bool(items.count != 0)
//    }
        
    func removeLocalMediaItems(with assetIdList: [String]) {
        guard assetIdList.count > 0 else {
            return
        }
        DispatchQueue.main.async {
            let context = self.mainContext//newChildBackgroundContext
            let predicate = NSPredicate(format: "localFileID IN %@", assetIdList)
            let items:[MediaItem] = self.executeRequest(predicate: predicate, context:context)
            items.forEach { context.delete($0) }
            
            self.saveDataForContext(context: context)
        }
        
    }
    
    func  allLocalItems() -> [WrapData] {
        let context = mainContext
        let predicate = NSPredicate(format: "localFileID != nil")
        let items:[MediaItem] = executeRequest(predicate: predicate, context:context)
        return items.flatMap{ $0.wrapedObject }
    }
    
    func  allLocalItems(with localIds: [String]) -> [WrapData] {
        let context = mainContext
        let predicate = NSPredicate(format: "(localFileID != nil) AND (localFileID IN %@)", localIds)
        let items:[MediaItem] = executeRequest(predicate: predicate, context:context)
        return items.flatMap{ $0.wrapedObject }
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool) -> [WrapData] {
        let assetList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
        let currentlyInLibriaryLocalIDs: [String] = assetList.flatMap{ $0.localIdentifier }
        
        var filesTypesArray = [Int16]()
        if (video){
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image){
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }

        let context = mainContext
        let predicate = NSPredicate(format: "(isLocalItemValue == true) AND (fileTypeValue IN %@) AND (localFileID IN %@)", filesTypesArray, currentlyInLibriaryLocalIDs)
        let items: [MediaItem] =  executeRequest(predicate: predicate, context:context)
        let sortedItems = items.sorted { (item1, item2) -> Bool in
            return item1.fileSizeValue < item2.fileSizeValue
        }
        let currentUserID = SingletonStorage.shared.unigueUserID
        
        let filtredArray = sortedItems.filter {
            
            return !$0.syncStatusesArray.contains(currentUserID)
        }
        
        return filtredArray.flatMap{ $0.wrapedObject }
    }
    
    func checkLocalFilesExistence(actualPhotoLibItemsIDs: [String], context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "localFileID != Nil AND NOT (localFileID IN %@)", actualPhotoLibItemsIDs)
        let allNonAccurateSavedLocalFiles: [MediaItem] = executeRequest(predicate: predicate,
                                                            context:context)
        
        allNonAccurateSavedLocalFiles.forEach {
            context.delete($0)
        }
        let items = allNonAccurateSavedLocalFiles.map { $0.wrapedObject }
        ItemOperationManager.default.deleteItems(items: items)
    }
}
