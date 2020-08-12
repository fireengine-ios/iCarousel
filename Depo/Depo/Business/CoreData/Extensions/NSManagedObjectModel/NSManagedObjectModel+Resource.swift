//
//  NSManagedObjectModel+Resource.swift
//  Depo
//
//  Created by Konstantin Studilin on 21/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import CoreData


extension NSManagedObjectModel {
    
    static func with(name: String, directory: String) -> NSManagedObjectModel {
        let bundle = Bundle.main
        let omoURL = bundle.url(forResource: name, withExtension: "omo", subdirectory: directory)
        let momURL = bundle.url(forResource: name, withExtension: "mom", subdirectory: directory)
        
        let url = omoURL ?? momURL
        
        guard let modelURL = url else {
            fatalLog("unable to find model in bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalLog("unable to load model in bundle")
        }
        
        return model
    }
}
