//
//  MediaItem+CoreDataClass.swift
//  
//
//  Created by Alexander Gurin on 8/23/17.
//
//

import Foundation
import CoreData
import SwiftyJSON

public class MediaItem: NSManagedObject {
    
    static let Identifier = "MediaItem"
    
    convenience init(wrapData: WrapData, context: NSManagedObjectContext) {
        
        let entityDescr = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                     in: context)!
        self.init(entity: entityDescr, insertInto: context)
        
        idValue = wrapData.id ?? -1

        nameValue = wrapData.name

        let char: Character = nameValue?.first ?? " "
        
        fileNameFirstChar = String(describing: char).uppercased()
        
        fileTypeValue = wrapData.fileType.valueForCoreDataMapping()
        fileSizeValue = wrapData.fileSize
        syncStatusValue = wrapData.syncStatus.valueForCoreDataMapping()
        favoritesValue = wrapData.favorites
        isLocalItemValue = wrapData.isLocalItem
        creationDateValue = wrapData.creationDate as NSDate?
        lastModifiDateValue = wrapData.lastModifiDate as NSDate?
        urlToFileValue = wrapData.urlToFile?.absoluteString
        
        isFolder = wrapData.isFolder ?? false
        
        parent = wrapData.parent
        
        switch wrapData.patchToPreview {
        case let .remoteUrl(url):
            patchToPreviewValue = url?.absoluteString
        case let .localMediaContent(assetContent):
            let localID = assetContent.asset.localIdentifier
            localFileID = localID
            trimmedLocalFileID = localID.components(separatedBy: "/").first ?? localID
            patchToPreviewValue = nil
        }
        
        md5Value = wrapData.md5
        
        let dateValue = self.creationDateValue as Date?
        
        monthValue = dateValue?.getDateForSortingOfCollectionView()
        
        let metaData = MediaItemsMetaData(metadata: wrapData.metaData,
                                          context: context)
        self.metadata = metaData
        
        //LR-2356
        let albums = wrapData.albums?.map({ albumUuid -> MediaItemsAlbum in
            MediaItemsAlbum(uuid: albumUuid, context: context)
        })
        self.albums = NSOrderedSet(array: albums ?? [])

        let syncStatuses = convertToMediaItems(syncStatuses: wrapData.syncStatuses, context: context)
        objectSyncStatus = syncStatuses
    }
    
    private func convertToMediaItems(syncStatuses: [String], context: NSManagedObjectContext) -> NSSet {
        return  NSSet(array: syncStatuses.flatMap { MediaItemsObjectSyncStatus(userID: $0, context: context) })
    }
    
    var wrapedObject: WrapData {
        return WrapData(mediaItem: self)
    }
    
    func wrapedObject(with asset: PHAsset) -> WrapData {
        return WrapData(mediaItem: self, asset: asset)
    }
}
