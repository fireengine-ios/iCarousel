//
//  MediaItem+CoreDataProperties.swift
//  
//
//  Created by Alexander Gurin on 8/23/17.
//
//

import Foundation
import CoreData


extension MediaItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaItem> {
        return NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
    }

    @NSManaged public var creationDateValue: NSDate?
    @NSManaged public var favoritesValue: Bool
    @NSManaged public var fileSizeValue: Int64
    @NSManaged public var fileTypeValue: Int16
    @NSManaged public var idValue: Int64
    @NSManaged public var isLocalItemValue: Bool
    @NSManaged public var lastModifiDateValue: NSDate?
    @NSManaged public var trimmedLocalFileID: String?
    @NSManaged public var localFileID: String?
    @NSManaged public var md5Value: String?
    @NSManaged public var monthValue: String?
    @NSManaged public var nameValue: String?
    @NSManaged public var patchToPreviewValue: String?
    @NSManaged public var parent: String?
    @NSManaged public var syncStatusValue: Int16
    @NSManaged public var urlToFileValue: String?
    @NSManaged public var albums: NSOrderedSet?
    @NSManaged public var metadata: MediaItemsMetaData?
    @NSManaged public var isFolder: Bool
    @NSManaged public var objectSyncStatus: NSSet?
    @NSManaged public var isFiltered: Bool///on that photo was applied filter From Home page
    @NSManaged public var isICloud: Bool
    @NSManaged public var relatedLocal: MediaItem?
    @NSManaged public var relatedRemotes: NSSet
    @NSManaged public var session: Session?
}


extension MediaItem {
    public var albumsUUIDs: [String] {
        return self.albums?.flatMap({ album -> String? in
            (album as? MediaItemsAlbum)?.uuid
        }) ?? []
    }
    
    public var syncStatusesArray: [String] {
        return objectSyncStatus?.allObjects.flatMap({ syncStatus -> String? in
            (syncStatus as? MediaItemsObjectSyncStatus)?.userID
        }) ?? []
    }
}

// MARK: Generated accessors for albums
extension MediaItem {
    
    @objc(insertObject:inAlbumsAtIndex:)
    @NSManaged public func insertIntoAlbums(_ value: MediaItemsAlbum, at idx: Int)
    
    @objc(removeObjectFromAlbumsAtIndex:)
    @NSManaged public func removeFromAlbums(at idx: Int)
    
    @objc(insertAlbums:atIndexes:)
    @NSManaged public func insertIntoAlbums(_ values: [MediaItemsAlbum], at indexes: NSIndexSet)
    
    @objc(removeAlbumsAtIndexes:)
    @NSManaged public func removeFromAlbums(at indexes: NSIndexSet)
    
    @objc(replaceObjectInAlbumsAtIndex:withObject:)
    @NSManaged public func replaceAlbums(at idx: Int, with value: MediaItemsAlbum)
    
    @objc(replaceAlbumsAtIndexes:withAlbums:)
    @NSManaged public func replaceAlbums(at indexes: NSIndexSet, with values: [MediaItemsAlbum])
    
    @objc(addAlbumsObject:)
    @NSManaged public func addToAlbums(_ value: MediaItemsAlbum)
    
    @objc(removeAlbumsObject:)
    @NSManaged public func removeFromAlbums(_ value: MediaItemsAlbum)
    
    @objc(addAlbums:)
    @NSManaged public func addToAlbums(_ values: NSOrderedSet)
    
    @objc(removeAlbums:)
    @NSManaged public func removeFromAlbums(_ values: NSOrderedSet)
    
}

// MARK: Generated accessors for objectSyncStatus
extension MediaItem {
    
    @objc(addObjectSyncStatusObject:)
    @NSManaged public func addToObjectSyncStatus(_ value: MediaItemsObjectSyncStatus)
    
    @objc(removeObjectSyncStatusObject:)
    @NSManaged public func removeFromObjectSyncStatus(_ value: MediaItemsObjectSyncStatus)
    
    @objc(addObjectSyncStatus:)
    @NSManaged public func addToObjectSyncStatus(_ values: NSSet)
    
    @objc(removeObjectSyncStatus:)
    @NSManaged public func removeFromObjectSyncStatus(_ values: NSSet)
    
}

// MARK: Generated accessors for relatedRemotes
extension MediaItem {
    
    @objc(addRelatedRemotesObject:)
    @NSManaged public func addToRelatedRemotes(_ value: MediaItem)
    
    @objc(removeRelatedRemotesObject:)
    @NSManaged public func removeFromRelatedRemotes(_ value: MediaItem)
    
    @objc(addRelatedRemotes:)
    @NSManaged public func addToRelatedRemotes(_ values: NSSet)
    
    @objc(removeRelatedRemotes:)
    @NSManaged public func removeFromRelatedRemotes(_ values: NSSet)
    
}
