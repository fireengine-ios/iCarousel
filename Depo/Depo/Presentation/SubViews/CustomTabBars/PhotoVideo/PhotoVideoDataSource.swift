//
//  PhotoVideoDataSource.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoDataSourceDelegate: class {
    func selectedModeDidChange(_ selectingMode: Bool)
    func fetchPredicateCreated()
    func contentDidChange(_ fetchedObjects: [MediaItem])
    func convertFetchedObjectsInProgress()
}

final class PhotoVideoDataSource: NSObject {
    
    private var thresholdService = ThresholdBlockService(threshold: 0.1)
    
    private let mergeQueue = DispatchQueue(label: DispatchQueueLabels.photoVideoMergeQueue)
    
    var isSelectingMode = false {
        didSet {
            delegate?.selectedModeDidChange(isSelectingMode)
        }
    }
    
    private var lastWrapedObjects = SynchronizedArray<WrapData>()
    
    private var lastUpdateFetchedObjects: [MediaItem]?
    private var firstOffsetSavedVisibleItem: MediaItem?
    
    private var cellTopOffset: CGFloat = 0
    private(set) var focusedIndexPath: IndexPath?
    
    private weak var delegate: PhotoVideoDataSourceDelegate?
    private weak var collectionView: UICollectionView?
    
    private let predicateManager = PhotoVideoPredicateManager()
    
    private lazy var sectionChanges = [() -> Void]()
    private lazy var objectChanges = [() -> Void]()
    private lazy var objectUpdates = [IndexPath]()
    
    private lazy var insertedItemsIds = [NSManagedObjectID]()
    private lazy var deletedItemsIds = [NSManagedObjectID]()
    private lazy var updatedItemsIds = [NSManagedObjectID]()
    private var lastFetchObjectCompetion: WrapObjectsCallBack?
    private var isConverting = false
    private var isMerging = false
    
    private var tbMatikItem: Item?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<MediaItem> = {
        let fetchRequest: NSFetchRequest = MediaItem.fetchRequest()
        
        let sortDescriptor1 = NSSortDescriptor(key: #keyPath(MediaItem.monthValue), ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: #keyPath(MediaItem.sortingDate), ascending: false)
        let sortDescriptor3 = NSSortDescriptor(key: #keyPath(MediaItem.idValue), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2, sortDescriptor3]
        
//        if Device.isIpad {
//            fetchRequest.fetchBatchSize = 64
//        } else {
//            fetchRequest.fetchBatchSize = 32
//        }
        
        //fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(PostDB.id)]
        let context = CoreDataStack.shared.mainContext
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: context,
                                                      sectionNameKeyPath: #keyPath(MediaItem.monthValue),
                                                      cacheName: nil)
        frController.delegate = self
        return frController
    }()
    
    /// collectionView needs only for NSFetchedResultsControllerDelegate
    init(collectionView: UICollectionView?, delegate: PhotoVideoDataSourceDelegate?) {
        self.collectionView = collectionView
        self.delegate = delegate
    }
    
    func scrollToItem(_ item: Item) {
        if lastUpdateFetchedObjects == nil {
            tbMatikItem = item
        } else {
            scroll(to: item)
        }
    }
    
    private func scroll(to item: Item) {
        getIndexPathForObject(uuid: item.uuid) { [weak self] indexPath in
            guard let self = self, let indexPath = indexPath else {
                return
            }
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func getFetchedOriginalObjects(mediaItemsCallback: @escaping MediaItemsCallBack) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            mediaItemsCallback(self?.fetchedResultsController.fetchedObjects ?? [])
        }
    }
    
    func getFetchedObjects(wrapDataCallBack: @escaping WrapObjectsCallBack) {
        //FIXME: this implementation would cause significant freeze on large accounts
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            wrapDataCallBack(self?.fetchedResultsController.fetchedObjects?.map { object in
                WrapData(mediaItem: object)
            } ?? [])
        }
    }
    
    func getSelectedObjects(at indexPaths: [IndexPath], wrapDataCallBack: @escaping WrapObjectsCallBack) {
        getConvertedObjects(at: Array(indexPaths), wrapItemsCallback: wrapDataCallBack)
    }
    
    private func getObject(at indexPath: IndexPath) -> MediaItem? {
        guard let section = fetchedResultsController.sections?[safe: indexPath.section],
            section.numberOfObjects > indexPath.row else {
                return nil
        }
        return fetchedResultsController.object(at: indexPath)
    }
    
