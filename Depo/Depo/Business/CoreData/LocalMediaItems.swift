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
        }
    }
    
    func save(items: [PHAsset], context: NSManagedObjectContext, completion: @escaping ()->Void ) {
        guard !items.isEmpty else {
            completion()
            return
        }

        let nextItemsToSave = Array(items.prefix(NumericConstants.numberOfLocalItemsOnPage))

        DispatchQueue(label: "com.lifebox.saveFromGallery").async {
            LocalMediaStorage.default.getInfo(from: nextItemsToSave, completion: { [weak self] (assetsInfo) in
                //assetsInfo.count can be less than pageItems.count
                var addedObjects = [WrapData]()
                assetsInfo.forEach {
                    let wrapedItem =  WrapData(info: $0)
                    _ = MediaItem(wrapData: wrapedItem, context: context)
                    
                    self?.saveDataForContext(context: context, saveAndWait: true)
                    addedObjects.append(wrapedItem)
                }
                ItemOperationManager.default.addedLocalFiles(items: addedObjects)
                
                self?.save(items: Array(items.dropFirst(nextItemsToSave.count)), context: context, completion: completion)
            })
        }
    }
    
    
//    func insertFromPhotoFramework(progress: AppendingLocaclItemsProgressCallback?,
//                                  allItemsAddedCallBack: AppendingLocaclItemsFinishCallback?) {
//        let localMediaStorage = LocalMediaStorage.default
//        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] (accessGranted, _) in
//            guard accessGranted, let `self` = self,
//                !self.inProcessAppendingLocalFiles else {
//                return
//            }
//
//            self.inProcessAppendingLocalFiles = true
//
//            let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
//
//            let newBgcontext = self.newChildBackgroundContext
//            let notSaved = self.listAssetIdIsNotSaved(allList: assetsList, context: newBgcontext)
//
//            let start = Date().timeIntervalSince1970
//            var i = 0
//            var addedObjects = [WrapData]()
//
//            let totalNotSavedItems = Float(notSaved.count)
//            debugPrint("number of not saved  ", totalNotSavedItems)
//
//            notSaved.forEach {
//                i += 1
//                debugPrint("local ", i)
//
//                let wrapedItem =  WrapData(asset: $0)
//                _ = MediaItem(wrapData: wrapedItem, context:newBgcontext)
//
//                if i % 10 == 0 {
//                    self.saveDataForContext(context: newBgcontext, saveAndWait: true)
//                }
//                addedObjects.append(wrapedItem)
//
//                progress?(Float(i)/totalNotSavedItems)
//            }
//
//            self.saveDataForContext(context: newBgcontext, saveAndWait: true)
//
//            self.inProcessAppendingLocalFiles = false
//            allItemsAddedCallBack?()
//
//            let finish = Date().timeIntervalSince1970
//            debugPrint("All images and videos have been saved in \(finish - start) seconds")
//
//            ItemOperationManager.default.addedLocalFiles(items: addedObjects)
//        }
//
//    }
    
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
