//
//  MediaItemsMetaData+CoreDataClass.swift
//  
//
//  Created by Alexander Gurin on 9/19/17.
//
//

import Foundation
import CoreData


public class MediaItemsMetaData: NSManagedObject {
    
    static let Identifier = "MediaItemsMetaData"
    
    convenience init(metadata: BaseMetaData?, context: NSManagedObjectContext) {
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItemsMetaData.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        self.album = metadata?.album
        self.artist = metadata?.artist
        self.duration = metadata?.duration ?? Double(-1.0)
        self.genre = metadata?.genre
        self.height = Int16(metadata?.height ?? 0)
        self.width = Int16(metadata?.width ?? 0)
        self.largeUrl = metadata?.largeUrl?.absoluteString
        self.mediumUrl = metadata?.mediumUrl?.absoluteString
        self.smalURl = metadata?.smalURl?.absoluteString
        self.title = metadata?.title
    }

}
