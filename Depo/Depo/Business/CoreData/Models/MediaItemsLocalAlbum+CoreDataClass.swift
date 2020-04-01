//
//  MediaItemsLocalAlbum+CoreDataClass.swift
//  Depo
//
//  Created by Konstantin Studilin on 17/03/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//
//

import Foundation
import CoreData


public class MediaItemsLocalAlbum: NSManagedObject {
    convenience init(asset: PHAssetCollection, context: NSManagedObjectContext) {
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItemsLocalAlbum.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        localId = asset.localIdentifier
        name = asset.localizedTitle
        isMain = asset.assetCollectionSubtype == .smartAlbumUserLibrary
        
        updateRelatedMediaItems(album: asset, context: context)
        updateRelatedRemoteAlbums(context: context)
    }
}

extension MediaItemsLocalAlbum {
    private func updateRelatedMediaItems(album: PHAssetCollection, context: NSManagedObjectContext) {
        let assetsIdentifiers = album.allAssets.compactMap { $0.localIdentifier }
        
        let request: NSFetchRequest = MediaItem.fetchRequest()
        request.predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.localFileID) IN %@", assetsIdentifiers)
        
        if let relatedMediaItems = try? context.fetch(request) {
            relatedMediaItems.forEach {
                addToItems($0)
                $0.isAvailable = true //by default for new Album
            }
        }
    }
    
    func updateRelatedRemoteAlbums(context: NSManagedObjectContext) {
        guard let name = name else {
            relatedRemote = nil
            return
        }
        
        let request: NSFetchRequest = MediaItemsAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "\(MediaItemsAlbum.PropertyNameKey.name) = %@", name)
        
        if let relatedAlbums = try? context.fetch(request) {
            relatedRemote = relatedAlbums.first
        }
    }
}
