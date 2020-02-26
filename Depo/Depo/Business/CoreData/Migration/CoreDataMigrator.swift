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
 
 If we've created model version n, we only need to create one additional mapping n-1 to n.
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
            printLog("db_migration: migration is required at \(storeURL) to \(version)")
            migrateStore(at: storeURL, toVersion: version)
        }
    }
    
    private func migrateStore(at storeURL: URL, toVersion version: CoreDataMigrationVersion) {
        forceWALCheckpointingForStore(at: storeURL)
        
        var currentURL = storeURL
        let migrationSteps = migrationStepsForStore(at: storeURL, toVersion: version)
        
        for migrationStep in migrationSteps {
            let manager = NSMigrationManager(sourceModel: migrationStep.sourceModel, destinationModel: migrationStep.destinationModel)
            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString + ".sqlite")
            
            do {
                try manager.migrateStore(from: currentURL, sourceType: NSSQLiteStoreType, options: nil, with: migrationStep.mappingModel, toDestinationURL: tempDirectoryURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
                printLog("db_migration: migrate store from \(currentURL) to \(tempDirectoryURL)")
            } catch let error {
                fatalLog("failed attempting to migrate from \(migrationStep.sourceModel) to \(migrationStep.destinationModel), error: \(error)")
            }
            
            if currentURL != storeURL {
                //Destroy intermediate step's store
                NSPersistentStoreCoordinator.destroyStore(at: currentURL)
            }
            
            currentURL = tempDirectoryURL
        }
        
        printLog("db_migration: replace store at \(storeURL) with \(currentURL)")
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

        printLog("db_migration: prepare steps from \(sourceVersion) to \(destinationVersion)")
        
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
        
        printLog("db_migration: WALCheckpointing")
        
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
            let model = NSManagedObjectModel.with(name: $0.name, directory: CoreDataConfig.modelDirectoryName)
            
            return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        return compatibleVersion
    }
    
    func isCompatibleWithStoreMetadata(_ metadata: [String : Any]) -> Bool {
        return CoreDataMigrationVersion.compatibleVersionForStoreMetadata(metadata) == self
    }
}
