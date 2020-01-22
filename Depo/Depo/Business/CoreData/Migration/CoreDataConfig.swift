//
//  CoreDataConfig.swift
//  Depo
//
//  Created by Konstantin Studilin on 21/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//


struct CoreDataConfig {
    private init() {}
    
    static let modelBaseName = "LifeBoxModel"
    static let modelDirectoryName = modelBaseName + ".momd"
    static let storeNameShort = "DataModel"
    static let storeNameFull = storeNameShort + ".sqlite"
    
    static var storeUrl: URL {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalLog("Unable to resolve document directory")
        }
        
        return docURL.appendingPathComponent(storeNameFull)
    }
}
