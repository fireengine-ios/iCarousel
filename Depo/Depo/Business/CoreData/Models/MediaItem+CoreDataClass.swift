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

//        let char: Character = nameValue?.first ?? " "
//        fileNameFirstChar = String(describing: char).uppercased()
        
        fileTypeValue = wrapData.fileType.valueForCoreDataMapping()
        fileSizeValue = wrapData.fileSize
        syncStatusValue = wrapData.syncStatus.valueForCoreDataMapping()
        favoritesValue = wrapData.favorites
        isLocalItemValue = wrapData.isLocalItem
        creationDateValue = wrapData.metaDate as NSDate?//wrapData.creationDate as NSDate?
        ///need to discuss that, we might use creation date after all.
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
//            trimmedLocalFileID = localID.components(separatedBy: "/").first ?? localID need to test this
            patchToPreviewValue = nil
        }
        
        md5Value = wrapData.md5
        trimmedLocalFileID = wrapData.getTrimmedLocalID()
        
        if isLocalItemValue {
            ///This staus setup only works when all remotes added beforehand
            let relatedTothisItemsRemotes = getAllRelatedRemotes(wrapItem: wrapData, context: context)
            relatedRemotes = NSSet(array: relatedTothisItemsRemotes)
            updateLocalRelated(remotesMediaItems: relatedTothisItemsRemotes)
        }
        
        if !isLocalItemValue, let md5 = md5Value, let trimmedID = trimmedLocalFileID,
            (md5.isEmpty || trimmedID.isEmpty) {
            debugPrint("!!! REMOTE ITEM MD5 EMPY \(md5Value) AND LOCAL ID \(trimmedLocalFileID)")
        }
        
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

//MARK: - relations
extension MediaItem {
    ///This staus setup only works when all remotes added beforehand
    private func getAllRelatedRemotes(wrapItem: WrapData, context: NSManagedObjectContext) -> [MediaItem] {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = NSPredicate(format: "isLocalItemValue == FALSE AND (trimmedLocalFileID == %@ OR md5Value == %@)", wrapItem.getTrimmedLocalID(), wrapItem.md5)///TODO: MD5
        let relatedRemotes = try? context.fetch(request)
        return relatedRemotes ?? []
    }

    private func updateLocalRelated(remotesMediaItems: [MediaItem]) {
        remotesMediaItems.forEach {
            $0.relatedLocal = self
        }
    }
    
}
