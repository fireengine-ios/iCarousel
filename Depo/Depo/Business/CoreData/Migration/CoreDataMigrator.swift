//
//  CoreDataMigrator.swift
//  Depo
//
//  Created by Konstantin Studilin on 09/10/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

/**
 Responsible for handling Core Data model migrations.
 
 The solution below uses an iterative approach where we migrate mutliple times through a chain of model versions.
 So, if we have 4 model versions (1, 2, 3, 4), you would need to create the following mappings 1 to 2, 2 to 3 and 3 to 4.
 Then when we create model version 5, we only need to create one additional mapping 4 to 5. This greatly reduces the work required when adding a new version.
 */

final class CoreDataMigrator {
    
    // MARK: - Check
    
    func requiresMigration(at storeURL: URL, currentMigrationModel: CoreDataMigrationModel = CoreDataMigrationModel.current) -> Bool {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return false
        }

        return !currentMigrationModel.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
    }
    
    // MARK: - Migration
    
    func migrateStore(at storeURL: URL) {
        migrateStore(from: storeURL, to: storeURL, targetVersion: CoreDataMigrationModel.current)
    }
    
    func migrateStore(from sourceURL: URL, to targetURL: URL, targetVersion: CoreDataMigrationModel) {
        guard let sourceMigrationModel = CoreDataMigrationSourceModel(storeURL: sourceURL as URL) else {
            fatalError("unknown store version at URL \(sourceURL)")
        }
        
        forceWALCheckpointingForStore(at: sourceURL)
        
        var currentURL = sourceURL
        let migrationSteps = sourceMigrationModel.migrationSteps(to: targetVersion)
        
        for step in migrationSteps {
            let manager = NSMigrationManager(sourceModel: step.source, destinationModel: step.destination)
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
            
            do {
                try manager.migrateStore(from: currentURL, sourceType: NSSQLiteStoreType, options: nil, with: step.mapping, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
            } catch let error {
                fatalError("failed attempting to migrate from \(step.source) to \(step.destination), error: \(error)")
            }
            
            if currentURL != sourceURL {
                //Destroy intermediate step's store
                NSPersistentStoreCoordinator.destroyStore(at: currentURL)
            }
            
            currentURL = destinationURL
        }
        
        NSPersistentStoreCoordinator.replaceStore(at: targetURL, withStoreAt: currentURL)
        
        if (currentURL != sourceURL) {
            NSPersistentStoreCoordinator.destroyStore(at: currentURL)
        }
    }
    
    // MARK: - WAL
    func forceWALCheckpointingForStore(at storeURL: URL) {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL), let migrationModel = CoreDataMigrationModel.migrationModelCompatible(with: metadata)  else {
            return
        }
        
        do {
            let objectModel = migrationModel.managedObjectModel
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
            
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = persistentStoreCoordinator.addPersistentStore(at: storeURL, options: options)
            try persistentStoreCoordinator.remove(store)
        } catch let error {
            fatalError("failed to force WAL checkpointing, error: \(error)")
        }
    }
}
