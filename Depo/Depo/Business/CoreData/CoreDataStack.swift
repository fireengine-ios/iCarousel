//
//  CoreDataStack.swift
//  Depo
//
//  Created by Konstantin Studilin on 28/08/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol CoreDataStackDelegate: class {
    func onCoreDataStackSetupCompleted()
}


protocol CoreDataStack: class {
    static var shared: CoreDataStack { get }
    
    var delegates: MulticastDelegate<CoreDataStackDelegate> { get }
    
    var isReady: Bool { get }
    
    func setup(completion: @escaping VoidHandler)
    
    var mainContext: NSManagedObjectContext  { get }
    var newChildBackgroundContext: NSManagedObjectContext { get }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}

extension CoreDataStack {
    
//    func checkReadiness() {
//        guard isReady else {
//            let message = "Call CoreDataStack before it's ready"
//            debugLog(message)
//            assertionFailure(message)
//            return
//        }
//    }
    
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
    
    let migrator = CoreDataMigrator()

    let mainContext: NSManagedObjectContext
    
    var newChildBackgroundContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        return context
    }
    
    private let storeCoordinator: NSPersistentStoreCoordinator = {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: CoreDataMigrationModel.current.managedObjectModel)
        do {
//            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
//                           NSInferMappingModelAutomaticallyOption: false]
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: CoreDataMigrationModel.current.modelURL, options: nil)
        } catch {
            let errorMessage = "Error migrating store: \(error)"
            debugLog(errorMessage)
            fatalError(errorMessage)
        }
        return  psc
    }()
    
    private init() {
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = storeCoordinator
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    func setup(completion: @escaping VoidHandler) {
        migrateStoreIfNeeded { [weak self] in
            self?.isReady = true
            self?.delegates.invoke(invocation: { $0.onCoreDataStackSetupCompleted() })
            completion()
        }
    }
    
    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        let storeURL = CoreDataConfig.storeUrl
        if migrator.requiresMigration(at: storeURL) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.migrator.migrateStore(at: storeURL)
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
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
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = newChildBackgroundContext
        context.perform {
            block(context)
        }
    }
}



@available(iOS 10, *)
final class CoreDataStack_ios10: CoreDataStack {
    
    static let shared: CoreDataStack = CoreDataStack_ios10()
    
    let delegates = MulticastDelegate<CoreDataStackDelegate>()
    
    private(set) var isReady = false
    
    private let migrator = CoreDataMigrator()
    
    private let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataConfig.storeNameShort, managedObjectModel: CoreDataMigrationModel.current.managedObjectModel)
        container.persistentStoreDescriptions = [CoreDataConfig.storeDescription]
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        let context = container.viewContext
        
        return context
    }
    
    var newChildBackgroundContext: NSManagedObjectContext {
        /// don't set parent for newBackgroundContext(), it will crash
        /// with error "Context already has a coordinator; cannot replace"
        return container.newBackgroundContext()
    }
    
    
    private init() {}
    
    
    func setup(completion: @escaping VoidHandler) {
        migrateStoreIfNeeded { [weak self] in
            self?.container.loadPersistentStores { description, error in
                guard error == nil else {
                    fatalError("was unable to load store \(error!)")
                }
                
                self?.isReady = true
                self?.delegates.invoke(invocation: { $0.onCoreDataStackSetupCompleted() })
                completion()
            }
        }
    }
    
    // MARK: - Loading
    
    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            fatalError("persistentContainer was not set up properly")
        }
        
        if migrator.requiresMigration(at: storeURL) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.migrator.migrateStore(at: storeURL)
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
    }
    
    
    
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask(block)
    }
}
