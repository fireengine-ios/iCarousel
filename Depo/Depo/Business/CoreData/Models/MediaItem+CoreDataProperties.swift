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
    @NSManaged public var fileNameFirstChar: String?
    @NSManaged public var fileSizeValue: Int64
    @NSManaged public var fileTypeValue: Int16
    @NSManaged public var idValue: Int64
    @NSManaged public var isLocalItemValue: Bool
    @NSManaged public var lastModifiDateValue: NSDate?
    @NSManaged public var localFileID: String?
    @NSManaged public var md5Value: String?
    @NSManaged public var monthValue: String?
    @NSManaged public var nameValue: String?
    @NSManaged public var patchToPreviewValue: String?
    @NSManaged public var parent: String?
    @NSManaged public var syncStatusValue: Int16
    @NSManaged public var urlToFileValue: String?
    @NSManaged public var uuidValue: String?
    @NSManaged public var albums: NSOrderedSet?
    @NSManaged public var metadata: MediaItemsMetaData?
    @NSManaged public var isFolder: Bool
    @NSManaged public var objectSyncStatus: NSSet?
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
    
    @objc(addAlbumsObject:)
    @NSManaged public func addToAlbums(_ value: MediaItemsAlbum)
    
    @objc(removeAlbumsObject:)
    @NSManaged public func removeFromAlbums(_ value: MediaItemsAlbum)
    
    @objc(addAlbums:)
    @NSManaged public func addToAlbums(_ values: NSSet)
    
    @objc(removeAlbums:)
    @NSManaged public func removeFromAlbums(_ values: NSSet)
    
    
    @objc(addObjectSyncStatusObject:)
    @NSManaged public func addToObjectSyncStatus(_ value: MediaItemsObjectSyncStatus)
    
    @objc(removeObjectSyncStatusObject:)
    @NSManaged public func removeFromObjectSyncStatus(_ value: MediaItemsObjectSyncStatus)
    
    @objc(addObjectSyncStatus:)
    @NSManaged public func addToObjectSyncStatus(_ values: NSSet)
    
    @objc(removeObjectSyncStatus:)
    @NSManaged public func removeFromObjectSyncStatus(_ values: NSSet)
    
}