    func getObject(at indexPath: IndexPath, mediaItemCallback: @escaping MediaItemCallback) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            mediaItemCallback(self?.getObject(at: indexPath))
        }
    }
    
    func getObjects(at indexPaths: [IndexPath], mediaItemsCallback: @escaping MediaItemsCallBack) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            mediaItemsCallback(indexPaths.compactMap { indexPath in
                self?.getObject(at: indexPath)
            })
        }
    }
    
    func getConvertedObjects(at indexPaths: [IndexPath], wrapItemsCallback: @escaping WrapObjectsCallBack) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            wrapItemsCallback(indexPaths.compactMap { indexPath in
                guard let mediaItem = self?.getObject(at: indexPath) else {
                    return nil
                }
                return WrapData(mediaItem: mediaItem)
            })
        }
    }
    
    ///this one is fine without a callback, beacause this method already SHOULD be called from the right context
    func indexPath(forObject object: MediaItem) -> IndexPath? {
        #if DEBUG
        ///Also this check is not totally 100% correct, because context of fetch controller can be different from main thred.
        if !DispatchQueue.isMainQueue || !Thread.isMainThread {
            assertionFailure("👉 CALL THIS FROM MAIN THREAD (if fetch controller uses not main context then delete this code)")
        }
        #endif
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    func getIndexPathForRemoteObject(itemUUID: String, indexCallBack: @escaping IndexPathCallback) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            guard let findedObject = self?.lastUpdateFetchedObjects?.first(where: { $0.trimmedLocalFileID == itemUUID }) else {
                indexCallBack(nil)
                return
            }
            indexCallBack(self?.indexPath(forObject: findedObject))
        }
    }
    
    func getIndexPathForLocalObject(itemTrimmedLocalID: String, indexCallBack: @escaping IndexPathCallback) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            guard let findedObject = self?.lastUpdateFetchedObjects?.first(where: { $0.trimmedLocalFileID == itemTrimmedLocalID && $0.isLocalItemValue }) else {
                indexCallBack(nil)
                return
            }
            
            indexCallBack(self?.indexPath(forObject: findedObject))
        }
    }
    
    func getIndexPathForObject(uuid: String, indexCallBack: @escaping IndexPathCallback) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            guard let findedObject = self?.lastUpdateFetchedObjects?.first(where: { $0.uuid == uuid }) else {
                indexCallBack(nil)
                return
            }
            indexCallBack(self?.indexPath(forObject: findedObject))
        }
    }
    
    func performFetch() {
        try? fetchedResultsController.performFetch()
        //need for update year view on scrollBar
        updateLastFetchedObjects(deletedIds: [], updatedIds: [], insertedIds: [])
    }
    
    func setupOriginalPredicates(isPhotos: Bool, predicateSetupedCallback: @escaping VoidHandler) {
        predicateManager.getMainCompoundedPredicate(isPhotos: isPhotos) { [weak self] compoundedPredicate in
            self?.fetchedResultsController.fetchRequest.predicate = compoundedPredicate
            predicateSetupedCallback()
        }
    }
    
    func changeSourceFilter(syncOnly: Bool, isPhotos: Bool, newPredicateSetupedCallback: @escaping VoidHandler) {
        lastWrapedObjects.removeAll()
        if syncOnly {
            fetchedResultsController.fetchRequest.predicate = predicateManager.getSyncPredicate(isPhotos: isPhotos)
            newPredicateSetupedCallback()
        } else {
            predicateManager.getMainCompoundedPredicate(isPhotos: isPhotos) { [weak self] compundedPredicate in
                self?.fetchedResultsController.fetchRequest.predicate = compundedPredicate
                newPredicateSetupedCallback()
            }
        }
    }
    
    func getWrapedFetchedObjects(completion: @escaping WrapObjectsCallBack) {
        if isConverting || isMerging {
            delegate?.convertFetchedObjectsInProgress()
            lastFetchObjectCompetion = completion
        } else {
            completion(lastWrapedObjects.getArray())
        }
    }
    
    private func convertFetchedObjects() {
        isConverting = true
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            
            let ids = self.lastUpdateFetchedObjects?.map { $0.objectID } ?? []
            self.mergeQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                guard !ids.isEmpty else {
                    self.finishConverting(needSorting: false)
                    return
                }
                
                MediaItemOperationsService.shared.mediaItemsByIDs(ids: ids) { [weak self] items in
                    guard let self = self else {
                        return
                    }
                    
                    assert(self.lastWrapedObjects.isEmpty, "lastWrapedObjects must be empty")
                    self.lastWrapedObjects.removeAll()
                    self.lastWrapedObjects.append(items.map {
                        WrapData(mediaItem: $0)
                    })
                    
                    self.isConverting = false
                    if !self.isMerging {
                        self.finishConverting(needSorting: true)
                    }
                }
            }
        }
    }
    
    private func mergeFetchedObjects(deletedIds: [NSManagedObjectID], updatedIds: [NSManagedObjectID], insertedIds: [NSManagedObjectID]) {
        isMerging = true
        mergeQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            guard !updatedIds.isEmpty || !insertedIds.isEmpty || !deletedIds.isEmpty else {
                self.finishConverting(needSorting: false)
                return
            }
            
            let idsToLoad = updatedIds + insertedIds
            MediaItemOperationsService.shared.mediaItemsByIDs(ids: idsToLoad) { [weak self] items in
                guard let self = self else {
                    return
                }
                
                let idsToRemove = deletedIds + updatedIds
            
                self.lastWrapedObjects.modify { array in
                    var array = array
                    idsToRemove.forEach { id in
                        array.removeAll(where: { $0.coreDataObjectId == id })
                    }
                    // seems like self.convertFetchedObjects() maybe performing simultaniously with this code
                    // and exactly between removing and appending items, it may append its own elements
                    // that is why we need to perform removeAll and append as an atomic operation
                    array += items.map { WrapData(mediaItem: $0) }
                    
                    return array
                }
                
                self.isMerging = false
                if !self.isConverting {
                    self.finishConverting(needSorting: true)
                }
            }
        }
    }
    
    private func finishConverting(needSorting: Bool) {
        let finish = { [weak self] in
            guard let self = self else {
                return
            }
            
            let objects = self.lastWrapedObjects.getArray()
            DispatchQueue.main.async {
                self.lastFetchObjectCompetion?(objects)
                self.lastFetchObjectCompetion = nil
                self.isConverting = false
                self.isMerging = false
            }
        }
        
        if needSorting {
            lastWrapedObjects.sortItself(by: { item1, item2 -> Bool in
                if let date1 = item1.isLocalItem ? item1.creationDate : item1.metaData?.takenDate {
                    if let date2 = item2.isLocalItem ? item2.creationDate : item2.metaData?.takenDate {
                        /// both dates are non-nil
                        if date1 == date2 {
                            if let itemId1 = item1.id, let itemId2 = item2.id {
                                return itemId1 > itemId2
                            }
                            /// shouldn't be there ever
                            return false
                        }
                        return date1 > date2
                    }
                    /// date2 is nil
                    return true
                } else if let _ = item2.isLocalItem ? item2.creationDate : item2.metaData?.takenDate {
                    /// date1 is nil
                    return false
                } else {
                    /// both dates are nil
                    if let itemId1 = item1.id, let itemId2 = item2.id {
                        return itemId1 > itemId2
                    }
                    /// shouldn't be there ever
                    return false
                }
            }, completion: {
                finish()
            })
        } else {
            finish()
        }
        
//            var mutableArray = lastWrapedObjects.getArray()
//
//            ///separate missing dates
//            let partitionIndex = mutableArray.partition { item -> Bool in
//                (item.isLocalItem && item.creationDate == nil) ||
//                    (!item.isLocalItem && item.metaData?.takenDate == nil)
//            }
//            var missingDates = Array(mutableArray.suffix(from: partitionIndex))
//            var ordinaryItems = Array(mutableArray.prefix(upTo: partitionIndex))
//
//            /// sort differentely
//            ordinaryItems.sort(by: { obj1, obj2 -> Bool in
//                if let date1 = obj1.metaData?.takenDate ?? obj1.creationDate,
//                    let date2 = obj2.metaData?.takenDate ?? obj2.creationDate {
//                    return date1 > date2
//                }
//                return false
//            })
//            missingDates.sort(by: { obj1, obj2 -> Bool in
//                if let id1 = obj1.id, let id2 = obj2.id {
//                    return id1 > id2
//                }
//                return false
//            })
//
//            /// update lastWrapedObjects
//            lastWrapedObjects.removeAll()
//            lastWrapedObjects.append(ordinaryItems + missingDates)
    }
    
    private func cleanChanges() {
        sectionChanges.removeAll()
        objectChanges.removeAll()
        insertedItemsIds.removeAll()
        deletedItemsIds.removeAll()
        updatedItemsIds.removeAll()
        objectUpdates.removeAll()
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoVideoDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[safe: section]?.numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: PhotoVideoCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
/// https://github.com/jessesquires/JSQDataSourcesKit/blob/develop/Source/FetchedResultsDelegate.swift
/// https://gist.github.com/nor0x/c48463e429ba7b053fff6e277c72f8ec
extension PhotoVideoDataSource: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        cleanChanges()
        saveOffset()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let section = IndexSet(integer: sectionIndex)
        
        sectionChanges.append { [unowned self] in
            switch type {
            case .insert:
                self.collectionView?.insertSections(section)
            case .delete:
                self.collectionView?.deleteSections(section)
            default:
                break
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let objectId = (anObject as? MediaItem)?.objectID
        
        switch type {
        case .insert:
            if let collectionView = collectionView, let indexPath = newIndexPath {
                self.objectChanges.append {
                    collectionView.insertItems(at: [indexPath])
                }
            }
            insertedItemsIds.append(objectId)
        case .delete:
            if let collectionView = collectionView, let indexPath = indexPath {
                self.objectChanges.append {
                    collectionView.deleteItems(at: [indexPath])
                }
            }
            deletedItemsIds.append(objectId)
        case .update:
            if let indexPath = indexPath {
                self.objectUpdates.append(indexPath)
            }
            updatedItemsIds.append(objectId)
        case .move:
            if let collectionView = collectionView, let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.objectChanges.append {
                    collectionView.deleteItems(at: [indexPath])
                    collectionView.insertItems(at: [newIndexPath])
                }
            }
            updatedItemsIds.append(objectId)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let sectionChangesStatic = sectionChanges
        let objectChangesStatic = objectChanges
        let deletedIdsStatic = deletedItemsIds
        let updatedIdsStatic = updatedItemsIds
        let insertedIdsStatic = insertedItemsIds
        let objectUpdatesStatic = objectUpdates
        
        cleanChanges()
        
        if let collectionView = collectionView, !collectionView.isDragging, let firstVisibleItem = firstOffsetSavedVisibleItem {
            focusedIndexPath = indexPath(forObject: firstVisibleItem)
            UIView.setAnimationsEnabled(false)
        }

        collectionView?.performBatchUpdates({
            sectionChangesStatic.forEach { $0() }
            objectChangesStatic.forEach { $0() }
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            // reload cells manually
            objectUpdatesStatic.forEach { indexPath in
                if let collectionView = self.collectionView, let cell = collectionView.cellForItem(at: indexPath) {
                    collectionView.delegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
                }
            }
            self.reloadSupplementaryViewsIfNeeded()
            self.updateLastFetchedObjects(deletedIds: deletedIdsStatic, updatedIds: updatedIdsStatic, insertedIds: insertedIdsStatic)
            
            UIView.setAnimationsEnabled(true)
        })
    }
    
    func focusedOffset() -> CGPoint? {
        if let collectionView = collectionView, !collectionView.isDragging,
            let indexPath = focusedIndexPath,
            let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
        
            return CGPoint(x: 0, y: attributes.frame.origin.y - cellTopOffset)
        }
        return nil
    }
    
    private func saveOffset() {
        firstOffsetSavedVisibleItem = nil
        cellTopOffset = 0
        focusedIndexPath = nil
        
        if let indexPath = collectionView?.indexPathsForVisibleItems.sorted().first, indexPath != IndexPath(item: 0, section: 0) {
            #if DEBUG
            if !DispatchQueue.isMainQueue || !Thread.isMainThread {
                assertionFailure("👉 CALL THIS FROM MAIN THREAD")
            }
            #endif
            firstOffsetSavedVisibleItem = getObject(at: indexPath)
            if let collectionView = collectionView, let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
                cellTopOffset = attributes.frame.origin.y - collectionView.contentOffset.y
            }
        }
    }
    
    private func updateLastFetchedObjects(deletedIds: [NSManagedObjectID], updatedIds: [NSManagedObjectID], insertedIds: [NSManagedObjectID]) {
        self.getFetchedOriginalObjects { [weak self] fetchedObjects in
            guard let self = self else {
                return
            }
            self.lastUpdateFetchedObjects = fetchedObjects
            self.delegate?.contentDidChange(fetchedObjects)
            if self.lastWrapedObjects.isEmpty, !self.isConverting {
                self.convertFetchedObjects()
            } else {
                self.mergeFetchedObjects(deletedIds: deletedIds, updatedIds: updatedIds, insertedIds: insertedIds)
            }
            
            if let item = self.tbMatikItem {
                self.scroll(to: item)
                self.tbMatikItem = nil
            }
        }
    }
    
    private func reloadSupplementaryViewsIfNeeded() {
        if !sectionChanges.isEmpty || !objectChanges.isEmpty {
            CellImageManager.clear()
            collectionView?.reloadData()
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
}

extension PhotoVideoDataSource: PhotoVideoCollectionViewLayoutDelegate {
    func targetContentOffset() -> CGPoint? {
        return focusedOffset()
    }
}
