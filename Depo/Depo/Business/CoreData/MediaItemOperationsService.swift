//
//  MediaItemOperationsService.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

typealias WrapObjectsCallBack = (_ items: [WrapData]) -> Void
typealias WrapObjectCallBack = (_ item: WrapData?) -> Void
typealias BaseDataSourceItems = (_ baseDSItems: [BaseDataSourceItem]) -> Void
typealias MediaItemsCallBack = (_ mediaItems: [MediaItem]) -> Void
typealias MediaItemCallback = (_ mediaItem: MediaItem?) -> Void
typealias PhotoAssetsCallback = (_ assets: [PHAsset]) -> Void
typealias AppendingLocaclItemsFinishCallback = () -> Void
typealias AppendingLocaclItemsProgressCallback = (Float) -> Void
typealias AppendingLocalItemsPageAppended = ([Item])->Void

final class MediaItemOperationsService {
    
    static let shared = MediaItemOperationsService()
    
    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    private lazy var localAlbumsCache = LocalAlbumsCache.shared
    private lazy var mediaAlbumsService = MediaItemsAlbumOperationService.shared
    
    let privateQueue = DispatchQueue(label: DispatchQueueLabels.mediaItemOperationsService, attributes: .concurrent)
    
//    var pageAppendedCallBack: AppendingLocalItemsPageAppended?
    
    var inProcessLocalFiles = false
    
    
    func deleteAllEnteties(_ completion: BoolHandler?) {
        let elementsToDelete: [(type: NSManagedObject.Type, predicate: NSPredicate?)]
        elementsToDelete = [(MediaItemsAlbum.self, nil),
                            (MediaItem.self, nil)]
        
        let group = DispatchGroup()
        
        for element in elementsToDelete {
            group.enter()
            
            delete(type: element.type, predicate: element.predicate, mergeChanges: false) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion?(true)
        }
    }
    
    func deleteRemoteEntities(_ completion: BoolHandler?) {
        let remoteMediaItemsPredicate = PredicateRules().predicate(filters: [.localStatus(.nonLocal)])
        
        let elementsToDelete: [(type: NSManagedObject.Type, predicate: NSPredicate?)]
        elementsToDelete = [(MediaItemsAlbum.self, nil),
                            (MediaItem.self, remoteMediaItemsPredicate)]
        
        let group = DispatchGroup()
        
        for element in elementsToDelete {
            group.enter()
            
            delete(type: element.type, predicate: element.predicate, mergeChanges: false) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion?(true)
        }
    }
    
