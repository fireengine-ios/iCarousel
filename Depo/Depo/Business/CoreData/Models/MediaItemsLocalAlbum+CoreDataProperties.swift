//
//  MediaItemsLocalAlbum+CoreDataProperties.swift
//  Depo
//
//  Created by Konstantin Studilin on 17/03/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//
//

import Foundation
import CoreData

extension MediaItemsLocalAlbum {
    enum PropertyNameKey {
        static let creationDate = #keyPath(MediaItemsLocalAlbum.creationDate)
        static let fileType = #keyPath(MediaItemsLocalAlbum.fileType)
        static let isEnabled = #keyPath(MediaItemsLocalAlbum.isEnabled)
        static let isMain = #keyPath(MediaItemsLocalAlbum.isMain)
        static let localId = #keyPath(MediaItemsLocalAlbum.localId)
        static let name = #keyPath(MediaItemsLocalAlbum.name )
        static let items = #keyPath(MediaItemsLocalAlbum.items)
        static let relatedRemote = #keyPath(MediaItemsLocalAlbum.relatedRemote)
    }
}

extension MediaItemsLocalAlbum {
    
    static let Identifier = "MediaItemsLocalAlbum"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaItemsLocalAlbum> {
        return NSFetchRequest<MediaItemsLocalAlbum>(entityName: "MediaItemsLocalAlbum")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var fileType: Int16
    @NSManaged public var isEnabled: Bool
    @NSManaged public var isMain: Bool
    @NSManaged public var localId: String?
    @NSManaged public var name: String?
    @NSManaged public var items: NSOrderedSet?
    @NSManaged public var relatedRemote: MediaItemsAlbum?

}

// MARK: Generated accessors for items
extension MediaItemsLocalAlbum {

    @objc(insertObject:inItemsAtIndex:)
    @NSManaged public func insertIntoItems(_ value: MediaItem, at idx: Int)

    @objc(removeObjectFromItemsAtIndex:)
    @NSManaged public func removeFromItems(at idx: Int)

    @objc(insertItems:atIndexes:)
    @NSManaged public func insertIntoItems(_ values: [MediaItem], at indexes: NSIndexSet)

    @objc(removeItemsAtIndexes:)
    @NSManaged public func removeFromItems(at indexes: NSIndexSet)

    @objc(replaceObjectInItemsAtIndex:withObject:)
    @NSManaged public func replaceItems(at idx: Int, with value: MediaItem)

    @objc(replaceItemsAtIndexes:withItems:)
    @NSManaged public func replaceItems(at indexes: NSIndexSet, with values: [MediaItem])

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: MediaItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: MediaItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSOrderedSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSOrderedSet)

}
