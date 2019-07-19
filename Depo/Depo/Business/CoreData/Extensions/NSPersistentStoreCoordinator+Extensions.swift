//
//  NSPersistentStoreCoordinator+Extensions.swift
//  EventsCountdown
//
//  Created by Bondar Yaroslav on 30/07/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import CoreData

extension NSPersistentStoreCoordinator {
    
    /// NSPersistentStoreCoordinator error types
    public enum CoordinatorError: Error {
        /// .momd file not found
        case modelFileNotFound
        /// NSManagedObjectModel creation fail
        case modelCreationError
        /// Gettings document directory fail
        case storePathNotFound
    }
    
    /// Return NSPersistentStoreCoordinator
    private convenience init(name: String) throws {
        do {
            let model = try NSPersistentStoreCoordinator.managedObjectModel(name: name)
            self.init(managedObjectModel: model)
        } catch {
            debugLog("failed NSPersistentStoreCoordinator init: \(error.localizedDescription)")
            throw CoordinatorError.modelCreationError
        }
    }
    
    class func managedObjectModel(name: String) throws -> NSManagedObjectModel {
        let modelBundle = Bundle.main
        let omoURL = modelBundle.url(forResource: "\(name) 3", withExtension: "omo", subdirectory: "\(name).momd")
        let momURL = modelBundle.url(forResource: "\(name) 3", withExtension: "mom", subdirectory: "\(name).momd")
        guard var url = omoURL ?? momURL else {
            debugLog("modelFileNotFound")
            throw CoordinatorError.modelFileNotFound
        }
        /// Use unoptimized model version < iOS 11
        if #available(iOS 11, *) {
            //
        } else if let momURL = momURL {
            url = momURL
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            debugLog("modelFile can not be opened")
            fatalError("cannot open model at \(url)")
        }
        return model
    }
    
    /// Return NSPersistentStoreCoordinator with set coordinator
    static func coordinator(modelName: String, persistentStoreName: String) throws -> NSPersistentStoreCoordinator? {
        let coordinator = try NSPersistentStoreCoordinator(name: modelName)
        
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            debugLog("failed urls(for: .documentDirectory")
            throw CoordinatorError.storePathNotFound
        }
        
        do {
            let url = documents.appendingPathComponent("\(persistentStoreName).sqlite")
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: false]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            debugLog("failed addPersistentStore: \(error.localizedDescription)")
            throw error
        }
        
        return coordinator
    }
}
