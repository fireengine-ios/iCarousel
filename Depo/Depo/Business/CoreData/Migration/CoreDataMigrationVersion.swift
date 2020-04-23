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
    case version_5
    
    static var latest: CoreDataMigrationVersion {
        guard let last = allCases.last else {
            fatalLog("add at least one CoreDataVersion case")
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
            
        case .version_4:
            return .version_5
            
        default:
            return nil
        }
    }
}