    func deleteRemoteEntities(uuids: [String], completion: BoolHandler?) {
        guard let remoteMediaItemsPredicate = PredicateRules().predicate(filters: [.localStatus(.nonLocal)]) else {
            completion?(false)
            return
        }
        let uuidsPredicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.uuid) IN %@", uuids)
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [remoteMediaItemsPredicate, uuidsPredicate])
        
        delete(type: MediaItem.self, predicate: compoundedPredicate, mergeChanges: false) { _ in
            completion?(true)
        }
    }
    
    private func delete(type: NSManagedObject.Type, predicate: NSPredicate?, mergeChanges: Bool, _ completion: BoolHandler?) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            do {
                let objectIDs = try [type]
                    .compactMap { $0.entityDescription(context: context)}
                    .compactMap { self.batchDeleteRequest(for: $0, predicate: predicate) }
                    .compactMap { try context.execute($0) as? NSBatchDeleteResult }
                    .compactMap { $0.result as? [NSManagedObjectID] }
                    .flatMap { $0 }
                
                let changes = [NSDeletedObjectsKey: objectIDs]

                if mergeChanges {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context.parent ?? self.coreDataStack.mainContext])
                }
                completion?(true)
                
            } catch {
                //TODO:
                completion?(false)
            }
        }
    }
    
    func deleteLocalFiles(completion: BoolHandler?) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicateRules = PredicateRules()
        guard let predicate = predicateRules.predicate(filters: [.localStatus(.local)]) else {
            return
        }
        fetchRequest.predicate = predicate
        let context = coreDataStack.newChildBackgroundContext
        self.deleteObjects(fromFetch: fetchRequest, context: context, completion: completion)
        
    }
    
    func getLocalDuplicates(localItems: @escaping MediaItemsCallBack) {
        let context = coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.relatedRemotes).@count > 0")
        
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: localItems)
    }
    
    func getLocalDuplicates(remoteItems: [Item], duplicatesCallBack: @escaping WrapObjectsCallBack) {
        getLocalDuplicates { localItems in
            var array = [WrapData]()
            let uuids = Set(remoteItems.map {$0.getTrimmedLocalID()})
            
            for localItem in localItems {
                autoreleasepool {
                    if let relatedRemotes = localItem.relatedRemotes as? Set<MediaItem> {
                        let relatedUuids = relatedRemotes.compactMap {$0.trimmedLocalFileID}
                        if !uuids.intersection(relatedUuids).isEmpty {
                            array.append(WrapData(mediaItem: localItem))
                        }
                    }
                }
            }
            
            duplicatesCallBack(array)
        }
    }
    
    //TODO: check the usefullness of it/or need of refactor
    func getLocalFilteredItem(remoteOriginalItem: Item, localFilteredPhotosCallBack: @escaping (Item?) -> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        fetchRequest.predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.md5Value) = %@ AND \(MediaItem.PropertyNameKey.isFiltered) = true", remoteOriginalItem.md5, remoteOriginalItem.getTrimmedLocalID())
        
        let context = coreDataStack.newChildBackgroundContext
        context.perform {
            guard let localDuplicatesMediaItems = (try? context.fetch(fetchRequest)) as? [MediaItem] else {
                localFilteredPhotosCallBack(nil)
                return
            }
            var array = [Item]()
            array = localDuplicatesMediaItems.compactMap { WrapData(mediaItem: $0) }
            localFilteredPhotosCallBack(array.first)
        }
        
    }
    
    private func deleteObjects(fromFetch fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, completion: BoolHandler?) {
//        let context = CoreDataStack.shared.newChildBackgroundContext
        context.perform {
            guard let fetchResult = try? context.fetch(fetchRequest),
                let unwrapedObjects = fetchResult as? [NSManagedObject],
                unwrapedObjects.count > 0
            else {
                completion?(false)
                return
            }
            
            for object in unwrapedObjects {
                if let mediaItem = object as? MediaItem,
                    let relatedRemotes = mediaItem.relatedRemotes as? Set<MediaItem> {
                    relatedRemotes.forEach {
                        $0.relatedLocal = nil
                        $0.localFileID = nil
                        $0.moveToMissingDatesIfNeeded()
                    }
                }
                context.delete(object)
            }
            self.coreDataStack.saveDataForContext(context: context, saveAndWait: true, savedCallBack: {
                completion?(true)
                debugPrint("Data base deleted objects")
            })
            
        }
    }
    
    func itemByUUID(uuid: String, context: NSManagedObjectContext? = nil, completion: @escaping WrapObjectCallBack) {
        let context = context ?? coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.uuid) = %@", uuid)
        executeRequest(predicate: predicate, context: context) { items in
            guard let item = items.first else {
                completion(nil)
                return
            }
            completion(WrapData(mediaItem: item))
        }
    }
    
    func remoteItemBy(trimmedId: String, context: NSManagedObjectContext? = nil, completion: @escaping WrapObjectCallBack) {
        let context = context ?? coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.trimmedLocalFileID) = %@", trimmedId)
        executeRequest(predicate: predicate, context: context) { items in
            guard let item = items.first else {
                completion(nil)
                return
            }
            completion(WrapData(mediaItem: item))
        }
    }
    
    func localItemBy(trimmedId: String, context: NSManagedObjectContext? = nil, completion: @escaping WrapObjectCallBack) {
        let context = context ?? coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.trimmedLocalFileID) = %@", trimmedId)
        executeRequest(predicate: predicate, context: context) { items in
            guard let item = items.first else {
                completion(nil)
                return
            }
            completion(WrapData(mediaItem: item))
        }
    }
    
    // MARK: - MediaItemOperations
    
    //TODO: check the usefullness of it/or need of refactor
    func updateLocalItemSyncStatus(item: Item, newRemote: WrapData? = nil, completion: VoidHandler? = nil) {
        coreDataStack.performBackgroundTask { [weak self] context in
            #if DEBUG
            let contextQueue = DispatchQueue.currentQueueLabelAsserted
            #endif

            guard let `self` = self else {
                return
            }
            
            
            let predicateForLocalFile = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND (\(MediaItem.PropertyNameKey.localFileID) = %@ OR \(MediaItem.PropertyNameKey.trimmedLocalFileID) = %@)", item.getLocalID(), item.getTrimmedLocalID())
            
            self.executeRequest(predicate: predicateForLocalFile, context: context) { alreadySavedMediaItems in
                alreadySavedMediaItems.forEach({ savedItem in
                    //for locals
                    savedItem.syncStatusValue = item.syncStatus.valueForCoreDataMapping()
                    
                    if savedItem.objectSyncStatus != nil {
                        savedItem.objectSyncStatus = nil
                    }
                    
                    var array = [MediaItemsObjectSyncStatus]()
                    for userID in item.syncStatuses {
                        debugLog("sync_status: synced")
                        
                        array.append(MediaItemsObjectSyncStatus(userID: userID, context: context))
                    }
                    savedItem.objectSyncStatus = NSSet(array: array)
                    
                    if let identifier = savedItem.localFileID {
                        SharedGroupCoreDataStack.shared.saveSynced(localIdentifiers: [identifier])
                    }
                    
                    //savedItem.objectSyncStatus?.addingObjects(from: item.syncStatuses)
                })
                
                #if DEBUG
                let contextQueue2 = DispatchQueue.currentQueueLabelAsserted
                assert(contextQueue == contextQueue2, "\(contextQueue) != \(contextQueue2)")
                #endif
                
                if let newRemoteItem = newRemote {
                    //all relation will be setuped inside
                    _ = MediaItem(wrapData: newRemoteItem, context: context)
                    debugLog("sync_status: remote \(newRemote?.name ?? "") is created")
                }

                self.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: completion)
            }
        }
    }
    
    func replaceItem(uuid: String, with item: WrapData, completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                completion()
                return
            }
            
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.uuid) = %@", uuid)
            
            self.executeRequest(predicate: predicate, context: context) { [weak self] mediaItems in
                guard let self = self, let remote = mediaItems.first else {
                    completion()
                    return
                }
                
                remote.copyInfo(item: item, context: context)
                
                self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
            }
        }
    }
    
    func updateRelationsAfterMerge(with uuid: String, localItem: MediaItem, context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        let predicateForRemoteFiles = NSPredicate(format: "\(MediaItem.PropertyNameKey.uuid) = %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = false", uuid)
        
        executeRequest(predicate: predicateForRemoteFiles, context: context) { alreadySavedRemoteItems in
            alreadySavedRemoteItems.forEach {
                if $0.relatedLocal == nil {
                    $0.relatedLocal = localItem
                    localItem.addToRelatedRemotes($0)
                }
            }
            completion()
        }
    }
    
    // MARK: MediaItem
    
    func mediaItemsByIDs(ids: [NSManagedObjectID],
                         context: NSManagedObjectContext? = nil,
                         mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let context = context ?? coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "self IN %@", ids)
        executeSortedRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func mediaItemByLocalID(trimmedLocalIDS: [String],
                            context: NSManagedObjectContext? = nil,
                            mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let context = context ?? coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.trimmedLocalFileID) IN %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", trimmedLocalIDS)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func mediaItems(by localId: String,
                    context: NSManagedObjectContext,
                    mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.localFileID) = %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", localId)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func mediaItems(by localIds: [String], context: NSManagedObjectContext, mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.localFileID) IN %@", localIds)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func executeSortedRequest(predicate: NSPredicate, limit: Int = 0, context: NSManagedObjectContext, mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.fetchLimit = limit
        request.predicate = predicate
        let sortDescriptor1 = NSSortDescriptor(key: MediaItem.PropertyNameKey.monthValue, ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: MediaItem.PropertyNameKey.sortingDate, ascending: false)
        let sortDescriptor3 = NSSortDescriptor(key: MediaItem.PropertyNameKey.idValue, ascending: false)
        request.sortDescriptors = [sortDescriptor1, sortDescriptor2, sortDescriptor3]
        execute(request: request, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func executeRequest(predicate: NSPredicate, limit: Int = 0, context: NSManagedObjectContext, mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.fetchLimit = limit
        request.predicate = predicate
        execute(request: request, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func execute(request: NSFetchRequest<MediaItem>, context: NSManagedObjectContext, mediaItemsCallBack: @escaping MediaItemsCallBack) {
        context.perform {
            var result: [MediaItem] = []
            do {
                result = try context.fetch(request)
            } catch let error as NSError {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                debugLog(errorMessage)
                debugLog(error.domain)
                debugLog(error.localizedFailureReason ?? "")
                assertionFailure(errorMessage)
            } catch {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                debugLog(errorMessage)
                assertionFailure(errorMessage)
            }
            mediaItemsCallBack(result)
        }
    }
    
    // MARK: - Remote Items
    
    func appendRemoteMediaItems(remoteItems: [Item], completion: @escaping VoidHandler) {
        // OR should we mark sync status and etc here. And also affect free app?

        guard !remoteItems.isEmpty else {
            debugPrint("REMOTE_ITEMS: no files to add")
            completion()
            return
        }
        
        checkRemoteItemsExistence(wrapData: remoteItems) { newItems in
            debugPrint("REMOTE_ITEMS: \(newItems.count) of \(remoteItems.count) remote files to add")
            
            let context = self.coreDataStack.newChildBackgroundContext
            context.perform {
                newItems.forEach { item in
                    autoreleasepool {
                        _ = MediaItem(wrapData: item, context: context)
                    }
                }
                
                self.coreDataStack.saveDataForContext(context: context, saveAndWait: true, savedCallBack: completion)
            }
            
            //      ItemOperationManager.default.addedLocalFiles(items: addedObjects)
            //WARNING:- DO we need notify ItemOperationManager here???
        }
    }
    
    func updateRemoteItems(remoteItems: [WrapData]) {
        let remoteIds = remoteItems.compactMap { $0.uuid }
        let context = coreDataStack.newChildBackgroundContext
        
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND (\(MediaItem.PropertyNameKey.uuid) IN %@)", remoteIds)
        executeRequest(predicate: predicate, context: context) { mediaItems in
            for newItem in remoteItems {
                if let existed = mediaItems.first(where: {$0.uuid == newItem.uuid}) {
                    existed.copyInfo(item: newItem, context: context)
                }
            }
            self.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: nil)
        }
    }

    func updateRemoteItems(remoteItems: [WrapData], fileType: FileType, topInfo: RangeAPIInfo, bottomInfo: RangeAPIInfo, completion: @escaping VoidHandler) {
        let remoteIds = remoteItems.compactMap { $0.id }
        let context = coreDataStack.newChildBackgroundContext
    
        let inRangePredicate = createInRangePredicate(fileType: fileType, topInfo: topInfo, bottomInfo: bottomInfo)
        debugLog("RangeAPI DB updateRemoteItems")
        executeSortedRequest(predicate: inRangePredicate, limit: RequestSizeConstant.quickScrollRangeApiPageSize, context: context) { inDateRangeItems in

            debugPrint("--- remotes in date range count \(remoteItems.count)")
            debugLog("--- count of already saved in date range \(inDateRangeItems.count)")
            
            let inDateRangeItemIds = inDateRangeItems.compactMap { $0.idValue }
            let inIdRangePredicate = NSPredicate(format:"\(MediaItem.PropertyNameKey.fileTypeValue) = %d AND \(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.idValue) IN %@ AND NOT \(MediaItem.PropertyNameKey.idValue) IN %@", fileType.valueForCoreDataMapping(), remoteIds, inDateRangeItemIds)
            
            self.executeRequest(predicate: inIdRangePredicate, context: context, mediaItemsCallBack: { inIdRangeItems in
                debugLog("--- count of already saved in id range \(inIdRangeItems.count)")
                
                var allSavedItems = (inDateRangeItems + inIdRangeItems).compactMap { WrapData(mediaItem: $0) }
                debugLog("--- count of already saved TOTAL count \(allSavedItems.count)")
                
                var deletedItems = [WrapData]()
                var newSavedItems = [WrapData]()
                
                let group = DispatchGroup()
                
                for newItem in remoteItems {
                    if let existed = allSavedItems.first(where: { $0.uuid == newItem.uuid }) {
                        if (newItem != existed || existed.hasExpiredUrl()), let objectId = existed.coreDataObjectId {
                            group.enter()
                            MediaItemOperationsService.shared.mediaItemsByIDs(ids: [objectId], context: context, mediaItemsCallBack: { items in
                                if let item = items.first {
                                    item.copyInfo(item: newItem, context: context)
                                    group.leave()
                                }
                            })
                        }
                        
                        allSavedItems.remove(existed)
                    } else {
                        newSavedItems.append(newItem)
                    }
                }

                deletedItems.append(contentsOf: allSavedItems)
                
                debugLog("RangeAPI DB allSavedItems \(allSavedItems.count)")
                debugLog("RangeAPI DB deletedItems \(deletedItems.count)")
                
                group.enter()
                
                #if DEBUG
                let contextQueue = DispatchQueue.currentQueueLabelAsserted
                #endif
                
                self.deleteItems(context: context, deletedItems, completion: {
                    
                    #if DEBUG
                    let contextQueue2 = DispatchQueue.currentQueueLabelAsserted
                    assert(contextQueue == contextQueue2, "\(contextQueue) != \(contextQueue2)")
                    #endif
                    
                    newSavedItems.forEach {
                        ///Relations being setuped in the MediaItem init
                        _ = MediaItem(wrapData: $0, context: context)
                    }
                    group.leave()
                })
                
                group.notify(queue: DispatchQueue.global(), execute: {
                    /// we don't need check contextQueue for saveDataForContext bcz save() used in perform block
                    ///
                    /// "context.perform" added for the guard
                    context.perform {
                        self.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: completion)
                    }
                })
                
            })
        }
    }
    
    private func createInRangePredicate(fileType: FileType, topInfo: RangeAPIInfo, bottomInfo: RangeAPIInfo) -> NSCompoundPredicate {
        
        let filetypePredicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.fileTypeValue) = %d AND \(MediaItem.PropertyNameKey.isLocalItemValue) = false", fileType.valueForCoreDataMapping())
        
        let takenDatePredicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.sortingDate) != Nil AND \(MediaItem.PropertyNameKey.sortingDate) <= %@ AND \(MediaItem.PropertyNameKey.sortingDate) >= %@", topInfo.date as NSDate, bottomInfo.date as NSDate)
        //TODO: check why Can has problems after prep
//        let cretedDatePredicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.creationDateValue) != Nil AND \(MediaItem.PropertyNameKey.creationDateValue) <= %@ AND \(MediaItem.PropertyNameKey.creationDateValue) >= %@", topInfo.date as NSDate, bottomInfo.date as NSDate)
//
//        let takenOrCreatedDatePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [takenDatePredicate, cretedDatePredicate])
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filetypePredicate, takenDatePredicate])

        let inIdRangePredicate: NSPredicate
        if topInfo.date != bottomInfo.date {
            inIdRangePredicate = NSPredicate(value: true)
        } else {
            if let topId = topInfo.id {
                if let bottomId = bottomInfo.id {
                    inIdRangePredicate = NSPredicate(format:"\(MediaItem.PropertyNameKey.idValue) <= %ld AND \(MediaItem.PropertyNameKey.idValue) >= %ld", topId, bottomId)
                } else {
                    inIdRangePredicate = NSPredicate(format:"\(MediaItem.PropertyNameKey.idValue) <= %ld", topId)
                }
            } else if let bottomId = bottomInfo.id {
                inIdRangePredicate = NSPredicate(format:"\(MediaItem.PropertyNameKey.idValue) >= %ld", bottomId)
            } else {
                inIdRangePredicate = NSPredicate(value: true)
            }
        }
        
       return NSCompoundPredicate(andPredicateWithSubpredicates: [finalPredicate, inIdRangePredicate])
    }
    
    func getAllRemotesMediaItem(allRemotes: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false")
        executeRequest(predicate: predicate, context: coreDataStack.newChildBackgroundContext, mediaItemsCallBack: allRemotes)
    }
    
    func getRemotesMediaItems(trimmedLocalIds: [String],
                              context: NSManagedObjectContext,
                              mediaItemsCallBack: @escaping MediaItemsCallBack) {
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.trimmedLocalFileID) IN %@", trimmedLocalIds)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: mediaItemsCallBack)
    }
    
    func isNoRemotesInDB(result: @escaping (_ noRemotes: Bool) -> Void) {
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false")
        let fetchRequest = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicate
        
        execute(request: fetchRequest, context: coreDataStack.newChildBackgroundContext) { items in
            result(items.isEmpty)
        }
    }
    
    // MARK: - LocalMediaItems
    
    @objc func processLocalMediaItems(completion: VoidHandler?) {
        let localMediaStorage = LocalMediaStorage.default
        
        guard !localMediaStorage.isWaitingForPhotoPermission else {
            return
        }
        
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: false) { [weak self] _, status in
            switch status {
            case .denied:
                debugLog("will delete all local media items")
                MediaItemOperationsService.shared.deleteLocalFiles(completion: { _ in
                    completion?()
                })
            //TODO: uncomment for xcode 12
            case .authorized, .limited:
                self?.processLocalGallery(completion: completion)
            case .restricted, .notDetermined:
                break
            }
        }
    }
    
    func append(localMediaItems: [PHAsset], needCreateRelationships: Bool = false, completion: @escaping VoidHandler) {
        //needCreateRelationships = true for adding from PHPhotoLibraryChangeObserver
        
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        privateQueue.async { [weak self] in
            guard let `self` = self else {
                completion()
                return
            }
            let assetCache = LocalMediaStorage.default.assetsCache
            assetCache.append(list: localMediaItems)
            
            self.pushToLocalsAppendingQueue(assets: localMediaItems,
                                            needCreateRelationships: needCreateRelationships,
                                            completion: completion)
        }
    }
    
    func remove(localMediaItems: [PHAsset], completion: @escaping VoidHandler) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion()
            return
        }
        removeLocalMediaItems(with: localMediaItems.map { $0.localIdentifier }, completion: completion)
    }
    
    func removeZeroBytesLocalItems(completion: @escaping BoolHandler) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.fileSizeValue) = 0")
        request.predicate = predicate
        let context = coreDataStack.newChildBackgroundContext
        
        deleteObjects(fromFetch: request, context: context, completion: completion)
    }
    
    func update(localMediaItems assets: [PHAsset], completion: @escaping VoidHandler) {
        //update relationships between LocalAlbums and MediaItems
        let context = coreDataStack.newChildBackgroundContext
        
        //localMediaItemId: [albumLocalId]
        var appendRelationships = [String: [String]]()
        var deletedRelationships = [String: [String]]()
        
        let smartAssets = PHAssetCollection.smartAlbums.map { (album: $0, assets: $0.allAssets) }
    
        assets.forEach { asset in
            let albumIds = Set(localAlbumsCache.albumIds(assetId: asset.localIdentifier))
            let albumAssets = asset.containingAlbums
            var albumAssetsIds = Set(albumAssets.map { $0.localIdentifier })
            let smartAlbumsIds = smartAssets.filter { $0.assets.contains(asset) }.map { $0.album.localIdentifier }
            albumAssetsIds.formUnion(Set(smartAlbumsIds))
            
            let appendAlbumsIds = albumAssetsIds.subtracting(albumIds)
            if !appendAlbumsIds.isEmpty {
                mediaAlbumsService.createLocalAlbumsIfNeeded(localIds: Array(appendAlbumsIds), context: context)
                let assetsArray = Array(appendAlbumsIds)
                appendRelationships[asset.localIdentifier] = assetsArray
                
                assetsArray.forEach {
                    localAlbumsCache.append(albumId: $0, with: [asset.localIdentifier])
                }
            }
            
            let deletedAlbumsIds = albumIds.subtracting(albumAssetsIds)
            if !deletedAlbumsIds.isEmpty {
                let assetsArray = Array(deletedAlbumsIds)
                deletedRelationships[asset.localIdentifier] = assetsArray

                assetsArray.forEach {
                    localAlbumsCache.remove(albumId: $0, for: asset.localIdentifier)
                }
            }
        }
        
        let localIds = assets.map { $0.localIdentifier }
        mediaItems(by: localIds, context: context) { [weak self] mediaItems in
            guard let self = self else {
                return
            }
            
            deletedRelationships.forEach { assetId, albumsIds in
                if let mediaItem = mediaItems.first(where: { $0.localFileID == assetId }),
                    let relatedAlbums = mediaItem.localAlbums?.array as? [MediaItemsLocalAlbum] {
                    let detetedAlbums = relatedAlbums.filter { albumsIds.contains($0.localId ?? "") }
                    detetedAlbums.forEach {
                        mediaItem.removeFromLocalAlbums($0)
                        $0.updateHasItems()
                    }
                    mediaItem.updateAvalability()
                }
            }

            if appendRelationships.isEmpty {
                self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
                return
            }
            
            let appendAssetsIds = appendRelationships.values.flatMap { $0 }
            self.mediaAlbumsService.getLocalAlbums(localIds: appendAssetsIds, context: context) { [weak self] mediaItemAlbums in
                guard let self = self else {
                    return
                }
                
                //add relationships
                appendRelationships.forEach { mediaItemLocalId, albumsIds in
                    if let mediaItem = mediaItems.first(where: { $0.localFileID == mediaItemLocalId }) {
                        mediaItemAlbums.forEach { album in
                            if let localId = album.localId, albumsIds.contains(localId) {
                                album.addToItems(mediaItem)
                                mediaItem.updateAvalability()
                                album.updateHasItems()
                            }
                        }
                    }
                }
                
                self.coreDataStack.saveDataForContext(context: context, savedCallBack: completion)
            }
        }
    }
    
    private let localsAppendingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    private func pushToLocalsAppendingQueue(assets: [PHAsset], needCreateRelationships: Bool = false, completion: @escaping VoidHandler) {
        let appendOperation = AppendLocalsOperation(assets: assets, needCreateRelationships: needCreateRelationships, completion: completion)
        localsAppendingQueue.addOperation(appendOperation)
    }
    
    
    private func processLocalGallery(completion: VoidHandler?) {
        debugLog("processLocalGallery")
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            completion?()
            return
        }
        
        guard !inProcessLocalFiles else {
            return
        }
        
        inProcessLocalFiles = true
        
        let localMediaStorage = LocalMediaStorage.default
        let assetsList = localMediaStorage.updateAllImagesAndVideoAssets()
        
        updateICloudStatus(for: assetsList)
        
        pushToLocalsAppendingQueue(assets: assetsList) { [weak self] in
            self?.removeMissingLocal(assets: assetsList) { [weak self] in
                self?.inProcessLocalFiles = false
                NotificationCenter.default.post(name: Notification.Name.allLocalMediaItemsHaveBeenLoaded, object: nil)
                completion?()
            }
        }
    }
    
    private func updateICloudStatus(for assets: [PHAsset]) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            return
        }
        coreDataStack.performBackgroundTask { [weak self] context in
            self?.privateQueue.async { [weak self] in
                
                guard let `self` = self else {
                    return
                }
                
                self.listAssetIdAlreadySaved(allList: assets, context: context) { alreadySavedAssets in
                    let start = Date()
                    LocalMediaStorage.default.getCompactInfo(from: alreadySavedAssets, completion: { [weak self] info in
                        guard let `self` = self else {
                            return
                        }
                        print("iCloud: updated iCloud in \(Date().timeIntervalSince(start)) secs")
                        context.perform {
                            let invalidItems = info.filter { !$0.isValid }.map { $0.asset.localIdentifier }
                            printLog("iCloud: removing \(invalidItems.count) items")
                            self.removeLocalMediaItems(with: invalidItems, completion: {})
                        }
                    })
                }
            }
        }
    }
    
    func listAssetIdAlreadySaved(allList: [PHAsset], context: NSManagedObjectContext, assetCallback: @escaping PhotoAssetsCallback) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            assetCallback([])
            return
        }
        
        let currentlyInLibriaryIDs = allList.map { $0.localIdentifier }
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.localFileID) IN %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", currentlyInLibriaryIDs)
        executeRequest(predicate: predicate, context: context) { alredySaved in
            let alredySavedIDs = alredySaved.compactMap { $0.localFileID }
            assetCallback(allList.filter { alredySavedIDs.contains( $0.localIdentifier ) })
        }
    }
    
    private func removeMissingLocal(assets: [PHAsset], completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            self.missingLocal(assets: assets, context: context) { [weak self] missingIDs in
                guard let `self` = self else {
                    return
                }

                self.removeLocalMediaItems(with: missingIDs, completion: completion)
            }
        }
    }
    
    private func missingLocal(assets: [PHAsset], context: NSManagedObjectContext, callback: @escaping ([String]) -> ()) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback([])
            return
        }
        
        let localIdentifiers = assets.map { $0.localIdentifier }
        let predicate = NSPredicate(format: "NOT(\(MediaItem.PropertyNameKey.localFileID) IN %@) AND \(MediaItem.PropertyNameKey.localFileID) != Nil AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", localIdentifiers)
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            let missingIDs = mediaItems.compactMap { $0.localFileID }
            callback(missingIDs)
        })
    }

    func notSaved(assets: [PHAsset], callback: @escaping PhotoAssetsCallback) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            callback([])
            return
        }
        
        let localIdentifiers = assets.map { $0.localIdentifier }
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.localFileID) IN %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", localIdentifiers)
        coreDataStack.performBackgroundTask { [weak self] context in
            self?.executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
                debugLog("db has \(mediaItems.count) saved local items")
                let alredySavedIDs = mediaItems.compactMap { $0.localFileID }
                let notSaved = assets.filter { !alredySavedIDs.contains($0.localIdentifier) }
                callback(notSaved)
            })
        }
    }
    
    
    func removeLocalMediaItems(with assetIdList: [String], completion: @escaping VoidHandler) {
        guard assetIdList.count > 0 else {
            completion()
            return
        }
        
        SharedGroupCoreDataStack.shared.delete(localIdentifiers: assetIdList)
        
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                completion()
                return
            }
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.localFileID) IN %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", assetIdList)
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
               
                let deletedItems = mediaItems.map { WrapData(mediaItem: $0) }
                let relatedRemotes = mediaItems.compactMap { Array($0.relatedRemotes) as? Array<MediaItem>}.joined()
                relatedRemotes.forEach {
                    $0.localFileID = nil
                    $0.moveToMissingDatesIfNeeded()
                }
                
                LocalMediaStorage.default.assetsCache.remove(identifiers: assetIdList)
                ItemOperationManager.default.deleteItems(items: deletedItems)
                mediaItems.forEach { mediaItem in
                    context.delete(mediaItem)
                    if let localAlbums = mediaItem.localAlbums?.array as? [MediaItemsLocalAlbum] {
                        localAlbums.forEach { $0.updateHasItems() }
                    }
                }
                
                self.coreDataStack.saveDataForContext(context: context, savedCallBack: { [weak self] in
                    ///Appearantly after recovery local ID may change, so temporary soloution is to check all files all over. and in the future chenge DataBase behavior heavily
                    let assetsList = LocalMediaStorage.default.updateAllImagesAndVideoAssets()
                    
                    self?.checkLocalFilesExistence(actualPhotoLibItemsIDs: assetsList.map{$0.localIdentifier}, complition: completion)
                })
                
            }
        }
    }
    
    func deleteItems(_ items: [WrapData], completion: @escaping VoidHandler) {
        guard !items.isEmpty else {
            completion()
            return
        }
        
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.uuid) in %@", items.map {$0.uuid} )
            self.executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { remoteItems in
                self.deleteItemsWithRelated(remoteItems, context: context, completion: completion)
            })
        }
        
        
        
        //        let predicate = NSPredicate(format: "uuid IN %@", items.compactMap { $0.uuid })
        //        delete(type: MediaItem.self, predicate: predicate, mergeChanges: true, { _ in
        //            completion()
        //        })
        
    }
    
    func deleteItems(context: NSManagedObjectContext, _ items: [WrapData], completion: @escaping VoidHandler) {
        guard !items.isEmpty else {
            completion()
            return
        }
        
        let predicate = NSPredicate(format: "uuid in %@", items.map {$0.uuid} )
        
        #if DEBUG
        let contextQueue = DispatchQueue.currentQueueLabelAsserted
        #endif
        
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { remoteItems in
            #if DEBUG
            let contextQueue2 = DispatchQueue.currentQueueLabelAsserted
            assert(contextQueue == contextQueue2, "\(contextQueue) != \(contextQueue2)")
            #endif
            
            self.deleteItemsWithRelated(remoteItems, context: context) {
                #if DEBUG
                let contextQueue3 = DispatchQueue.currentQueueLabelAsserted
                assert(contextQueue == contextQueue3, "\(contextQueue) != \(contextQueue3)")
                #endif
            }
        })
        
    }
    
    func deleteTrashedItems(completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { context in
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.status) = %d", ItemStatus.trashed.valueForCoreDataMapping())
            self.executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { trashedItems in
                self.deleteItemsWithRelated(trashedItems, context: context, completion: completion)
            })
        }
    }
    
    private func deleteItemsWithRelated(_ items: [MediaItem], context: NSManagedObjectContext, completion: @escaping VoidHandler) {
        let itemsSet = NSSet(array: items)
        
        mediaItemByLocalID(trimmedLocalIDS: items.compactMap { $0.trimmedLocalFileID }, context: context, mediaItemsCallBack: { mediaItems in
            mediaItems.forEach {
                $0.removeFromRelatedRemotes(itemsSet)
                $0.updateMissingDateRelations()
                
                if $0.relatedRemotes.count == 0 {
                    $0.regenerateTrimmedLocalFileID()
                }
            }
            
            items.forEach { context.delete($0) }
            
            self.coreDataStack.saveDataForContext(context: context, saveAndWait: false, savedCallBack: completion)
        })
    }
    
    private func batchDeleteRequest(for entityDescription: NSEntityDescription, predicate: NSPredicate?) -> NSBatchDeleteRequest {
        let deleteFetchRequest = NSFetchRequest<NSFetchRequestResult>()
        deleteFetchRequest.entity = entityDescription
        deleteFetchRequest.predicate = predicate
        deleteFetchRequest.includesPropertyValues = false
        deleteFetchRequest.returnsObjectsAsFaults = false
        deleteFetchRequest.resultType = .managedObjectIDResultType
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        return batchDeleteRequest
    }
    
    func allLocalItems(localItems: @escaping WrapObjectsCallBack) {
        let context = coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.localFileID) != nil")
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            localItems(mediaItems.map { $0.wrapedObject })
        })
    }
    
    func localItemsBy(assets: [PHAsset], localItemsCallback: @escaping WrapObjectsCallBack) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            localItemsCallback([])
            return
        }
        let sortDescriptor = NSSortDescriptor(key: MediaItem.PropertyNameKey.creationDateValue, ascending: false)
        let context = coreDataStack.newChildBackgroundContext
       
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.localFileID) != nil AND \(MediaItem.PropertyNameKey.localFileID) IN %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", assets.map { $0.localIdentifier })
        
        let request = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        context.perform {
            guard let result = try? context.fetch(request) else {
                localItemsCallback([])
                return
            }
            var localItems = [WrapData]()
            for (item, asset) in zip(result, assets) {
                localItems.append(item.wrapedObject(with: asset))
            }
            localItemsCallback(localItems)
        }
    }
    
    func allLocalItems(with assets: [PHAsset], localItemsCallback: @escaping WrapObjectsCallBack) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            localItemsCallback([])
            return
        }
        let context = coreDataStack.newChildBackgroundContext
        
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.localFileID) != nil AND \(MediaItem.PropertyNameKey.localFileID) IN %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", assets.map { $0.localIdentifier })
        executeRequest(predicate: predicate, context: context, mediaItemsCallBack: { mediaItems in
            /// sort items in the assets order
            var items = mediaItems
            let ordering = Dictionary(uniqueKeysWithValues: assets.enumerated().map { ($1.localIdentifier, $0) })
            items = items.sorted(by: { (firstItem, secondItem) -> Bool in
                if let firstLocalId = firstItem.localFileID, let firstIndex = ordering[firstLocalId] {
                    if let secondLocalId = secondItem.localFileID, let secondIndex = ordering[secondLocalId] {
                        return firstIndex < secondIndex
                    } else {
                        return false
                    }
                }
                return false
            })
            
            var localItems = [WrapData]()
            for (item, asset) in zip(items, assets) {
                localItems.append(item.wrapedObject(with: asset))
            }
            
            localItemsCallback(localItems)
        })

    }
    
    func allLocalItems(trimmedLocalIds: [String], localItemsCallBack: @escaping WrapObjectsCallBack) {
        let context = coreDataStack.newChildBackgroundContext
        let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.trimmedLocalFileID) != nil AND \(MediaItem.PropertyNameKey.trimmedLocalFileID) IN %@ AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", trimmedLocalIds)
        executeRequest(predicate: predicate, context: context) { mediaItems in
             localItemsCallBack(mediaItems.map{ $0.wrapedObject })
        }
    }
    
    func hasLocalItemsForSync(video: Bool, image: Bool, completion: @escaping  (_ has: Bool) -> Void) {
        debugLog("hasLocalItemsForSync")
        getUnsyncedMediaItems(video: video, image: image, completion: { items in
            let wrappedItems = items.map { $0.wrapedObject }
            completion(!AppMigrator.migrateSyncStatus(for: wrappedItems).isEmpty)
        })
        
    }
    
    func allLocalItemsForSync(video: Bool, image: Bool, completion: @escaping WrapObjectsCallBack) {
        debugLog("allLocalItemsForSync")
        getUnsyncedMediaItems(video: video, image: image, completion: { items in
            let wrappedItems = items
                .filter { $0.fileSizeValue < NumericConstants.fourGigabytes }
                .sorted { $0.fileSizeValue < $1.fileSizeValue }
                .compactMap { $0.wrapedObject }
            
            completion(AppMigrator.migrateSyncStatus(for: wrappedItems))
        })
    }
    
    private func getUnsyncedMediaItems(video: Bool, image: Bool, completion: @escaping MediaItemsCallBack) {
        debugLog("getUnsyncedMediaItems")
        let assetList = LocalMediaStorage.default.getAllImagesAndVideoAssets()
        let currentlyInLibriaryLocalIDs = assetList.map { $0.localIdentifier }
        
        var filesTypesArray = [Int16]()
        if (video) {
            filesTypesArray.append(FileType.video.valueForCoreDataMapping())
        }
        if (image) {
            filesTypesArray.append(FileType.image.valueForCoreDataMapping())
        }
        
        
        coreDataStack.performBackgroundTask { [weak self] context in
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isAvailable) = true AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.fileTypeValue) IN %@ AND \(MediaItem.PropertyNameKey.localFileID) IN %@ AND (SUBQUERY(\(MediaItem.PropertyNameKey.objectSyncStatus), $x, $x.userID = %@).@count = 0 AND \(MediaItem.PropertyNameKey.relatedRemotes).@count = 0)", filesTypesArray, currentlyInLibriaryLocalIDs, SingletonStorage.shared.uniqueUserID)
            self?.executeRequest(predicate: predicate, context: context) { mediaItems in
                completion(mediaItems)
            }
        }
    }
    
    private func checkLocalFilesExistence(actualPhotoLibItemsIDs: [String], complition: VoidHandler? = nil) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.localFileID) != Nil AND NOT (\(MediaItem.PropertyNameKey.localFileID) IN %@) AND \(MediaItem.PropertyNameKey.isLocalItemValue) = true", actualPhotoLibItemsIDs)
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
                mediaItems.forEach {
                    context.delete($0)
                }
                self.coreDataStack.saveDataForContext(context: context, savedCallBack: {
                    /// put notification here that item deleted
                    let items = mediaItems.map { $0.wrapedObject }
                    ItemOperationManager.default.deleteItems(items: items)
                    complition?()
                })
            }
        }
    }
    
    private func checkRemoteItemsExistence(wrapData: [WrapData], completion: @escaping WrapObjectsCallBack) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let `self` = self else {
                return
            }
            
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.uuid) IN %@", wrapData.compactMap { $0.uuid })
            
            self.executeRequest(predicate: predicate, context: context) { mediaItems in
                let existedUUIDS = mediaItems.compactMap { $0.uuid }
                let filteredItems = wrapData.filter { !existedUUIDS.contains($0.uuid) }
                print("--- filtered \(wrapData.count - filteredItems.count) existed uuids")
                completion(filteredItems)
            }
        }
    }
    
    
    //MARK: - Hide
    func hide(_ items: [WrapData], completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.uuid) IN %@", items.compactMap { $0.uuid })
            
            self.executeRequest(predicate: predicate, context: context) { [weak self] mediaItems in
                guard let self = self else {
                    assertionFailure("Unexpected MediaItemOperationsService == nil")
                    return
                }
                mediaItems.forEach { $0.status = ItemStatus.hidden.valueForCoreDataMapping() }
                self.coreDataStack.saveDataForContext(context: context) {
                    completion()
                }
            }
        }
    }
    
    func hide(_ albums: [AlbumItem], completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            let predicate = NSPredicate(format: "\(MediaItemsAlbum.PropertyNameKey.uuid) IN %@", albums.compactMap { $0.uuid })
            let request = NSFetchRequest<MediaItemsAlbum>(entityName: MediaItemsAlbum.Identifier)
            request.predicate = predicate
            
            do {
                let savedHiddenAlbums: [MediaItemsAlbum] = try context.fetch(request)
                savedHiddenAlbums.forEach {
                    guard let items = $0.items as? Set<MediaItem> else {
                        return
                    }
                    items.forEach { $0.status = ItemStatus.hidden.valueForCoreDataMapping() }
                }
                self.coreDataStack.saveDataForContext(context: context) {
                    completion()
                }
            } catch {
                let errorMessage = "context.fetch failed with: \(error.localizedDescription)"
                assertionFailure(errorMessage)
            }
        }
    }
    
    //MARK: - Unhide
    func recover(_ items: [WrapData], completion: @escaping VoidHandler) {
        coreDataStack.performBackgroundTask { [weak self] context in
            guard let self = self else {
                return
            }
            
            let predicate = NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.uuid) IN %@", items.compactMap { $0.uuid })
            
            self.executeRequest(predicate: predicate, context: context) { [weak self] mediaItems in
                guard let self = self else {
                    assertionFailure("Unexpected MediaItemOperationsService == nil")
                    return
                }
                
                /// TODO: maybe we need to change status value to the related status value from recover response??
                mediaItems.forEach { $0.status = ItemStatus.active.valueForCoreDataMapping() }
                self.coreDataStack.saveDataForContext(context: context) {
                    completion()
                }
            }
        }
    }
}
