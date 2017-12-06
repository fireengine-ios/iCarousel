//
//  MediaItemsObjectSyncStatus+CoreDataClass.swift
//  Depo_LifeTech
//
//  Created by Oleg on 06.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import CoreData


public class MediaItemsObjectSyncStatus: NSManagedObject {
    
    static let Identifier = "ObjectSyncStatus"
    
    convenience init(userID: String, context: NSManagedObjectContext) {
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItemsMetaData.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        self.userID = userID
    }
    
}
