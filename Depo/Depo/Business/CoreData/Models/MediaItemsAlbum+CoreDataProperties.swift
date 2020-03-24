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
    enum PropertyNameKey {
        static let audioCount = #keyPath(MediaItemsAlbum.audioCount)
        static let creationDate = #keyPath(MediaItemsAlbum.creationDate)
        static let fileType = #keyPath(MediaItemsAlbum.fileType)
        static let imageCount = #keyPath(MediaItemsAlbum.imageCount)
        static let lastModifiDate = #keyPath(MediaItemsAlbum.lastModifiDate)
        static let name = #keyPath(MediaItemsAlbum.name)
        static let readOnly = #keyPath(MediaItemsAlbum.readOnly)
        static let uploadDateValue = #keyPath(MediaItemsAlbum.uploadDateValue)
        static let uuid = #keyPath(MediaItemsAlbum.uuid)
        static let videoCount = #keyPath(MediaItemsAlbum.videoCount)
        static let items = #keyPath(MediaItemsAlbum.items)
    }
}

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
