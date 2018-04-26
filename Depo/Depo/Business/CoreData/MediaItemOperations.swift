//
//  MediaItemOperations.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/19/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

extension CoreDataStack {
    
    func updateSavedItems(savedItems: [MediaItem], remoteItems: [WrapData], context: NSManagedObjectContext) {
        guard savedItems.count > 0 else {
            return
        }
        context.perform { [weak self] in
            for savedMediaItem in savedItems {
                for remoteWrapedItem in remoteItems {
                    if savedMediaItem.trimmedLocalFileID == remoteWrapedItem.getTrimmedLocalID() {
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
            self?.saveDataForContext(context: context, savedCallBack: nil)
        }
    }
    
    func updateLocalItemSyncStatus(item: Item) {
        let context = newChildBackgroundContext
        context.perform { [weak self] in
            
            guard let `self` = self else {
                return
            }
            let predicateForRemoteFile = NSPredicate(format: "trimmedLocalFileID == %@", item.getTrimmedLocalID())
            let alreadySavedMediaItems = self.executeRequest(predicate: predicateForRemoteFile, context: context)
                alreadySavedMediaItems.forEach({ savedItem in
                    //for locals
                    savedItem.syncStatusValue = item.syncStatus.valueForCoreDataMapping()
                    
                    if savedItem.objectSyncStatus != nil {
                        savedItem.objectSyncStatus = nil
                    }
                    
                    var array = [MediaItemsObjectSyncStatus]()
                    for userID in item.syncStatuses {
                        array.append(MediaItemsObjectSyncStatus(userID: userID, context: context))
                    }
                    savedItem.objectSyncStatus = NSSet(array: array)
                    
                    //savedItem.objectSyncStatus?.addingObjects(from: item.syncStatuses)
                })
            
            self.saveDataForContext(context: context, savedCallBack: nil)
            
        }
    }
    
    
    // MARK: MediaItem
    
    func mediaItemByLocalID(trimmedLocalIDS: [String]) -> [MediaItem] {
        let predicate = NSPredicate(format: "trimmedLocalFileID IN %@", trimmedLocalIDS)
        return executeRequest(predicate: predicate, context: newChildBackgroundContext)
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
