//
//  MediaItemsAlbum+CoreDataClass.swift
//  
//
//  Created by Alexander Gurin on 9/19/17.
//
//

import Foundation
import CoreData


public class MediaItemsAlbum: NSManagedObject {
    convenience init(uuid: String?, name: String?, context: NSManagedObjectContext) {
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItemsAlbum.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        self.uuid = uuid
        self.name = name
    }
}

