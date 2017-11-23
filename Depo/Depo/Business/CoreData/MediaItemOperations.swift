//
//  MediaItemOperations.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/19/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

extension CoreDataStack {
    
    func appendOnlyNewItems(items: [WrapData] ) {
        
        let uuidList = items.map{ $0.uuid }
        let predicateForRemoteFile = NSPredicate(format: "uuidValue IN %@", uuidList)
        
        let childrenContext = backgroundContext
 
        let alreadySavedMediaItems = executeRequest(predicate: predicateForRemoteFile, context: childrenContext)
        
        updateSavedItems(savedItems: alreadySavedMediaItems, remoteItems: items, context: childrenContext)
        
        let inCoreData = alreadySavedMediaItems.flatMap{ $0.uuidValue }
        
        let appendItems = items.filter { !inCoreData.contains($0.uuid) }
        
        if appendItems.count == 0 {
            return
        }
        
        appendItems.forEach {
            _ = MediaItem(wrapData: $0, context: childrenContext)
        }
        
        saveDataForContext(context: childrenContext, saveAndWait: true)
    }
    
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
                        let albums = unwrapedAlbumbs.map({ (albumUuid) -> MediaItemsAlbum in
                            return MediaItemsAlbum(uuid: albumUuid, context: context)
                        })
                        savedMediaItem.albums = NSOrderedSet(array: albums)
                    }
                    savedMediaItem.urlToFileValue = remoteWrapedItem.urlToFile?.absoluteString
                    savedMediaItem.metadata?.largeUrl = remoteWrapedItem.metaData?.largeUrl?.absoluteString
                    savedMediaItem.metadata?.mediumUrl = remoteWrapedItem.metaData?.mediumUrl?.absoluteString
                    savedMediaItem.metadata?.smalURl = remoteWrapedItem.metaData?.smalURl?.absoluteString
                    savedMediaItem.favoritesValue = remoteWrapedItem.favorites
                    
                    
                    break
                }
            }
        }
        saveDataForContext(context: context)
    }
    
    func updateLocalItemSyncStatus(item: Item) {
        let predicateForRemoteFile = NSPredicate(format: "uuidValue == %@", item.uuid)
        let alreadySavedMediaItems = executeRequest(predicate: predicateForRemoteFile, context: backgroundContext)
        
        alreadySavedMediaItems.forEach({ savedItem in
            //for locals
            savedItem.syncStatusValue = item.syncStatus.valueForCoreDataMapping()
        })
        saveDataForContext(context: backgroundContext)
    }
    
    func removeFromStorage(wrapData: [WrapData]) {
        
        //let context = mainContext
        //wrapData.forEach {
            //context.delete( $0.coreDataObject! )
        //}
        //saveDataForContext(context: context, saveAndWait: true)
    }
    
    
    // MARK:  MediaItem
    
    func mediaItemByUUIDs(uuidList: [String]) -> [WrapData] {
        
        let context = mainContext
        let predicate = NSPredicate(format: "uuidValue IN %@", uuidList)
        let items:[MediaItem] = executeRequest(predicate: predicate, context:context)
        
        return items.flatMap{ $0.wrapedObject }
    }
    
    func executeRequest(predicate: NSPredicate, context:NSManagedObjectContext) -> [MediaItem] {
        var result: [MediaItem] = []
        do {
            let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
            request.predicate = predicate
            result =  try context.fetch(request)
        } catch {
            print("exeption Coredata  ")
        }
        return result
    }
    
}
