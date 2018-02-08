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
    
    typealias AppendingLocaclItemsFinishCallback = ()->Void
    typealias AppendingLocaclItemsProgressCallback = (Float)->Void
    
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
    
//    var appendingItemsFinishBlock: AppendingLocaclItemsFinishCallback?
    var inProcessAppendingLocalFiles = false

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
        mainContext.persistentStoreCoordinator = persistentStoreCoordinator
        backgroundContext.parent = mainContext
    }
    
    func clearDataBase() {
        deleteRemoteFiles()
    }
    
//    func
    
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
        DispatchQueue.main.async {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
            let predicateRules = PredicateRules()
            guard let predicate = predicateRules.predicate(filters: [.localStatus(.local)]) else {
                return
            }
            fetchRequest.predicate = predicate
            self.deleteObjects(fromFetch: fetchRequest)
        }
    }
    
    func getLocalDuplicates(remoteItems: [Item]) -> [Item] {
        let remoteMd5s = remoteItems.map{$0.md5}
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        fetchRequest.predicate = NSPredicate(format: "md5Value IN %@",  remoteMd5s)
        
        guard let localDuplicatesMediaItems = (try? CoreDataStack.default.mainContext.fetch(fetchRequest)) as? [MediaItem] else {
            return []
        }
        
        return localDuplicatesMediaItems.flatMap{return WrapData(mediaItem: $0)}
    }

    /// MAYBE WILL BE NEED
//    private func deleteAllObjects(forEntity entity: NSEntityDescription) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
//        fetchRequest.entity = entity
//        deleteObjects(fromFetch: fetchRequest)
//    }
    
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
    
    @objc func saveDataForContext(context: NSManagedObjectContext, saveAndWait: Bool = true) {
        debugPrint("save context")
        let saveBlock: () -> Void = {
            do {
                try context.save()
                if !self.inProcessAppendingLocalFiles {
                    //TODO: some NOTIFICATION OR ACTUAL finished block
                }
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
                self.saveMainContext()
            }
            return
        }
    }
}
