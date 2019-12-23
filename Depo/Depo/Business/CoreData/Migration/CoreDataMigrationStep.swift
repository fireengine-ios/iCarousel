//
//  CoreDataMigrationStep.swift
//  Depo
//
//  Created by Konstantin Studilin on 21/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import CoreData


struct CoreDataMigrationStep {
    // MARK: - Mapping
    
    private static func mappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
        guard let customMapping = customMappingModel(fromSourceModel: sourceModel, toDestinationModel: destinationModel) else {
            return inferredMappingModel(fromSourceModel:sourceModel, toDestinationModel: destinationModel)
        }
        
        return customMapping
    }
    
    private static func inferredMappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
        return try? NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
    }
    
    private static func customMappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
        return NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel)
    }
    
    
    // MARK : - Properties
    
    let sourceModel: NSManagedObjectModel
    let destinationModel: NSManagedObjectModel
    let mappingModel: NSMappingModel
    
    
    // MARK: Init
    
    init(sourceVersion: CoreDataMigrationVersion, destinationVersion: CoreDataMigrationVersion) {
        let sourceModel = NSManagedObjectModel.managedObjectModel(forName: sourceVersion.name, directory: CoreDataConfig.modelDirectoryName)
        let destinationModel = NSManagedObjectModel.managedObjectModel(forName: destinationVersion.name, directory: CoreDataConfig.modelDirectoryName)
        
        guard let mappingModel = CoreDataMigrationStep.mappingModel(fromSourceModel: sourceModel, toDestinationModel: destinationModel) else {
            fatalError("Expected modal mapping not present")
        }
        
        self.sourceModel = sourceModel
        self.destinationModel = destinationModel
        self.mappingModel = mappingModel
    }
}
