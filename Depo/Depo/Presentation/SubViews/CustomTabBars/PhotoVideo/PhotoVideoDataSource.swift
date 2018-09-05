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
    
    private var originalPredicate = NSPredicate() //maybe there is some sence to setup it every time from controller, and not here
//    private var duplicationPredicate = NSPredicate()
    //TODO: move all work with predicates into another class
    
    private lazy var sectionChanges = [() -> Void]()
    private lazy var objectChanges = [() -> Void]()
    
//    private lazy var
    
    private lazy var fetchedResultsController: NSFetchedResultsController<MediaItem> = {
        let fetchRequest: NSFetchRequest = MediaItem.fetchRequest()
        
        
    
//        fetchRequest.predicate = NSPredicate(format: "isLocalItemValue = true AND ", [])
//        NSCompoundPredicate(andPredicateWithSubpredicates:
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
        let type = isPhotos ? FileType.image.valueForCoreDataMapping() :
        FileType.video.valueForCoreDataMapping()
        let predicateFormat = "fileTypeValue == \(type)"
        let filetPredicate = NSPredicate(format: predicateFormat)
        
        
        
        setupDuplicationPredicate(duplicationPredicateCallback: { [weak self] duplicatesPredicate in
            let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filetPredicate, duplicatesPredicate])
            self?.originalPredicate = duplicatesPredicate
            self?.fetchedResultsController.fetchRequest.predicate = self?.originalPredicate
            predicateSetupedCallback()
        })
    }
    
    func changeSourceFilter(syncOnly: Bool) {
        if syncOnly {
            fetchedResultsController.fetchRequest.predicate =
                NSCompoundPredicate(andPredicateWithSubpredicates: [originalPredicate, NSPredicate(format: "isLocalItemValue != \(syncOnly)")])
//                 ///most likely we need to incer ANDpredicate here = previous + local status
        } else {
            fetchedResultsController.fetchRequest.predicate = originalPredicate///Previous predicate here
        }
        performFetch()
    }
    
}

// MARK: - DATA BASE

extension PhotoVideoDataSource {
    private func setupDuplicationPredicate(duplicationPredicateCallback: (_ predicate: NSPredicate) -> Void) {
        createPredicate(createdPredicateCallback: {[weak self] predicate in
            //TODO: compound predicate
            debugPrint("!!! PREDICATE SETUPED")
            DispatchQueue.main.async {
                self?.fetchedResultsController.fetchRequest.predicate = predicate
                
            }
        })
    }
    
    private func createPredicate(createdPredicateCallback: @escaping (_ predicate: NSPredicate) -> Void) {
        guard !CacheManager.shared.processingRemoteItems else {
            CacheManager.shared.remotePageAdded = { [weak self] in
                self?.createPredicate(createdPredicateCallback: createdPredicateCallback)
            }
            return
        }
        MediaItemOperationsService.shared.getAllRemotesMediaItem(allRemotes: { [weak self] allRemotes in
            var remoteMD5s = [String]()
            var remoteLocalIDs = [String]()
            allRemotes.forEach {
                remoteMD5s.append($0.md5Value ?? "")
                remoteLocalIDs.append($0.trimmedLocalFileID ?? "")
            }
            //REMOVE ME
            //        let locals = MediaItemOperationsService.shared.allLocalItems()
            //REMOVE ME
            let duplicationPredicateTmp = NSPredicate(format: "isLocalItemValue == true AND NOT (md5Value IN %@)", remoteMD5s)/*  AND NOT (trimmedLocalFileID IN \(remoteLocalIDs))) OR isLocalItemValue == FALSE"*/
            /// ///PREDICATE HERE
            //self?.duplicationPredicate = duplicationPredicateTmp
            createdPredicateCallback(duplicationPredicateTmp)
        })
    }
//    private func compundPredicates()
    
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
