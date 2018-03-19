//
//  MediaItemOperations.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/19/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

extension CoreDataStack {
    
    // FIXME: maybe delete and commented code used appendOnlyNewItems
//    func appendOnlyNewItems(items: [WrapData]) {
//        DispatchQueue.main.async {
//            let uuidList = items.map{ $0.uuid }
//            let predicateForRemoteFile = NSPredicate(format: "uuidValue IN %@", uuidList)
//            
//            let childrenContext = self.mainContext//backgroundContext
//            
//            let alreadySavedMediaItems = self.executeRequest(predicate: predicateForRemoteFile, context: childrenContext)
//            
//            self.updateSavedItems(savedItems: alreadySavedMediaItems, remoteItems: items, context: childrenContext)
//            
//            let inCoreData = alreadySavedMediaItems.flatMap{ $0.uuidValue }
//            
//            let appendItems = items.filter { !inCoreData.contains($0.uuid) }
//            
//            if appendItems.count == 0 {
//                return
//            }
//            
//            appendItems.forEach {
//                _ = MediaItem(wrapData: $0, context: childrenContext)
//            }
//            
//            self.saveDataForContext(context: childrenContext, saveAndWait: true)
//        }
//    }
    
    func updateSavedItems(savedItems: [MediaItem], remoteItems: [WrapData], context: NSManagedObjectContext) {
        guard savedItems.count > 0 else {
            return
        }
        for savedMediaItem in savedItems {
            for remoteWrapedItem in remoteItems {
                if savedMediaItem.uuidValue == remoteWrapedItem.uuid {
                    if let unwrapedParent = remoteWrapedItem.parent {
                        savedMediaItem.parent = unwrapedParent
                    }
                    if let unwrapedAlbumbs = remoteWrapedItem.albums {
                        //LR-2356
                        let albums = unwrapedAlbumbs.map({ albumUuid -> MediaItemsAlbum in
                            MediaItemsAlbum(uuid: albumUuid, context: context)
                        })
                        savedMediaItem.albums = NSOrderedSet(array: albums)
                    }
                    savedMediaItem.urlToFileValue = remoteWrapedItem.urlToFile?.absoluteString
                    savedMediaItem.metadata?.largeUrl = remoteWrapedItem.metaData?.largeUrl?.absoluteString
                    savedMediaItem.metadata?.mediumUrl = remoteWrapedItem.metaData?.mediumUrl?.absoluteString
                    savedMediaItem.metadata?.smalURl = remoteWrapedItem.metaData?.smalURl?.absoluteString
                    savedMediaItem.favoritesValue = remoteWrapedItem.favorites
                    
                    savedMediaItem.syncStatusValue = remoteWrapedItem.syncStatus.valueForCoreDataMapping()
                    
                    break
                }
            }
        }
        saveDataForContext(context: context)
    }
    
    func updateLocalItemSyncStatus(item: Item) {
        backgroundContext.perform { [weak self] in
            
            guard let `self` = self else {
                return
            }
            
            let predicateForRemoteFile = NSPredicate(format: "uuidValue == %@", item.uuid)
            let alreadySavedMediaItems = self.executeRequest(predicate: predicateForRemoteFile, context: self.mainContext)
            
            alreadySavedMediaItems.forEach({ savedItem in
                //for locals
                savedItem.syncStatusValue = item.syncStatus.valueForCoreDataMapping()
                
                if savedItem.objectSyncStatus != nil {
                    savedItem.objectSyncStatus = nil
                }
                
                var array = [MediaItemsObjectSyncStatus]()
                for userID in item.syncStatuses {
                    array.append(MediaItemsObjectSyncStatus(userID: userID, context: self.mainContext))
                }
                savedItem.objectSyncStatus = NSSet(array: array)
                
                //savedItem.objectSyncStatus?.addingObjects(from: item.syncStatuses)
            })
            self.saveDataForContext(context: self.mainContext)
        }
    }
    
    
    // MARK: MediaItem
    
    func mediaItemByUUIDs(uuidList: [String]) -> [MediaItem] {
        let predicate = NSPredicate(format: "uuidValue IN %@", uuidList)
        return executeRequest(predicate: predicate, context: mainContext)
    }
    
    func executeRequest(predicate: NSPredicate, context: NSManagedObjectContext) -> [MediaItem] {
        var result: [MediaItem] = []
        do {
            let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
            request.predicate = predicate
            result = try context.fetch(request)
        } catch {
            print("exeption Coredata  ")
        }
        return result
    }
    
}
