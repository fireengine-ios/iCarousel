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
        favoritesValue = wrapData.favorites
        isLocalItemValue = wrapData.isLocalItem
        creationDateValue = wrapData.creationDate as NSDate?
        lastModifiDateValue = wrapData.lastModifiDate as NSDate?
        sortingDate = (wrapData.metaData?.takenDate ?? wrapData.creationDate) as NSDate?
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
        
        if !isLocalItemValue, let md5 = md5Value, let trimmedID = trimmedLocalFileID,
            (md5.isEmpty || trimmedID.isEmpty) {
            debugPrint("!!! REMOTE ITEM MD5 EMPTY \(md5Value) AND LOCAL ID \(trimmedLocalFileID)")
        }
        
        //empty monthValue for missing dates section
        switch wrapData.patchToPreview {
        case .remoteUrl(let url):
            if url != nil {
                fallthrough
            }
        default:
            monthValue = (sortingDate as Date?)?.getDateForSortingOfCollectionView()
        }
        
        let metaData = MediaItemsMetaData(metadata: wrapData.metaData,
                                          context: context)
        self.metadata = metaData
        
        //LR-2356
        let albums = wrapData.albums?.map({ albumUuid -> MediaItemsAlbum in
            MediaItemsAlbum(uuid: albumUuid, context: context)
        })
        self.albums = NSOrderedSet(array: albums ?? [])

        syncStatusValue = wrapData.syncStatus.valueForCoreDataMapping()
        
        let syncStatuses = convertToMediaItems(syncStatuses: wrapData.syncStatuses, context: context)
        objectSyncStatus = syncStatuses
        
        if isLocalItemValue {
            let savedRelatedRemotes = getRelatedRemotes(for: wrapData, context: context)
            if !savedRelatedRemotes.isEmpty {
                addToObjectSyncStatus(MediaItemsObjectSyncStatus(userID: SingletonStorage.shared.uniqueUserID, context: context))
                relatedRemotes = NSSet(array: savedRelatedRemotes)
                updateLocalRelated(remotesMediaItems: savedRelatedRemotes)
            }
        } else {
            let savedRelatedLocals = getRelatedLocals(for: wrapData, context: context)
            if !savedRelatedLocals.isEmpty {
                savedRelatedLocals.forEach {
                    $0.addToObjectSyncStatus(MediaItemsObjectSyncStatus(userID: SingletonStorage.shared.uniqueUserID, context: context))
                }
                relatedLocal = savedRelatedLocals.first
                updateRemoteRelated(localMediaItems: savedRelatedLocals)
            }
        }
    }
    
    private func getRemoteTrimmedID(json: JSON) -> String  {
        let uuid = json[SearchJsonKey.uuid].stringValue
        if uuid.contains("~"){
            return uuid.components(separatedBy: "~").first ?? uuid
        }
        return uuid
    }
    
    private func convertToMediaItems(syncStatuses: [String], context: NSManagedObjectContext) -> NSSet {
        return NSSet(array: syncStatuses.compactMap { MediaItemsObjectSyncStatus(userID: $0, context: context) })
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
        
        creationDateValue = item.creationDate as NSDate?
        lastModifiDateValue = item.lastModifiDate as NSDate?
        sortingDate = (item.metaData?.takenDate ?? item.creationDate) as NSDate?
        
        //empty monthValue for missing dates section
        switch item.patchToPreview {
        case .remoteUrl(let url):
            if url != nil {
                fallthrough
            }
        default:
            monthValue = (sortingDate as Date?)?.getDateForSortingOfCollectionView()
        }
        
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

    private func getRelatedPredicate(item: WrapData, local: Bool) -> NSPredicate {
        return NSPredicate(format: "isLocalItemValue == %@ AND (trimmedLocalFileID == %@ OR md5Value == %@)", NSNumber(value: local), item.getTrimmedLocalID(), item.md5)
    }
    
    func getRelatedLocals(for wrapItem: WrapData, context: NSManagedObjectContext)  -> [MediaItem] {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = getRelatedPredicate(item: wrapItem, local: true)
        let relatedLocals = try? context.fetch(request)
        return relatedLocals ?? []
    }
    
    func getRelatedRemotes(for wrapItem: WrapData, context: NSManagedObjectContext)  -> [MediaItem] {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = getRelatedPredicate(item: wrapItem, local: false)
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
            $0.addToRelatedRemotes(self)
        }
    }
}
