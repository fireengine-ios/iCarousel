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
    
    // TODO: do we need save main context for compounder
    func saveDataForContext(context: NSManagedObjectContext, saveAndWait: Bool = true,
                                  savedCallBack: VoidHandler?) {
        context.save(async: !saveAndWait) { _ in
            savedCallBack?()
        }
    }
}


@available(iOS 10, *)
final class CoreDataStack_ios10: CoreDataStack {
    
    static let shared: CoreDataStack = CoreDataStack_ios10()
    
    let delegates = MulticastDelegate<CoreDataStackDelegate>()
    
    private(set) var isReady = false
    
    private let migrator = CoreDataMigrator()
    
    private lazy var storeDescription: NSPersistentStoreDescription = {
        let description = NSPersistentStoreDescription(url: CoreDataConfig.storeUrl)
        description.type = NSSQLiteStoreType
        description.setOption(FileProtectionType.none as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        description.shouldMigrateStoreAutomatically = false
        description.shouldInferMappingModelAutomatically = false
        
        return description
    }()

    private lazy var container: NSPersistentContainer = {
        let modelName = CoreDataMigrationVersion.latest.name
        let model = NSManagedObjectModel.with(name: modelName, directory: CoreDataConfig.modelDirectoryName)
        
        let container = NSPersistentContainer(name: CoreDataConfig.storeNameShort, managedObjectModel: model)
        container.persistentStoreDescriptions = [storeDescription]
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        if !isReady {
            assertionFailure("do not call until isReady")
            debugLog("core_data: isReady == false")
        }
        
        let context = container.viewContext
        
        return context
    }
    
    var newChildBackgroundContext: NSManagedObjectContext {
        if !isReady {
            assertionFailure("do not call until isReady")
            debugLog("core_data: isReady == false")
        }
        
        /// don't set parent for newBackgroundContext(), it will crash
        /// with error "Context already has a coordinator; cannot replace"
        return container.newBackgroundContext()
    }
    
    
    private init() {}
    
    
    func setup(completion: @escaping VoidHandler) {
        migrateIfNeeded { [weak self] in
            self?.container.loadPersistentStores { description, error in
                guard error == nil else {
                    fatalLog("unable to load store \(error!)")
                }
                
                self?.container.viewContext.automaticallyMergesChangesFromParent = true
                self?.isReady = true
                self?.delegates.invoke(invocation: { $0.onCoreDataStackSetupCompleted() })
                
                completion()
            }
        }
    }
    
    // MARK: - Loading
    
    private func migrateIfNeeded(completion: @escaping VoidHandler) {
        DispatchQueue.toBackground { [weak self] in
            self?.migrator.migrateStoreIfNeeded(at: CoreDataConfig.storeUrl, toVersion: .latest)
            DispatchQueue.toMain {
                completion()
            }
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        if !isReady {
            assertionFailure("do not call until isReady")
            debugLog("core_data: isReady == false")
        }
        container.performBackgroundTask(block)
    }
}
