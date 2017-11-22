//
//  CoreDataStack.swift
//  Depo
//
//  Created by Alexander Gurin on 7/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import CoreData
import Photos

class CoreDataStack: NSObject {
    
    @objc static let `default` = CoreDataStack()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        guard let modelURL = Bundle.main.url(forResource: "LifeBoxModel", withExtension:"momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else { fatalError("Error loading model from bundle") }

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        do {
            let storeURL = Device.documentsFolderUrl(withComponent: "DataModel.sqlite")
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                configurationName: nil,
                                                at: storeURL,
                                                options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        
        return coordinator
    }()
    
    
    var mainContext: NSManagedObjectContext
    
    var newChildBackgroundContext: NSManagedObjectContext {
        let children =  NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        children.parent = mainContext
        return children
    }
    
    var backgroundContext: NSManagedObjectContext
    
    override init() {

        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        
        super.init()
//        rootBackgroundContext.persistentStoreCoordinator = persistentStoreCoordinator
        mainContext.persistentStoreCoordinator = persistentStoreCoordinator
        backgroundContext.parent = mainContext
//        let name = NSNotification.Name.NSManagedObjectContextDidSave
//        let selector = #selector(managedObjectContextObjectsDidSave)
//        NotificationCenter.default.addObserver(self,
//                                               selector: selector,
//                                               name: name,
//                                               object: nil)
        
    }
    
    func clearDataBase() {
        deleteRemoteFiles()
    }
    
    func deleteRemoteFiles() {
        // Album has remote status by default for now
        let albumFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItemsAlbum.Identifier)
        
        let mediaItemFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicateRules = PredicateRules()
        guard let predicate = predicateRules.predicate(filters: [.localStatus(.nonLocal)]) else {
            return
        }
        mediaItemFetchRequest.predicate = predicate
        
        self.deleteObjects(fromFetches: [albumFetchRequest, mediaItemFetchRequest])
    }

    func deleteLocalFiles(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicateRules = PredicateRules()
        guard let predicate = predicateRules.predicate(filters: [.localStatus(.local)]) else {
            return
        }
        fetchRequest.predicate = predicate
        deleteObjects(fromFetch: fetchRequest)
    }
    
    private func clearAllEntities() {
        let allEnteties = persistentStoreCoordinator.managedObjectModel.entities
        allEnteties.forEach {
            self.deleteAllObjects(forEntity: $0)
        }
    }
    
    private func deleteAllObjects(forEntity entity: NSEntityDescription) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        deleteObjects(fromFetch: fetchRequest)
    }
    
    private func deleteObjects(fromFetches fetchRequests: [NSFetchRequest<NSFetchRequestResult>]) {
        for fetchRequest in fetchRequests {
            self.deleteObjects(fromFetch: fetchRequest)
        }
    }
    
    private func deleteObjects(fromFetch fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let context = mainContext
        
        guard let fetchResult = try? context.fetch(fetchRequest),
            let unwrapedObjects = fetchResult as? [NSManagedObject],
            unwrapedObjects.count > 0 else {
                
                return
        }
        for object in unwrapedObjects {
            context.delete(object)
        }
        saveDataForContext(context: context, saveAndWait: true)
        debugPrint("Data base should be cleared any moment now")
    }
    
    func saveMainContext() {
        mainContext.processPendingChanges()
        saveDataForContext(context: mainContext, saveAndWait: true)
    }
    
    @objc func saveDataForContext(context: NSManagedObjectContext,saveAndWait: Bool = false) {
        debugPrint("save context")
        let saveBlock: () -> Void = {
            do {
                try context.save()
            } catch {
                print("Error saving context ___ ")
            }
        }
        
        if context.hasChanges {
            if (saveAndWait) {
                context.performAndWait(saveBlock)
            } else {
                context.perform(saveBlock)
            }
        }
        
        if context.parent == mainContext, context != mainContext {
            DispatchQueue.main.async {
//                try? self.mainContext.save()
                self.saveMainContext()
            }
            return
        }
    }
    
//    func appendNewRemmoteFiles(items:[SearchItemResponse]) { //AlexGurin
//
//        let uuidList = items.map{ $0.hash }
//        let predicateForRemoteFile = NSPredicate(format: "uuidValue IN %@", uuidList)
//
//        let inCoreData = executeRequest(predicate: predicateForRemoteFile, context:rootBackgroundContext).flatMap{ $0.uuidValue }
//
//        let childrenContext = self.newChildBackgroundContext
//        let appendItems = items.filter{ !inCoreData.contains($0.uuid!) }
//        appendItems.forEach {
//            _ = MediaItem(remoteItem: $0, context: childrenContext)
//        }
//        saveDataForContext(context: childrenContext, saveAndWait: true)
//    }
    
//    @objc func managedObjectContextObjectsDidSave(notification: Notification) {
    
//        if let context = notification.object as? NSManagedObjectContext,
//            let parent = context.parent,
//            parent == mainContext {
//            try? parent.save()
////            print("SAVE MAIN CONTEXT %@ ", Date() )
////            parent.mergeChanges(fromContextDidSave: notification)
////            if parent == rootBackgroundContext {
////                print("SAVE MAIN CONTEXT %@ ", Date() )
////            }
//        }
        
  
//    }
    
}
