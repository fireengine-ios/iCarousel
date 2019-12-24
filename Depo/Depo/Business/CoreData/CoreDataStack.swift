//
//  CoreDataStack.swift
//  Depo
//
//  Created by Konstantin Studilin on 28/08/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


fileprivate struct CoreDataConfig {
    static let modelName = "LifeBoxModel"
    static let modelVersion = "4"
    static let storeName = "DataModel"
    
    static var storeUrl: URL {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalLog("Unable to resolve document directory")
        }
        
        return docURL.appendingPathComponent("\(CoreDataConfig.storeName).sqlite")
    }
    
    static var modelURL: URL? {
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
    }
    
    static var managedObjectModel: NSManagedObjectModel {
        guard let modelURL = CoreDataConfig.modelURL else {
            fatalLog("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalLog("Error initializing mom from: \(modelURL)")
        }
        return mom
    }
    
    @available(iOS 10.0, *)
    static var storeDescription: NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: CoreDataConfig.storeUrl)
        description.type = NSSQLiteStoreType
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = false
        
        return description
    }
    
    private init() {}
}



protocol CoreDataStackDelegate: class {
    func onCoreDataStackSetupCompleted()
}

protocol CoreDataStack: class {
    static var shared: CoreDataStack { get }
    
    var delegates: MulticastDelegate<CoreDataStackDelegate> { get }
    
    var isReady: Bool { get }
    var mainContext: NSManagedObjectContext { get }
    var newChildBackgroundContext: NSManagedObjectContext  { get }
    
    /**  Call before first use.
     * Required.
     * Since ios 10 loadPersistentStores is async and may take a long time in case of migration
     */
    func setup(completion: @escaping VoidHandler)
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}


extension CoreDataStack {
    
    func checkReadiness() {
        guard isReady else {
            let message = "Call CoreDataStack before it's ready"
            debugLog(message)
            assertionFailure(message)
            return
        }
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

    static let shared: CoreDataStack = CoreDataStack_ios9()
    
    let delegates = MulticastDelegate<CoreDataStackDelegate>()
    
    private(set) var isReady = false
    
    let mainContext: NSManagedObjectContext
    
    var newChildBackgroundContext: NSManagedObjectContext {
        checkReadiness()
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        return context
    }
    
    private let storeCoordinator: NSPersistentStoreCoordinator = {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: CoreDataConfig.managedObjectModel)
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: false]
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: CoreDataConfig.storeUrl, options: options)
        } catch {
            fatalLog("Error migrating store: \(error)")
        }
        return  psc
    }()
    
    
    private init() {
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = storeCoordinator
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    
    @objc private func managedObjectContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else {
            assertionFailure()
            return
        }
        
        if context != mainContext, context.parent == mainContext {
            /// will be called on background queue
            mainContext.saveAsync()
        }
    }
    
    func setup(completion: @escaping VoidHandler) {
        isReady = true
        delegates.invoke { $0.onCoreDataStackSetupCompleted() }
        completion()
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        checkReadiness()
        let context = newChildBackgroundContext
        context.perform {
            block(context)
        }
    }
    
}


@available(iOS 10, *)
final class CoreDataStack_ios10: CoreDataStack {
 
    static let shared: CoreDataStack = CoreDataStack_ios10()
    
    private let container: NSPersistentContainer
    
    private(set) var isReady = false
    
    let delegates = MulticastDelegate<CoreDataStackDelegate>()

    var mainContext: NSManagedObjectContext {
        checkReadiness()
        return container.viewContext
    }
    
    var newChildBackgroundContext: NSManagedObjectContext {
        checkReadiness()
        /// don't set parent for newBackgroundContext(), it will crash
        /// with error "Context already has a coordinator; cannot replace"
        return container.newBackgroundContext()
    }
    
    
    private init() {
        container = NSPersistentContainer(name: CoreDataConfig.storeName, managedObjectModel: CoreDataConfig.managedObjectModel)
        container.persistentStoreDescriptions = [CoreDataConfig.storeDescription]
    }
    
    
    func setup(completion: @escaping VoidHandler) {
        guard !isReady else {
            delegates.invoke { $0.onCoreDataStackSetupCompleted() }
            completion()
            return
        }
        
        container.loadPersistentStores { [weak self] description, error in
            if let error = error {
                let errorMessage = "Unable to load persistent stores: \(error)"
                debugLog(errorMessage)
                assertionFailure(errorMessage)
            }
            debugLog("persistent store loaded: \(description)")
            self?.isReady = true
            self?.mainContext.automaticallyMergesChangesFromParent = true
            self?.delegates.invoke { $0.onCoreDataStackSetupCompleted() }
            completion()
        }
    }
    
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        checkReadiness()
        container.performBackgroundTask(block)
    }
}
