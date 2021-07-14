//
//  SharedGroupCoreDataStack.swift
//  Depo
//
//  Created by Konstantin Studilin on 18.09.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import CoreData
import Photos


final class SharedGroupCoreDataStack {
    
    static let shared = SharedGroupCoreDataStack()
    
    
    private lazy var container: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: SharedConstants.sharedGroupDBContainerName)
        let storeURL = sharedGroupStoreURL(for: SharedConstants.groupIdentifier, databaseName: SharedConstants.sharedGroupDBName)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        return persistentContainer
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var newChildBackgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    
    private init() { }
    
    
    func saveData(for context: NSManagedObjectContext, async: Bool = false, completion: VoidHandler?) {
        context.save(async: async) { _ in
            completion?()
        }
    }
    
    func setup(completion: @escaping VoidHandler) {
        container.loadPersistentStores { [weak self] description, error in
            guard error == nil else {
                completion()
                return
            }
            
            self?.container.viewContext.automaticallyMergesChangesFromParent = true
            completion()
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
    
    private func sharedGroupStoreURL(for appGroup: String, databaseName: String) -> URL {
        guard
            let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
   
}


extension SharedGroupCoreDataStack {
    func unsynced(from assetLocalIdentifier: [String], completion: @escaping (Set<String>) -> ()) {
        let predicate = NSPredicate(format: "isValidForSync == false")
        executeRequest(predicate: predicate, context: mainContext) { invalidItems in
            let invalidIdentifiers = invalidItems.compactMap { $0.localIdentifier }
            
            #if MAIN_APP
            debugLog("WIDGET: got invalidItems \(invalidIdentifiers.count) out of \(assetLocalIdentifier.count) gallery items")
            #endif
            
            completion(Set(assetLocalIdentifier).subtracting(invalidIdentifiers))
        }
    }
    
    func save(isSynced: Bool, localIdentifiers: [String], completion: @escaping VoidHandler) {
        guard !localIdentifiers.isEmpty else {
            completion()
            return
        }
        
        #if MAIN_APP
        debugLog("WIDGET: save locals \(localIdentifiers.count) as isSynced \(isSynced)")
        #endif
        
        performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "localIdentifier IN %@", localIdentifiers)
            
            self?.executeRequest(predicate: predicate, context: context) { [weak self] existedItems in
                let existedIdentifiers = existedItems.compactMap { $0.localIdentifier }
                let newIdentifiers = Set(localIdentifiers).subtracting(existedIdentifiers)
                
                //update assets
                existedItems.forEach {
                    $0.isValidForSync = !isSynced
                }
                
                guard !newIdentifiers.isEmpty else {
                    self?.saveData(for: context, completion: completion)
                    return
                }
                
                //create new assets
                newIdentifiers.forEach {
                    let newAsset = LocalAsset(context: context)
                    newAsset.localIdentifier = $0
                    newAsset.isValidForSync = !isSynced
                }
                
                self?.saveData(for: context, completion: completion)
            }
        }
    }
    
    func actualizeWith(synced: [String], unsynced: [String], completion: @escaping VoidHandler) {
        
        #if MAIN_APP
        debugLog("WIDGET: actualizing with synced \(synced.count), unsynced \(unsynced.count)")
        #endif
        
        guard !synced.isEmpty || !unsynced.isEmpty else {
            completion()
            return
        }
        
        deleteAllExcept(localIdentifiers: synced + unsynced) { [weak self] in
            self?.save(isSynced: false, localIdentifiers: unsynced) {
                self?.save(isSynced: true, localIdentifiers: synced, completion: completion)
            }
        }
        
    }
    
    private func deleteAllExcept(localIdentifiers: [String], completion: @escaping VoidHandler) {
        
        #if MAIN_APP
        debugLog("WIDGET: deleting \(localIdentifiers.count)")
        #endif
        
        performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "NOT(localIdentifier IN %@)", localIdentifiers)
            self?.executeRequest(predicate: predicate, context: context) { [weak self] syncedItems in
                syncedItems.forEach {
                    context.delete($0)
                }
                self?.saveData(for: context, completion: completion)
            }
        }
    }
    
    
    //saving invalid (mostly iCloud) assets as not synced
    func saveInvalid(localIdentifiers: [String]) {
        
        #if MAIN_APP
        debugLog("WIDGET: save invalid \(localIdentifiers.count)")
        #endif
        
        guard !localIdentifiers.isEmpty else {
            return
        }
        
        performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "localIdentifier IN %@", localIdentifiers)
            
            self?.executeRequest(predicate: predicate, context: context) { [weak self] invalidItems in
                let syncedIdentifiers = invalidItems.compactMap { $0.localIdentifier }
                let newInvalid = Set(localIdentifiers).subtracting(syncedIdentifiers)
                
                //update assets
                invalidItems.forEach {
                    $0.isValidForSync = false
                }
                
                guard !newInvalid.isEmpty else {
                    self?.saveData(for: context, completion: nil)
                    return
                }
                
                newInvalid.forEach {
                    let newAsset = LocalAsset(context: context)
                    newAsset.localIdentifier = $0
                    newAsset.isValidForSync = false
                }
                
                self?.saveData(for: context, completion: nil)
            }
        }
    }
    
    func delete(localIdentifiers: [String], completion: @escaping VoidHandler) {
        performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "localIdentifier IN %@", localIdentifiers)
            self?.executeRequest(predicate: predicate, context: context) { [weak self] syncedItems in
                syncedItems.forEach {
                    context.delete($0)
                }
                self?.saveData(for: context, completion: completion)
            }
        }
    }
    
