//
//  CoreDataMigrationVersion.swift
//  Depo
//
//  Created by Konstantin Studilin on 21/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//


enum CoreDataMigrationVersion: Int, CaseIterable {
    case version_1 = 1
    case version_2 // skipped
    case version_3
    case version_4
    
    static var latest: CoreDataMigrationVersion {
        guard let last = allCases.last else {
            //no way to be here
            fatalError("add at least one CoreDataVersion case")
        }
        
        return last
    }
    
    var name: String {
        if rawValue == 1 {
            return CoreDataConfig.modelBaseName
        } else {
            return CoreDataConfig.modelBaseName + " " + "\(rawValue)"
        }
    }
    
    var next: CoreDataMigrationVersion? {
        switch self {
        case .version_1:
            return .version_3
            
        case .version_2:
            assertionFailure("version_2 is unused")
            return nil
            
        case .version_3:
            return .version_4
            
        default:
            return nil
        }
    }
}
