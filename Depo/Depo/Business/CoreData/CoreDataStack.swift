//
//  CoreDataStack.swift
//  Depo
//
//  Created by Alexander Gurin on 7/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack: NSObject {
    
    static let `default` = CoreDataStack()
    
    private let modelName = "LifeBoxModel"
    private let persistentStoreName = "DataModel"
    
    
    private override init() {
        super.init()
        
        if #available(iOS 10.0, *) {
            mainContext.automaticallyMergesChangesFromParent = true
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
        }
        
        /// for tests
        //NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func managedObjectContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            return
        }
        if context != mainContext, context.parent == mainContext {
            /// will be called on background queue
            mainContext.saveAsync()
        }
    }
    
    @available(iOS 10.0, *)
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        
        let loadDefaultStore = {
            container.loadPersistentStores { (storeDescription, error) in
                print("CoreData: Inited \(storeDescription)")
                if let error = error {
                    print("CoreData: Unresolved error \(error)")
                    return
                }
            }
        }
        
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            loadDefaultStore()
            return container
        }
        
        do {
            let url = documents.appendingPathComponent("\(persistentStoreName).sqlite")
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: false]
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch let error {
            loadDefaultStore()
        }
        
        return container
    }()

    
    ///--- available iOS 9
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        do {
            return try NSPersistentStoreCoordinator.coordinator(modelName: modelName, persistentStoreName: persistentStoreName)
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        return nil
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()
    ///---
    
    // MARK: Public methods
    
    var newChildBackgroundContext: NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            /// don't set parent for newBackgroundContext(), it will crash
            /// with error "Context already has a coordinator; cannot replace"
            return persistentContainer.newBackgroundContext()
        } else {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.parent = mainContext
            return context
        }
        /// for tests
        //        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        //        context.parent = mainContext
        //        return context
    }
    
    var mainContext: NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            return persistentContainer.viewContext
        } else {
            return managedObjectContext
        }
    }
    
    /// for background fetch
    //lazy var backgroundContext = newBackgroundContext
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        if #available(iOS 10.0, *) {
            persistentContainer.performBackgroundTask(block)
        } else {
            let context = newChildBackgroundContext
            context.perform { 
                block(context)
            }
        }
    }
    
    // TODO: do we need save main context for compounder
    @objc func saveDataForContext(context: NSManagedObjectContext, saveAndWait: Bool = true,
                                  savedCallBack: VoidHandler?) {
        context.saveAsyncWithParantMerge(async: !saveAndWait, completion: { _ in
            savedCallBack?()
        })
    }
}
