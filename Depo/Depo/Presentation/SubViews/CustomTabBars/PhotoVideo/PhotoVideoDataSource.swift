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
    func convertFetchedObjectsDidStart()
}

// TODO: selectedIndexPaths NSFetchedResultsController changes
final class PhotoVideoDataSource: NSObject {
    
    private var thresholdService = ThresholdBlockService(threshold: 0.1)
    
    var isSelectingMode = false {
        didSet {
            delegate?.selectedModeDidChange(isSelectingMode)
        }
    }
    
    var selectedIndexPaths = Set<IndexPath>()
    
    var selectedObjects: [WrapData] {
        return selectedIndexPaths.compactMap { indexPath in
            if let object = self.object(at: indexPath) {
                return WrapData(mediaItem: object)
            }
            return nil
        }
    }
    
    var fetchedOriginalObjects: [MediaItem] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    var fetchedObjects: [WrapData] {
        return fetchedResultsController.fetchedObjects?.map { object in
            return WrapData(mediaItem: object)
        } ?? []
    }
    
    private var lastWrapedObjects = SynchronizedArray<WrapData>()
    var lastFetchedObjects: [MediaItem]?
    
    private var firstVisibleItem: MediaItem?
    private var cellTopOffset: CGFloat = 0
    private(set) var focusedIndexPath: IndexPath?
    
    private weak var delegate: PhotoVideoDataSourceDelegate?
    private weak var collectionView: UICollectionView!
    
    private let predicateManager = PhotoVideoPredicateManager()
    
    private lazy var sectionChanges = [() -> Void]()
    private lazy var objectChanges = [() -> Void]()
    
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
    
    func object(at indexPath: IndexPath) -> MediaItem? {
        if let section = fetchedResultsController.sections?[safe: indexPath.section],
            section.numberOfObjects > indexPath.row {
            return fetchedResultsController.object(at: indexPath)
        }
        return nil
    }
    
    func indexPath(forObject object: MediaItem) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    func performFetch() {
        try? fetchedResultsController.performFetch()
        //need for update year view on scrollBar
        updateLastFetchedObjects()
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
        if !lastWrapedObjects.isEmpty {
            completion(lastWrapedObjects.getArray())
        } else {
            delegate?.convertFetchedObjectsDidStart()
            convertFetchedObjects(completion)
        }
    }
    
    private func convertFetchedObjects(_ completion: WrapObjectsCallBack? = nil) {
        DispatchQueue.toBackground { [weak self] in
            let ids = self?.lastFetchedObjects?.map { $0.idValue } ?? []
            MediaItemOperationsService.shared.mediaItemsByIDs(ids: ids) { [weak self] items in
                guard let `self` = self else {
                    return
                }
                let wrapedObjects: [WrapData] = items.compactMap { WrapData(mediaItem: $0) }
                completion?(wrapedObjects)
                self.lastWrapedObjects.removeAll()
                self.lastWrapedObjects.append(wrapedObjects)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoVideoDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        sectionChanges.removeAll()
        objectChanges.removeAll()
        lastWrapedObjects.removeAll()
        
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
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.insertItems(at: [indexPath])
                }
            }
        case .delete:
            if let indexPath = indexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
        case .update:
            if let indexPath = indexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.deleteItems(at: [indexPath])
                    self.collectionView.insertItems(at: [newIndexPath])
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let sectionChangesStatic = sectionChanges
        let objectChangesStatic = objectChanges
        sectionChanges.removeAll()
        objectChanges.removeAll()
        
        if !collectionView.isDragging, let firstVisibleItem = firstVisibleItem {
            focusedIndexPath = fetchedResultsController.indexPath(forObject: firstVisibleItem)
            UIView.setAnimationsEnabled(false)
        }
        
        collectionView.performBatchUpdates({
            sectionChangesStatic.forEach { $0() }
            objectChangesStatic.forEach { $0() }
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.reloadSupplementaryViewsIfNeeded()
            self.updateLastFetchedObjects()
            
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
        firstVisibleItem = nil
        cellTopOffset = 0
        focusedIndexPath = nil
        
        if let indexPath = collectionView.indexPathsForVisibleItems.sorted().first, indexPath != IndexPath(item: 0, section: 0) {
            firstVisibleItem = self.object(at: indexPath)
            if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
                cellTopOffset = attributes.frame.origin.y - collectionView.contentOffset.y
            }
        }
    }
    
    private func updateLastFetchedObjects() {
        thresholdService.execute { [weak self] in
            self?.lastFetchedObjects = self?.fetchedOriginalObjects
            self?.delegate?.contentDidChange(self?.fetchedOriginalObjects ?? [])
            self?.convertFetchedObjects()
        }
    }
    
    private func reloadSupplementaryViewsIfNeeded() {
        if !sectionChanges.isEmpty || !objectChanges.isEmpty {
            CellImageManager.clear()
            collectionView.reloadData()
        }
    }
    
}

extension PhotoVideoDataSource: PhotoVideoCollectionViewLayoutDelegate {
    func targetContentOffset() -> CGPoint? {
        return focusedOffset()
    }
}
