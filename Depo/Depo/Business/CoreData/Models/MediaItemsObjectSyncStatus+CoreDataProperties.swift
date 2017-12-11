//
//  MediaItemsObjectSyncStatus+CoreDataProperties.swift
//  Depo_LifeTech
//
//  Created by Oleg on 06.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

extension MediaItemsObjectSyncStatus {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaItemsMetaData> {
        return NSFetchRequest<MediaItemsMetaData>(entityName: "MediaItemsObjectSyncStatus")
    }
    
    @NSManaged public var userID: String?
    @NSManaged public var item: MediaItem?
    
}
