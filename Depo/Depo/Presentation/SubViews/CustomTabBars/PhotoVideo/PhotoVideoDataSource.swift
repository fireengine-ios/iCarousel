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

// TODO: selectedIndexPaths NSFetchedResultsController changes
final class PhotoVideoDataSource: NSObject {
    
    private var thresholdService = ThresholdBlockService(threshold: 0.1)
    
    private let mergeQueue = DispatchQueue(label: DispatchQueueLabels.photoVideoMergeQueue)
    
    var isSelectingMode = false {
        didSet {
            delegate?.selectedModeDidChange(isSelectingMode)
        }
    }
    
    var selectedIndexPaths = Set<IndexPath>()
    
    private var lastWrapedObjects = SynchronizedArray<WrapData>()
    
    private var lastUpdateFetchedObjects: [MediaItem]?
    private var firstOffsetSavedVisibleItem: MediaItem?
    
    private var cellTopOffset: CGFloat = 0
    private(set) var focusedIndexPath: IndexPath?
    
    private weak var delegate: PhotoVideoDataSourceDelegate?
    private weak var collectionView: UICollectionView!
    
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
        let context = CoreDataStack.default.mainContext
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
    
    func getSelectedObjects(wrapDataCallBack: @escaping WrapObjectsCallBack) {
        getConvertedObjects(at: Array(selectedIndexPaths), wrapItemsCallback: wrapDataCallBack)
    }
    
