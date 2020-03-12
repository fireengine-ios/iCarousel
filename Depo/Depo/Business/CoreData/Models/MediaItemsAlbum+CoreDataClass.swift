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
    convenience init(uuid: String?, context: NSManagedObjectContext) {
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItemsAlbum.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        self.uuid = uuid
    }
    
    convenience init(asset: PHAssetCollection, context: NSManagedObjectContext) {
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItemsAlbum.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        self.localId = asset.localIdentifier
        self.name = asset.localizedTitle
        self.isLocal = true
    }
}
