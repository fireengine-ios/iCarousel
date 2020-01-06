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
    
    private func requiresMigration(at storeURL: URL, toVersion version: CoreDataMigrationVersion) -> Bool {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return false
        }

        return !version.isCompatibleWithStoreMetadata(metadata)
    }
    
    // MARK: - Migration
    
    func migrateStoreIfNeeded(at storeURL: URL, toVersion version: CoreDataMigrationVersion) {
        if requiresMigration(at: storeURL, toVersion: version) {
            migrateStore(at: storeURL, toVersion: version)
        }
    }
    
    func migrateStore(at storeURL: URL, toVersion version: CoreDataMigrationVersion) {
        forceWALCheckpointingForStore(at: storeURL)
        
        var currentURL = storeURL
        let migrationSteps = migrationStepsForStore(at: storeURL, toVersion: version)
        
        for migrationStep in migrationSteps {
            let manager = NSMigrationManager(sourceModel: migrationStep.sourceModel, destinationModel: migrationStep.destinationModel)
            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
            
            do {
                try manager.migrateStore(from: currentURL, sourceType: NSSQLiteStoreType, options: nil, with: migrationStep.mappingModel, toDestinationURL: tempDirectoryURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
            } catch let error {
                fatalLog("failed attempting to migrate from \(migrationStep.sourceModel) to \(migrationStep.destinationModel), error: \(error)")
            }
            
            if currentURL != storeURL {
                //Destroy intermediate step's store
                NSPersistentStoreCoordinator.destroyStore(at: currentURL)
            }
            
            currentURL = tempDirectoryURL
        }
        
        NSPersistentStoreCoordinator.replaceStore(at: storeURL, withStoreAt: currentURL)
        
        if currentURL != storeURL {
            NSPersistentStoreCoordinator.destroyStore(at: currentURL)
        }
    }
    
    private func migrationStepsForStore(at storeURL: URL, toVersion destinationVersion: CoreDataMigrationVersion) -> [CoreDataMigrationStep] {
        guard
            let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL),
            let sourceVersion = CoreDataMigrationVersion.compatibleVersionForStoreMetadata(metadata)
        else {
            fatalLog("unknown store version at URL \(storeURL)")
        }
        
        return migrationSteps(fromSourceVersion: sourceVersion, toDestinationVersion: destinationVersion)
    }

    private func migrationSteps(fromSourceVersion sourceVersion: CoreDataMigrationVersion, toDestinationVersion destinationVersion: CoreDataMigrationVersion) -> [CoreDataMigrationStep] {
        var sourceVersion = sourceVersion
        var migrationSteps = [CoreDataMigrationStep]()

        while sourceVersion != destinationVersion, let nextVersion = sourceVersion.next {
            let migrationStep = CoreDataMigrationStep(sourceVersion: sourceVersion, destinationVersion: nextVersion)
            migrationSteps.append(migrationStep)

            sourceVersion = nextVersion
        }

        return migrationSteps
    }
    
    // MARK: - WAL
    func forceWALCheckpointingForStore(at storeURL: URL) {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL), let currentModel = NSManagedObjectModel.compatibleModelForStoreMetadata(metadata) else {
            return
        }
        
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: currentModel)
            
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = persistentStoreCoordinator.addPersistentStore(at: storeURL, options: options)
            try persistentStoreCoordinator.remove(store)
        } catch let error {
            fatalLog("failed to force WAL checkpointing, error: \(error)")
        }
    }
}


private extension CoreDataMigrationVersion {
    
    // MARK: - Compatibility
    
    static func compatibleVersionForStoreMetadata(_ metadata: [String : Any]) -> CoreDataMigrationVersion? {
        let compatibleVersion = CoreDataMigrationVersion.allCases.first {
            let model = NSManagedObjectModel.managedObjectModel(forName: $0.name, directory: CoreDataConfig.modelDirectoryName)
            
            return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        return compatibleVersion
    }
    
    func isCompatibleWithStoreMetadata(_ metadata: [String : Any]) -> Bool {
        return CoreDataMigrationVersion.compatibleVersionForStoreMetadata(metadata) == self
    }
}
