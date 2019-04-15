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
        copyInfo(metaData: metadata)
    }
 
    func copyInfo(metaData: BaseMetaData?) {
        guard let metaData = metaData else {
            return
        }
        
        self.takenDate = metaData.takenDate as NSDate?
        self.title = metaData.title
        self.album = metaData.album
        self.artist = metaData.artist
        self.duration = metaData.duration
        self.genre = metaData.genre
        self.height = Int16(metaData.height)
        self.width = Int16(metaData.width)
        self.largeUrl = metaData.largeUrl?.absoluteString
        self.mediumUrl = metaData.mediumUrl?.absoluteString
        self.smalURl = metaData.smalURl?.absoluteString
        self.videoPreviewUrl = metaData.videoPreviewURL?.absoluteString
    }
}