    func getObject(at indexPath: IndexPath, mediaItemCallback: @escaping MediaItemCallback) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            guard let self = self, let section = self.fetchedResultsController.sections?[safe: indexPath.section],
                section.numberOfObjects > indexPath.row else {
                mediaItemCallback(nil)
                    return
            }
            mediaItemCallback(self.fetchedResultsController.object(at: indexPath))
        }
    }
    
    func getObjects(at indexPaths: [IndexPath], mediaItemsCallback: @escaping MediaItemsCallBack) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            mediaItemsCallback(indexPaths.compactMap { indexPath in
                guard let self = self, let section = self.fetchedResultsController.sections?[safe: indexPath.section],
                    section.numberOfObjects > indexPath.row else {
                        return nil
                }
                return self.fetchedResultsController.object(at: indexPath)
            })
        }
    }
    
    func getConvertedObjects(at indexPaths: [IndexPath], wrapItemsCallback: @escaping WrapObjectsCallBack) {
        fetchedResultsController.managedObjectContext.perform { [weak self] in
            wrapItemsCallback(indexPaths.compactMap { indexPath in
                guard let self = self, let section = self.fetchedResultsController.sections?[safe: indexPath.section],
                    section.numberOfObjects > indexPath.row else {
                        return nil
                }
                return WrapData(mediaItem:self.fetchedResultsController.object(at: indexPath))
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
                    
                    items.forEach({ mediaItem in
                        autoreleasepool {
                            self.lastWrapedObjects.append(WrapData(mediaItem: mediaItem))
                        }
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
            
            let ids = deletedIds + updatedIds + insertedIds
            guard !ids.isEmpty else {
                self.finishConverting(needSorting: false)
                return
            }
            
            MediaItemOperationsService.shared.mediaItemsByIDs(ids: ids) { [weak self] items in
                guard let self = self else {
                    return
                }
                
                for mediaItem in items {
                    let itemUuid = mediaItem.isLocalItemValue ? mediaItem.trimmedLocalFileID : mediaItem.uuid
                    guard let uuid = itemUuid else {
                        continue
                    }
                    
                    let deleteItem = {
                        if mediaItem.isLocalItemValue {
                            self.lastWrapedObjects.remove(where: {$0.isLocalItem && $0.getTrimmedLocalID() == uuid})
                        } else {
                            self.lastWrapedObjects.remove(where: {$0.uuid == uuid})
                        }
                    }
                    
                    if deletedIds.contains(mediaItem.objectID) {
                        deleteItem()
                    } else {
                        if updatedIds.contains(mediaItem.objectID) {
                            deleteItem()
                        }
                        
                        let wrappedObject = WrapData(mediaItem: mediaItem)
                        self.lastWrapedObjects.append(wrappedObject)
                    }
                }

                self.isMerging = false
                if !self.isConverting {
                    self.finishConverting(needSorting: true)
                }
            }
        }
    }
    
    private func finishConverting(needSorting: Bool) {
        if needSorting {
            lastWrapedObjects.sortItself(by: { obj1, obj2 -> Bool in
                if let date1 = obj1.metaData?.takenDate ?? obj1.creationDate,
                    let date2 = obj2.metaData?.takenDate ?? obj2.creationDate,
                    date1 > date2
                {
                    return true
                }
                return false
            })
        }
        
        DispatchQueue.main.async {
            self.lastFetchObjectCompetion?(self.lastWrapedObjects.getArray())
            self.lastFetchObjectCompetion = nil
            self.isConverting = false
            self.isMerging = false
        }
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
        debugLog("PhotoVideoDataSource numberOfSections")
        return fetchedResultsController.sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        debugLog("PhotoVideoDataSource numberOfItemsInSection")
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
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
        debugLog("PhotoVideoDataSource controllerWillChangeContent")
        cleanChanges()
        saveOffset()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let section = IndexSet(integer: sectionIndex)
        
        sectionChanges.append { [unowned self] in
            switch type {
            case .insert:
                self.collectionView.insertSections(section)
            case .delete:
                self.collectionView.deleteSections(section)
            default:
                break
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let objectId = (anObject as? MediaItem)?.objectID
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.insertItems(at: [indexPath])
                }
            }
            insertedItemsIds.append(objectId)
        case .delete:
            if let indexPath = indexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
            deletedItemsIds.append(objectId)
        case .update:
            if let indexPath = indexPath {
                self.objectUpdates.append(indexPath)
            }
            updatedItemsIds.append(objectId)
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.deleteItems(at: [indexPath])
                    self.collectionView.insertItems(at: [newIndexPath])
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
        
        if !collectionView.isDragging, let firstVisibleItem = firstOffsetSavedVisibleItem {
            focusedIndexPath = fetchedResultsController.indexPath(forObject: firstVisibleItem)
            UIView.setAnimationsEnabled(false)
        }
        
        /// reload cells manually
        objectUpdatesStatic.forEach { indexPath in
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                self.collectionView.delegate?.collectionView?(self.collectionView, willDisplay: cell, forItemAt: indexPath)
            }
        }
        
        debugLog("PhotoVideoDataSource collectionView batchUpdates start")
        collectionView.performBatchUpdates({
            debugLog("PhotoVideoDataSource collectionView batchUpdates in process")
            sectionChangesStatic.forEach { $0() }
            objectChangesStatic.forEach { $0() }
        }, completion: { [weak self] _ in
            debugLog("PhotoVideoDataSource collectionView batchUpdates completion")
            guard let self = self else {
                return
            }
            
            self.reloadSupplementaryViewsIfNeeded()
            self.updateLastFetchedObjects(deletedIds: deletedIdsStatic, updatedIds: updatedIdsStatic, insertedIds: insertedIdsStatic)
            
            UIView.setAnimationsEnabled(true)
        })
    }
    
    func focusedOffset() -> CGPoint? {
        if !collectionView.isDragging,
            let indexPath = focusedIndexPath,
            let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) {
        
            return CGPoint(x: 0, y: attributes.frame.origin.y - cellTopOffset)
        }
        return nil
    }
    
    private func saveOffset() {
        firstOffsetSavedVisibleItem = nil
        cellTopOffset = 0
        focusedIndexPath = nil
        
        if let indexPath = collectionView.indexPathsForVisibleItems.sorted().first, indexPath != IndexPath(item: 0, section: 0) {
            #if DEBUG
            if !DispatchQueue.isMainQueue || !Thread.isMainThread {
                assertionFailure("👉 CALL THIS FROM MAIN THREAD")
            }
            #endif
            firstOffsetSavedVisibleItem = fetchedResultsController.object(at: indexPath)
            if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
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
        }
    }
    
    private func reloadSupplementaryViewsIfNeeded() {
        if !sectionChanges.isEmpty || !objectChanges.isEmpty {
            CellImageManager.clear()
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
}

extension PhotoVideoDataSource: PhotoVideoCollectionViewLayoutDelegate {
    func targetContentOffset() -> CGPoint? {
        return focusedOffset()
    }
}
