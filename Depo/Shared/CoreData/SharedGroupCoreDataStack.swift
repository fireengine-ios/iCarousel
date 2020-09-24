//
//  SharedGroupCoreDataStack.swift
//  Depo
//
//  Created by Konstantin Studilin on 18.09.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import CoreData


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
        let predicate = NSPredicate(format: "isSynced == true OR isValid == false", assetLocalIdentifier)
        executeRequest(predicate: predicate, context: mainContext) { [weak self] syncedItems in
            let syncedIdentifiers = syncedItems.compactMap { $0.localIdentifier }
            
            completion(Set(assetLocalIdentifier).subtracting(syncedIdentifiers))
        }
    }
    
    func saveSynced(localIdentifiers: [String]) {
        guard !localIdentifiers.isEmpty else {
            return
        }
        
        performBackgroundTask { [weak self] context in
            //TODO: kind of Range API updateDB logic is required to filter added/changed assets
            let predicate = NSPredicate(format: "localIdentifier IN %@", localIdentifiers)
            
            self?.executeRequest(predicate: predicate, context: context) { [weak self] syncedItems in
                let syncedIdentifiers = syncedItems.compactMap { $0.localIdentifier }
                let newSynced = Set(localIdentifiers).subtracting(syncedIdentifiers)
                
                //update assets
                syncedItems.forEach {
                    $0.isSynced = true
                    $0.isValid = true
                }
                
                guard !newSynced.isEmpty else {
                    self?.saveData(for: context, completion: nil)
                    return
                }
                
                newSynced.forEach {
                    let newAsset = LocalAsset(context: context)
                    newAsset.localIdentifier = $0
                    newAsset.isSynced = true
                    newAsset.isValid = true
                }
                
                self?.saveData(for: context, completion: nil)
            }
        }
    }
    
    
    //saving invalid (mostly iCloud) assets as not synced
    func saveInvalid(localIdentifiers: [String]) {
        guard !localIdentifiers.isEmpty else {
            return
        }
        
        performBackgroundTask { [weak self] context in
            //TODO: kind of Range API updateDB logic is required to filter added/changed assets
            let predicate = NSPredicate(format: "localIdentifier IN %@", localIdentifiers)
            
            self?.executeRequest(predicate: predicate, context: context) { [weak self] invalidItems in
                let syncedIdentifiers = invalidItems.compactMap { $0.localIdentifier }
                let newInvalid = Set(localIdentifiers).subtracting(syncedIdentifiers)
                
                //update assets
                invalidItems.forEach {
                    $0.isSynced = false
                    $0.isValid = false
                }
                
                guard !newInvalid.isEmpty else {
                    self?.saveData(for: context, completion: nil)
                    return
                }
                
                newInvalid.forEach {
                    let newAsset = LocalAsset(context: context)
                    newAsset.localIdentifier = $0
                    newAsset.isSynced = false
                    newAsset.isValid = false
                }
                
                self?.saveData(for: context, completion: nil)
            }
        }
    }
    
    func delete(localIdentifiers: [String]) {
        performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "localIdentifier IN %@", localIdentifiers)
            self?.executeRequest(predicate: predicate, context: context) { [weak self] syncedItems in
                syncedItems.forEach {
                    context.delete($0)
                }
                self?.saveData(for: context, completion: nil)
            }
        }
    }
    
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
