//
//  CoreDataStack.swift
//  Depo
//
//  Created by Konstantin Studilin on 28/08/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


final class CoreDataStack {
    
    private struct Config {
        static let modelName = "LifeBoxModel"
        static let modelVersion = "3"
        static let storeName = "DataModel"
    }
    
    static let shared = CoreDataStack()
    
    private lazy var storeUrl: URL = {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            let errorMessage = "Unable to resolve document directory"
            debugLog(errorMessage)
            fatalError(errorMessage)
        }
        
        return docURL.appendingPathComponent("\(Config.storeName).sqlite")
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle.main
        let versionedModelName = "\(Config.modelName) \(Config.modelVersion)"
        let subdir = "\(Config.modelName).momd"
        let omoURL = bundle.url(forResource: versionedModelName, withExtension: "omo", subdirectory: subdir)
        let momURL = bundle.url(forResource: versionedModelName, withExtension: "mom", subdirectory: subdir)
        
        let url: ()->(URL?) = {
            /// Use optimized model version only if iOS >= 11
            if #available(iOS 11, *) {
                return omoURL ?? momURL
            } else {
                return momURL ?? omoURL
            }
        }

        guard let modelURL = url() else {
            let errorMessage = "Error loading model from bundle"
            debugLog(errorMessage)
            fatalError(errorMessage)
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            let errorMessage = "Error initializing mom from: \(modelURL)"
            debugLog(errorMessage)
            fatalError(errorMessage)
        }
        return mom
    }()
    
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        if #available(iOS 10, *) {
            return container.persistentStoreCoordinator
        } else {
            let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            do {
                let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                               NSInferMappingModelAutomaticallyOption: false]
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
            } catch {
                let errorMessage = "Error migrating store: \(error)"
                debugLog(errorMessage)
                fatalError(errorMessage)
            }
            return  psc
        }
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        if #available(iOS 10, *) {
            return container.viewContext
        } else {
            let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            moc.persistentStoreCoordinator = storeCoordinator
            return moc
        }
    }()
    
    var newChildBackgroundContext: NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            /// don't set parent for newBackgroundContext(), it will crash
            /// with error "Context already has a coordinator; cannot replace"
            return container.newBackgroundContext()
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
    
    
    @available(iOS 10, *)
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Config.storeName, managedObjectModel: managedObjectModel)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { description, error in
            if let error = error {
                let errorMessage = "Unable to load persistent stores: \(error)"
                debugLog(errorMessage)
                fatalError(errorMessage)
            }
            debugLog("persistent store loaded: \(description)")
        }
        return container
    }()
    
    @available(iOS 10, *)
    private lazy var storeDescription: NSPersistentStoreDescription = {
        let description = NSPersistentStoreDescription(url: storeUrl)
        description.type = NSSQLiteStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = false
        
        return description
    }()
    
    
    init() {
        if #available(iOS 10.0, *) {
            mainContext.automaticallyMergesChangesFromParent = true
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
        }
    }
    
    @objc func managedObjectContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            assertionFailure()
            return
        }
        
        if context != mainContext, context.parent == mainContext {
            /// will be called on background queue
            mainContext.saveAsync()
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        if #available(iOS 10.0, *) {
            container.performBackgroundTask(block)
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
        context.save(async: !saveAndWait) { _ in
            savedCallBack?()
        }
    }
}
