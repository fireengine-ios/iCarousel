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
    
    @objc func appendLocalMediaItems() {
        let queue = DispatchQueue(label: "Append Local Item ")
        queue.async {
            let localMediaStorage = LocalMediaStorage.default
            localMediaStorage.askPermissionForPhotoFramework{ status in
                if status == .authorized {
                    self.insertFromPhotoFramework()
                }
            }
        }
    }
    
    private func insertFromPhotoFramework() {
        let localMediaStorage = LocalMediaStorage.default
        let localStorageIsAvalible = localMediaStorage.photoIsAvalible()
        if (localStorageIsAvalible) {
            let assetsList = localMediaStorage.getAllImagesAndVideoAssets()
            
            let notSaved = listAssetIdIsNotSaved(allList: assetsList)
            let newBgcontext = newChildBackgroundContext
            
            notSaved.forEach {
                
                let info = localMediaStorage.fullInfoAboutAsset(asset: $0)
                
                let baseMediaContent = BaseMediaContent(curentAsset: $0,
                                                        urlToFile: info.url,
                                                        size: info.size,
                                                        md5: info.md5)
                
                let wrapData = WrapData(baseModel: baseMediaContent)
                _ = MediaItem(wrapData: wrapData, context:newBgcontext )
            }
            
            saveDataForContext(context: newBgcontext, saveAndWait: true)
        }
    }
    
    private func listAssetIdIsNotSaved(allList:[PHAsset]) -> [PHAsset] {
        let list:[String] = allList.flatMap{ $0.localIdentifier }
        let predicate = NSPredicate(format: "localFileID IN %@", list)
        let alredySaved:[MediaItem] = executeRequest(predicate: predicate, context:rootBackgroundContext)
        
        let result = alredySaved.flatMap{ $0.localFileID }
        return allList.filter { !result.contains( $0.localIdentifier )}
    }
        
    func localStorageContains(assetId: String) -> Bool {
        
        let context = mainContext
        let predicate = NSPredicate(format: "localFileID == %@", assetId)
        let items:[MediaItem] = executeRequest(predicate: predicate, context:context)
        
        return Bool(items.count != 0)
    }
        
    func removeLocalMediaItemswithAssetID(list: [String]) {
        let context = newChildBackgroundContext
        let predicate = NSPredicate(format: "localFileID IN %@", list)
        let items:[MediaItem] = executeRequest(predicate: predicate, context:context)
        items.forEach { context.delete($0) }
        
        saveDataForContext(context: context)
    }
    
    func  allLocalItem() -> [WrapData] {
        let context = mainContext
        let predicate = NSPredicate(format: "localFileID != nil")
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
        return items.flatMap{ $0.wrapedObject }
    }
}
