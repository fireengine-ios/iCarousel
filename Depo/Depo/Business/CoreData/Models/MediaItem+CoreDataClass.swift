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
        
        uuid = wrapData.uuid

        nameValue = wrapData.name
        
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
            patchToPreviewValue = nil
        }
        
        md5Value = wrapData.md5
        trimmedLocalFileID = wrapData.getTrimmedLocalID()
        
        if isLocalItemValue {
            ///This staus setup only works when all remotes added beforehand
            let relatedTothisItemsRemotes = getAllRelatedItems(wrapItem: wrapData, findRelatedLocals: !isLocalItemValue, context: context)
            relatedRemotes = NSSet(array: relatedTothisItemsRemotes)
            updateLocalRelated(remotesMediaItems: relatedTothisItemsRemotes)
        }
            //TODO:CODE BELOW NEED TO BE TESTED
        else {
            let relatedTothisItemsLocals = getAllRelatedItems(wrapItem: wrapData, findRelatedLocals: isLocalItemValue, context: context)
            relatedLocal = relatedTothisItemsLocals.first
            updateRemoteRelated(localMediaItems: relatedTothisItemsLocals)
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
    
    private func getRemoteTrimmedID(json: JSON) -> String  {
        let uuid = json[SearchJsonKey.uuid].stringValue
        if uuid.contains("~"){
            return uuid.components(separatedBy: "~").first ?? uuid
        }
        return uuid
    }
    
    private func convertToMediaItems(syncStatuses: [String], context: NSManagedObjectContext) -> NSSet {
        return NSSet(array: syncStatuses.flatMap { MediaItemsObjectSyncStatus(userID: $0, context: context) })
    }

    var wrapedObject: WrapData {
        return WrapData(mediaItem: self)
    }
    
    func wrapedObject(with asset: PHAsset) -> WrapData {
        return WrapData(mediaItem: self, asset: asset)
    }
    
    func copyInfo(item: WrapData, context: NSManagedObjectContext) {
        ///FOR NOW we copy everything, could downgrated to just urls and name
        
        metadata?.copyInfo(metaData: item.metaData)
        
        creationDateValue = item.metaDate as NSDate?
        lastModifiDateValue = item.lastModifiDate as NSDate?
        urlToFileValue = item.tmpDownloadUrl?.absoluteString
        
        switch item.patchToPreview {
        case let .remoteUrl(url):
            patchToPreviewValue = url?.absoluteString
        case let .localMediaContent(assetContent):
            let localID = assetContent.asset.localIdentifier
            localFileID = localID
            patchToPreviewValue = nil
        }
        
        trimmedLocalFileID = item.getTrimmedLocalID()
        parent = item.parent
        monthValue = item.creationDate?.getDateForSortingOfCollectionView()
        md5Value = item.md5
        isFolder = item.isFolder ?? false
        favoritesValue = item.favorites
        fileTypeValue = item.fileType.valueForCoreDataMapping()
        fileSizeValue = item.fileSize
        nameValue = item.name
        idValue = item.id ?? -1
        uuid = item.uuid
        
        //
        self.albums?.forEach { album in
            if let savedAlbum = album as? MediaItemsAlbum {
                context.delete(savedAlbum)
            }
        }
        //
        let albums = item.albums?.map({ albumUuid -> MediaItemsAlbum in
            MediaItemsAlbum(uuid: albumUuid, context: context)
        })
        self.albums = NSOrderedSet(array: albums ?? [])
    }
}

//MARK: - relations
extension MediaItem {

    private func getRelatedPredicate(item: WrapData, findRelatedLocals: Bool) -> NSPredicate {
        return NSPredicate(format: "isLocalItemValue == %@ AND (trimmedLocalFileID == %@ OR md5Value == %@)", NSNumber(value: findRelatedLocals), item.getTrimmedLocalID(), item.md5)
    }
    
    func getAllRelatedItems(wrapItem: WrapData, findRelatedLocals: Bool, context: NSManagedObjectContext)  -> [MediaItem] {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = getRelatedPredicate(item: wrapItem, findRelatedLocals: findRelatedLocals)
        let relatedLocals = try? context.fetch(request)
        return relatedLocals ?? []
    }
    
    private func updateLocalRelated(remotesMediaItems: [MediaItem]) {
        remotesMediaItems.forEach {
            $0.relatedLocal = self
        }
    }
    
    private func updateRemoteRelated(localMediaItems: [MediaItem]) {
        localMediaItems.forEach {
            $0.relatedRemotes.adding(self)
        }
    }
}
