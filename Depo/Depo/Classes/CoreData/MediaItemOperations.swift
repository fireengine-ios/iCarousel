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
 
        let inCoreData = executeRequest(predicate: predicateForRemoteFile, context:rootBackgroundContext).flatMap{ $0.uuidValue }
        
        let childrenContext = self.newChildBackgroundContext
        let appendItems = items.filter{ !inCoreData.contains($0.uuid) }
        
        if appendItems.count == 0 {
            return
        }
        
        appendItems.forEach {
            _ = MediaItem(wrapData: $0, context: childrenContext)
        }
        
        saveDataForContext(context: childrenContext, saveAndWait: true)
    }
    
    
    func removeFromStorage(wrapData: [WrapData]) {
        
        let context = mainContext
        wrapData.forEach {
            context.delete( $0.coreDataObject! )
        }
        saveDataForContext(context: context, saveAndWait: true)
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
