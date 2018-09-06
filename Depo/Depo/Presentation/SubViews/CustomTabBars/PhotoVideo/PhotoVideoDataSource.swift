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
}

// TODO: selectedIndexPaths NSFetchedResultsController changes
final class PhotoVideoDataSource: NSObject {
    
    var isSelectingMode = false {
        didSet {
            delegate?.selectedModeDidChange(isSelectingMode)
        }
    }
    
    var selectedIndexPaths = Set<IndexPath>()
    
    var selectedObjects: [WrapData] {
        return selectedIndexPaths.map { indexPath in
            let object = fetchedResultsController.object(at: indexPath)
            return WrapData(mediaItem: object)
        }
    }
    
    var fetchedObjects: [WrapData] {
        return fetchedResultsController.fetchedObjects?.map { object in
            return WrapData(mediaItem: object)
        } ?? []
    }
    
    private weak var delegate: PhotoVideoDataSourceDelegate?
    private weak var collectionView: UICollectionView!
    
    private let predicateManager = PhotoVideoPredicateManager()
    
    private lazy var sectionChanges = [() -> Void]()
    private lazy var objectChanges = [() -> Void]()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<MediaItem> = {
        let fetchRequest: NSFetchRequest = MediaItem.fetchRequest()
        
        let sortDescriptor1 = NSSortDescriptor(key: #keyPath(MediaItem.creationDateValue), ascending: false)
        //        let sortDescriptor2 = NSSortDescriptor(key: #keyPath(MediaItem.nameValue), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        if Device.isIpad {
            fetchRequest.fetchBatchSize = 50
        } else {
            fetchRequest.fetchBatchSize = 20
        }
        
        //fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(PostDB.id)]
        let context = CoreDataStack.default.mainContext
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: #keyPath(MediaItem.monthValue), cacheName: nil)
        frController.delegate = self
        return frController
    }()
    
    /// collectionView needs only for NSFetchedResultsControllerDelegate
    init(collectionView: UICollectionView?) {
        self.collectionView = collectionView
    }
    
    func object(at indexPath: IndexPath) -> MediaItem {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func indexPath(forObject object: MediaItem) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    func performFetch() {
        try? fetchedResultsController.performFetch()
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
                    self.collectionView.moveItem(at: indexPath, to: newIndexPath)
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({ [weak self] in  
            self?.objectChanges.forEach { $0() }
            ///check: self?.sectionChanges.forEach { $0() }
            }, completion: { [weak self] _ in
                
                self?.collectionView.performBatchUpdates({
                    self?.sectionChanges.forEach { $0() }
                }, completion: { _ in 
                    self?.reloadSupplementaryViewsIfNeeded()
                })
        })
    }
    
    private func reloadSupplementaryViewsIfNeeded() {
        if !sectionChanges.isEmpty {
            collectionView.reloadData()
        }
    }
    
}
