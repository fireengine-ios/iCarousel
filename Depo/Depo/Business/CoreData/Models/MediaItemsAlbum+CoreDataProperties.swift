//
//  MediaItemsAlbum+CoreDataProperties.swift
//  
//
//  Created by Alexander Gurin on 9/19/17.
//
//

import Foundation
import CoreData


extension MediaItemsAlbum {
    
    static let Identifier = "MediaItemsAlbum"
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaItemsAlbum> {
        return NSFetchRequest<MediaItemsAlbum>(entityName: MediaItemsAlbum.Identifier)
    }

    @NSManaged public var audioCount: Int64
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var fileType: Int16
    @NSManaged public var imageCount: Int64
    @NSManaged public var lastModifiDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var readOnly: Bool
    @NSManaged public var uploadDateValue: NSDate?
    @NSManaged public var uuid: String?
    @NSManaged public var videoCount: Int64
    @NSManaged public var items: NSSet?
}

// MARK: Generated accessors for items
extension MediaItemsAlbum {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: MediaItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: MediaItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