//    func deleteAll() {
//        performBackgroundTask { [weak self] context in
//            guard let self = self else {
//                return
//            }
//            
//            do {
//                let _ = try [LocalAsset.self]
//                    .compactMap { $0.entityDescription(context: context) }
//                    .compactMap { self.batchDeleteRequest(for: $0, predicate: nil) }
//                    .compactMap { try context.execute($0) as? NSBatchDeleteResult }
//                    .compactMap { $0.result as? [NSManagedObjectID] }
//                    .flatMap { $0 }
//                debugLog("successfull shared DB cleaning")
//            } catch {
//                debugLog("error during the shared DB cleaning: \(error.description)")
//            }
//        }
//    }
//    
//    
//    private func batchDeleteRequest(for entityDescription: NSEntityDescription, predicate: NSPredicate?) -> NSBatchDeleteRequest {
//        let deleteFetchRequest = NSFetchRequest<NSFetchRequestResult>()
//        deleteFetchRequest.entity = entityDescription
//        deleteFetchRequest.predicate = predicate
//        deleteFetchRequest.includesPropertyValues = false
//        deleteFetchRequest.returnsObjectsAsFaults = false
//        deleteFetchRequest.resultType = .managedObjectIDResultType
//        
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchRequest)
//        batchDeleteRequest.resultType = .resultTypeObjectIDs
//        
//        return batchDeleteRequest
//    }
//    
    private func executeRequest(predicate: NSPredicate, limit: Int = 0, context: NSManagedObjectContext, completion: @escaping ([LocalAsset])->()) {
        let request = NSFetchRequest<LocalAsset>(entityName: "LocalAsset")
        request.fetchLimit = limit
        request.predicate = predicate
        execute(request: request, context: context, completion: completion)
    }
    
    private func execute(request: NSFetchRequest<LocalAsset>, context: NSManagedObjectContext, completion: @escaping ([LocalAsset])->()) {
        context.perform {
            var result: [LocalAsset] = []
            do {
                result = try context.fetch(request)
            } catch let error as NSError {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                assertionFailure(errorMessage)
            } catch {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                assertionFailure(errorMessage)
            }
            completion(result)
        }
    }
}
