//
//  LocalMediaItems.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/26/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import Photos

extension CoreDataStack {
    
    @objc func appendLocalMediaItems(_ end: AppendingLocaclItemsFinishCallback?) {
        let queue = DispatchQueue(label: "Append Local Item ")
        queue.async {
            let localMediaStorage = LocalMediaStorage.default
            localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { (authorized, status) in
                if authorized {
                    self.insertFromPhotoFramework(allItemsAddedCallBack: end)
                }
                if status == .denied {
                    self.deleteLocalFiles()
                    end?()
                }
            }
        }
    }
    
    func insertFromPhotoFramework(allItemsAddedCallBack: AppendingLocaclItemsFinishCallback?) {
        let localMediaStorage = LocalMediaStorage.default
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] (accessGranted, _) in
            guard accessGranted, let `self` = self,
                !self.inProcessAppendingLocalFiles else {
                return
            }
            
            self.inProcessAppendingLocalFiles = true
            
            let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
            
            let newBgcontext = self.newChildBackgroundContext
            let notSaved = self.listAssetIdIsNotSaved(allList: assetsList, context: newBgcontext)
            
            debugPrint("number of not saved  ", notSaved.count)
            let start = Date().timeIntervalSince1970
            var i = 0
            var addedObjects = [WrapData]()
            notSaved.forEach {
                i += 1
                debugPrint("local ", i)
                let info = localMediaStorage.shortInfoAboutAsset(asset: $0)
                
                let baseMediaContent = BaseMediaContent(curentAsset: $0,
                                                        urlToFile: info.url,
                                                        size: info.size,
                                                        md5: info.md5)
                
                let wrapData = WrapData(baseModel: baseMediaContent)
                _ = MediaItem(wrapData: wrapData, context:newBgcontext)
                debugPrint(i)
                
                if i % 10 == 0 {
                    self.saveDataForContext(context: newBgcontext, saveAndWait: true)
                }
                
                addedObjects.append(wrapData)
            }
            
            self.saveDataForContext(context: newBgcontext, saveAndWait: true)
//            self.isAppendingLocalFilesFinished = true
//            self.appendingItemsFinishBlock?()
            self.inProcessAppendingLocalFiles = false
            allItemsAddedCallBack?()
            let finish = Date().timeIntervalSince1970
            debugPrint("All images and videos have been saved in \(finish - start) seconds")
            
            ItemOperationManager.default.addedLocalFiles(items: addedObjects)
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
        
    func localStorageContains(assetId: String) -> Bool {
        
        let context = mainContext
        let predicate = NSPredicate(format: "localFileID == %@", assetId)
        let items:[MediaItem] = executeRequest(predicate: predicate, context:context)
        
        return Bool(items.count != 0)
    }
        
    func removeLocalMediaItemswithAssetID(list: [String]) {
        guard list.count > 0 else {
            return
        }
        DispatchQueue.main.async {
            let context = self.mainContext//newChildBackgroundContext
            let predicate = NSPredicate(format: "localFileID IN %@", list)
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
    
    func allLocalNotSyncedItems(md5Array: [String], video: Bool, image: Bool) -> [WrapData] {
        var filesTypesArray = [Int16]()
        if (video){
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image){
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }
        let context = mainContext
        let predicate = NSPredicate(format: "NOT (md5Value IN %@) AND (isLocalItemValue == true) AND (fileTypeValue IN %@)",  md5Array, filesTypesArray)
        let items: [MediaItem] =  executeRequest(predicate: predicate, context:context)
        let sortedItems = items.sorted { (item1, item2) -> Bool in
            //< correct
            return item1.fileSizeValue < item2.fileSizeValue
        }
        return sortedItems.flatMap{ $0.wrapedObject }
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool) -> [WrapData] {
        var filesTypesArray = [Int16]()
        if (video){
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image){
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }
        let context = mainContext
        let predicate = NSPredicate(format: "(isLocalItemValue == true) AND (fileTypeValue IN %@)", filesTypesArray)
        let items: [MediaItem] =  executeRequest(predicate: predicate, context:context)
        let sortedItems = items.sorted { (item1, item2) -> Bool in
            //< correct
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
