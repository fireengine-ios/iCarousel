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
        
        self.localId = asset.localIdentifier
        self.name = asset.localizedTitle
        self.isMain = asset.assetCollectionSubtype == .smartAlbumUserLibrary
    }
}
