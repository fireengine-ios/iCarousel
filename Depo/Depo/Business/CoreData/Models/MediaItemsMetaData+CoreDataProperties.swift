//
//  MediaItemsMetaData+CoreDataProperties.swift
//  
//
//  Created by Aleksandr on 10/23/17.
//
//

import Foundation
import CoreData


extension MediaItemsMetaData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaItemsMetaData> {
        return NSFetchRequest<MediaItemsMetaData>(entityName: "MediaItemsMetaData")
    }

    @NSManaged public var album: String?
    @NSManaged public var artist: String?
    @NSManaged public var duration: Double
    @NSManaged public var genre: [String]?
    @NSManaged public var height: Int16
    @NSManaged public var largeUrl: String?
    @NSManaged public var mediumUrl: String?
    @NSManaged public var smalURl: String?
    @NSManaged public var videoPreviewUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var width: Int16
    @NSManaged public var item: MediaItem?
    @NSManaged public var takenDate: NSDate?

}
