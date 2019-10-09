//
//  CoreDataMigrationModel.swift
//  Depo
//
//  Created by Konstantin Studilin on 07/10/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


struct CoreDataConfig {
    private init() {}
    
    static let modelBaseName = "LifeBoxModel"
    static let modelDirectoryName = modelBaseName + ".momd"
    static let storeNameShort = "DataModel"
    static let storeNameFull = storeNameShort + ".sqlite"
}

struct CoreDataMigrationStep {
    let source: NSManagedObjectModel
    let destination: NSManagedObjectModel
    let mapping: NSMappingModel
}

enum CoreDataVersion: Int, CaseIterable {
    case version_1 = 1
    case version_2 // unused
    case version_3
    
    // MARK: - Accessors
    
    var name: String {
        if rawValue == 1 {
            return CoreDataConfig.modelBaseName
        } else {
            return CoreDataConfig.modelBaseName + "\(rawValue)"
        }
    }
    
    static var latest: CoreDataVersion {
        guard let last = allCases.last else {
            //no way to be here
            fatalError("add at least one CoreDataVersion case")
        }
        
        return last
    }
}

class CoreDataMigrationModel {
    
    static let all = CoreDataVersion.allCases.compactMap { CoreDataMigrationModel(version: $0) }
    static let current = CoreDataMigrationModel(version: CoreDataVersion.latest)

    static func migrationModelCompatible(with metadata: [String : Any]) -> CoreDataMigrationModel? {
        let compatibleMigrationModel = CoreDataMigrationModel.all.first {
            $0.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        return compatibleMigrationModel
    }
    
    
    /**
     Determines the next model version from the current model version.
     
     NB: the next version migration is not always the next actual version. With
     this solution we can skip "bad/corrupted" versions.
     */
    private lazy var successor: CoreDataMigrationModel? = {
        switch self.version {
        case .version_1:
            // version_2 is unused
            return CoreDataMigrationModel(version: .version_3)
        default:
            return nil
        }
    }()
    
    private let bundle = Bundle.main
    
    let version: CoreDataVersion
    
    
    // MARK: - Init
    
    init(version: CoreDataVersion) {
        self.version = version
    }
    
    // MARK: - Model
    
    private func modelURL() -> URL? {
        let omoURL = bundle.url(forResource: version.name, withExtension: "omo", subdirectory: CoreDataConfig.modelDirectoryName)
        let momURL = bundle.url(forResource: version.name, withExtension: "mom", subdirectory: CoreDataConfig.modelDirectoryName)
        
        /// Use optimized model version only if iOS >= 11
        if #available(iOS 11, *) {
            return omoURL ?? momURL
        } else {
            return momURL ?? omoURL
        }
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
           guard let modelURL = modelURL() else {
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

    
    // MARK: - Mapping
    
    private func mappingModelToSuccessor() -> NSMappingModel? {
        guard let nextVersion = successor else {
            return nil
        }
        
        //check if custom mapping is required or not (default)
        switch version {
        case .version_1:
            guard let mapping = customMappingModel(to: nextVersion) else {
                return nil
            }
            return mapping
            
        default:
            return inferredMappingModel(to: nextVersion)
        }
    }
    
    private func inferredMappingModel(to nextModel: CoreDataMigrationModel) -> NSMappingModel {
        do {
            let destinationObjectModel = nextModel.managedObjectModel
            return try NSMappingModel.inferredMappingModel(forSourceModel: managedObjectModel, destinationModel: destinationObjectModel)
        } catch {
            let errorMessage = "Unable to generate inferred mapping model from \(version.name) to \(nextModel.version.name)"
            debugLog(errorMessage)
            fatalError(errorMessage)
        }
    }
    
    private func customMappingModel(to nextModel: CoreDataMigrationModel) -> NSMappingModel? {
        let destinationObjectModel = nextModel.managedObjectModel
        
        return NSMappingModel(from: [bundle], forSourceModel: managedObjectModel, destinationModel: destinationObjectModel)
    }
    
    // MARK: - MigrationSteps
    
    func migrationSteps(to model: CoreDataMigrationModel) -> [CoreDataMigrationStep] {
        guard self.version != model.version else {
            return []
        }
        
        guard let mapping = mappingModelToSuccessor(), let nextModel = successor else {
            return []
        }
        
        let destinationObjectModel = nextModel.managedObjectModel
        
        let step = CoreDataMigrationStep(source: managedObjectModel, destination: destinationObjectModel, mapping: mapping)
        let nextStep = nextModel.migrationSteps(to: model)
        
        return [step] + nextStep
    }
}


// MARK: - Source
final class CoreDataMigrationSourceModel: CoreDataMigrationModel {
    
    // MARK: - Init
    
    init?(storeURL: URL) {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return nil
        }
        
        let migrationVersionModel = CoreDataMigrationModel.all.first {
            $0.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        guard let versionModel = migrationVersionModel else {
            return nil
        }
        
        super.init(version: versionModel.version)
    }
}
