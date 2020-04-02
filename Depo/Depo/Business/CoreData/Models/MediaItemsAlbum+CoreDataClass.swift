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
        
        updateRelatedLocalAlbum(context: context)
    }
}

extension MediaItemsAlbum {
    func updateRelatedLocalAlbum(context: NSManagedObjectContext) {
        guard let name = name else {
            relatedLocal = nil
            return
        }
        
        let request: NSFetchRequest = MediaItemsLocalAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "\(MediaItemsLocalAlbum.PropertyNameKey.name) = %@", name)
        
        if let relatedAlbums = try? context.fetch(request) {
            relatedLocal = relatedAlbums.first
        }
    }
}
