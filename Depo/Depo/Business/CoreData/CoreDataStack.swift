//
//  CoreDataStack.swift
//  Depo
//
//  Created by Konstantin Studilin on 28/08/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol CoreDataStack: class {
    var isReady: Bool { get }
    var mainContext: NSManagedObjectContext { get }
    var newChildBackgroundContext: NSManagedObjectContext  { get }
    
    func setup(completion: @escaping VoidHandler)
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}


fileprivate struct CoreDataConfig {
    static let modelName = "LifeBoxModel"
    static let modelVersion = "3"
    static let storeName = "DataModel"
    
    static let storeUrl: URL = {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            let errorMessage = "Unable to resolve document directory"
            debugLog(errorMessage)
            fatalError(errorMessage)
        }
        
        return docURL.appendingPathComponent("\(CoreDataConfig.storeName).sqlite")
    }()
    
    static let modelURL: URL? = {
        let bundle = Bundle.main
        let versionedModelName = "\(CoreDataConfig.modelName) \(CoreDataConfig.modelVersion)"
        let subdir = "\(CoreDataConfig.modelName).momd"
        let omoURL = bundle.url(forResource: versionedModelName, withExtension: "omo", subdirectory: subdir)
        let momURL = bundle.url(forResource: versionedModelName, withExtension: "mom", subdirectory: subdir)
        
        /// Use optimized model version only if iOS >= 11
        if #available(iOS 11, *) {
            return omoURL ?? momURL
        } else {
            return momURL ?? omoURL
        }
    }()
    
    private init() {}
}


extension CoreDataStack {
    
    fileprivate static func managedObjectModel() -> NSManagedObjectModel {
        guard let modelURL = CoreDataConfig.modelURL else {
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
    }
    
    // TODO: do we need save main context for compounder
    func saveDataForContext(context: NSManagedObjectContext, saveAndWait: Bool = true,
                                  savedCallBack: VoidHandler?) {
        context.save(async: !saveAndWait) { _ in
            savedCallBack?()
        }
    }
}


final class CoreDataStack_ios9: CoreDataStack {
    
    private static func storeCoordinator() -> NSPersistentStoreCoordinator {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel())
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: false]
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: CoreDataConfig.storeUrl, options: options)
        } catch {
            let errorMessage = "Error migrating store: \(error)"
            debugLog(errorMessage)
            fatalError(errorMessage)
        }
        return  psc
    }
    
    
    private(set) var isReady = false
    
    let mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = storeCoordinator()
        return context
    }()
    
    var newChildBackgroundContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        return context
    }
    
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    
    func setup(completion: @escaping VoidHandler) {
        isReady = true
        completion()
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
        let context = newChildBackgroundContext
        context.perform {
            block(context)
        }
    }
}



@available(iOS 10, *)
final class CoreDataStack_ios10: CoreDataStack {
    
    private static func storeDescription() -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: CoreDataConfig.storeUrl)
        description.type = NSSQLiteStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = false
        
        return description
    }
    

    private(set) var isReady = false
    
    
    private let container: NSPersistentContainer
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var newChildBackgroundContext: NSManagedObjectContext {
        /// don't set parent for newBackgroundContext(), it will crash
        /// with error "Context already has a coordinator; cannot replace"
        return container.newBackgroundContext()
    }
    
    
    init() {
        container = NSPersistentContainer(name: CoreDataConfig.storeName, managedObjectModel: Self.managedObjectModel())
        container.persistentStoreDescriptions = [Self.storeDescription()]
    }
    
    func setup(completion: @escaping VoidHandler) {
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                let errorMessage = "Unable to load persistent stores: \(error)"
                debugLog(errorMessage)
                assertionFailure(errorMessage)
            }
            debugLog("persistent store loaded: \(description)")
            self?.mainContext.automaticallyMergesChangesFromParent = true
            self?.isReady = true
            completion()
        }
    }
    
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
}
