//
//  NSManagedObjectModel+Compatible.swift
//  Depo
//
//  Created by Konstantin Studilin on 21/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import CoreData


extension NSManagedObjectModel {
    
    static func compatibleModelForStoreMetadata(_ metadata: [String : Any]) -> NSManagedObjectModel? {
        let mainBundle = Bundle.main
        return NSManagedObjectModel.mergedModel(from: [mainBundle], forStoreMetadata: metadata)
    }
}
