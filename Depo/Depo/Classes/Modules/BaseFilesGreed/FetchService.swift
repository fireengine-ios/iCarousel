//
//  Fetch.swift
//  Depo
//
//  Created by Alexander Gurin on 8/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import ObjectiveC
import CoreData

protocol Iterator {
    
    associatedtype Item
    
    var curent: Item? { get set }
    
    func next() -> Item?
    
    func prev() -> Item?
    
    func all() -> [Item]
    
    func object(at:IndexPath) -> Item?
}


class FetchService: NSObject {
    
    let batchSize: Int
    
    var controller: NSFetchedResultsController<MediaItem>
    
    var sortingRules: SortedRules = .timeUp
    
    var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? {
        set {
            controller.delegate = newValue
        }
        get {
            return controller.delegate
        }
    }
    
    init(batchSize: Int, delegate:NSFetchedResultsControllerDelegate?) {

        let agregate = CollectionSortingRules(sortingRules: .lettersAZ).rule
        controller = FetchService.createController(batchSize: batchSize,
                                           sortingAgrifate: agregate,
                                           prediicate: nil,
                                           delegate:delegate)
        self.batchSize = batchSize
        super.init() 
    }
    
    static func createController(batchSize: Int,
                                 sortingAgrifate: SortingAgregate,
                                 prediicate: NSPredicate?,
                                 delegate:NSFetchedResultsControllerDelegate?) -> (NSFetchedResultsController<MediaItem>) {
        
        let fetchRequest_ = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        fetchRequest_.fetchBatchSize = batchSize
        fetchRequest_.sortDescriptors = sortingAgrifate.sortDescriptors
        fetchRequest_.predicate = prediicate
        
        let keyPathName = sortingAgrifate.section
        
        let context = CoreDataStack.default.mainContext
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest_,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: keyPathName,
                                                cacheName: nil)
        controller.delegate = delegate
        return controller
    }
    
    func performFetch() {
        do {
            try controller.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    func performFetch(sortingRules: SortedRules,
                      filtes:[GeneralFilesFiltrationType]? = nil,
                      delegate:NSFetchedResultsControllerDelegate? = nil) {
        
        self.sortingRules = sortingRules
        let sortingAgregate = CollectionSortingRules(sortingRules: sortingRules).rule
        let predicate = PredicateRules().predicate(filters: filtes)
        
        controller = FetchService.createController(batchSize: self.batchSize,
                                                   sortingAgrifate: sortingAgregate,
                                                   prediicate: predicate,
                                                   delegate: delegate)
        performFetch()
    }
    
    func mediaItemObject(at: IndexPath) -> MediaItem? {
        
        guard let sections = controller.sections?.count,
            sections > at.section,
            let rows = controller.sections?[at.section].numberOfObjects,
            rows > at.row
        else { return nil }
        
        let obj = controller.object(at: at)
        return obj
    }
 
    func headerText(indexPath: IndexPath) -> String {
        
        guard let value = mediaItemObject(at: indexPath)
            else {
            return ""
        }
        
        switch sortingRules {
        case .lettersAZ,.lettersZA:
            let char = (value.nameValue ?? " ").characters.first!
            let result = String(describing: char).uppercased()
            return result
            
        case .sizeAZ, .sizeZA,.timeDown, .timeUp:
            let date = value.creationDateValue! as Date
            return date.getDateInTextForCollectionViewHeader()
        }
    }
    
    func needSeparateBySection() -> Bool{
        if (sortingRules == .sizeAZ) || (sortingRules == .sizeZA){
            return false
        }
        return true
    }
    
}

extension FetchService: Iterator  {
    
    typealias Item = WrapData
    
    var curent: WrapData? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    func next() -> WrapData? {
        if let obj = curent?.coreDataObject,
           let indexPath = controller.indexPath(forObject: obj) {
            
            var newIndexPath: IndexPath
            
            let rowsInSection: Int = controller.sections?[indexPath.section].numberOfObjects ?? 0
            let isAvalibleNexItemInRow: Bool = rowsInSection > indexPath.row
            let isAvalibleNextSection: Bool = (controller.sections?.count ?? 0) > indexPath.section
 
            if isAvalibleNexItemInRow {
                newIndexPath = IndexPath(row: indexPath.row + 1,
                                         section: indexPath.section)
                return controller.object(at: newIndexPath).wrapedObject
            }
            
            if isAvalibleNextSection {
                newIndexPath = IndexPath(row: 0,
                                         section: indexPath.section + 1)
                return controller.object(at: newIndexPath).wrapedObject
            }
            
            return nil
        }
        return nil
    }
    
    func prev() -> WrapData? {
        
        if let obj = curent?.coreDataObject,
            let indexPath = controller.indexPath(forObject: obj) {
            
            var newIndexPath: IndexPath
            
            let rowsInSection: Int = controller.sections?[indexPath.section].numberOfObjects ?? 0
            let isAvaliblePrevItemInRow: Bool = rowsInSection > 1
            let isAvaliblePrevSection: Bool =  indexPath.section > 0
            
            if isAvaliblePrevItemInRow {
                newIndexPath = IndexPath(row: indexPath.row - 1,
                                         section: indexPath.section)
                return controller.object(at: newIndexPath).wrapedObject
            }
            
            if isAvaliblePrevSection,
                let lastRowIndex = controller.sections?[indexPath.section - 1].numberOfObjects {
                newIndexPath = IndexPath(row: lastRowIndex,
                                         section: indexPath.section - 1)
                return controller.object(at: newIndexPath).wrapedObject
            }
            
            return nil
        }
        return nil
    }
    
    
    func all() -> [WrapData] {
        guard let allItems:[MediaItem] = controller.fetchedObjects else {
            return []
        }
        let result: [WrapData] =  allItems.flatMap{ $0.wrapedObject }
        return result
    }
    
    func object(at: IndexPath) -> WrapData? {
        return self.mediaItemObject(at: at)?.wrapedObject
    }
}

private var AssociatedObjectHandle: UInt8 = 0

extension BaseDataSourceForCollectionView {
    
    var blockOperation: BlockOperation {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! BlockOperation
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension BaseDataSourceForCollectionView: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard controller == fetchService.controller,
            let wrapedCollectionView = collectionView else {
            return
        }
        
        switch type {
        case .insert:
            if let newIndex = newIndexPath {
                blockOperation.addExecutionBlock {
                    wrapedCollectionView.insertItems(at: [newIndex])
                }
            }
        case .update:
            if let newIndex = newIndexPath {
                blockOperation.addExecutionBlock {
                    wrapedCollectionView.reloadItems(at: [newIndex])
                }
            }
        case .move:
            if let oldIndex = indexPath,
               let newIndex = newIndexPath{
                blockOperation.addExecutionBlock {
                    wrapedCollectionView.moveItem(at: oldIndex, to: newIndex)
                }
            }
            
        case .delete:
            if let newIndex = indexPath {
                blockOperation.addExecutionBlock { [weak self] in
                    wrapedCollectionView.deleteItems(at: [newIndex])
                    guard let self_ = self else{
                        return
                    }
                    self_.selectedItemsArray.removeAll()
                    self_.updateSelectionCount()
                }
            }
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        
        guard controller == fetchService.controller,
              let wrapedCollectionView = collectionView else {
            return
        }
        
        switch type {
        case .insert:
            blockOperation.addExecutionBlock {
                wrapedCollectionView.insertSections(IndexSet(integer: sectionIndex))
            }
            
        case .delete:
            blockOperation.addExecutionBlock { [weak self] in
                wrapedCollectionView.deleteSections(IndexSet(integer: sectionIndex))
                guard let self_ = self else{
                    return
                }
                self_.selectedItemsArray.removeAll()
                self_.updateSelectionCount()
            }
        
        case .update:
            blockOperation.addExecutionBlock {
                wrapedCollectionView.reloadSections(IndexSet(integer: sectionIndex))
            }
       
        case .move  :
            blockOperation.addExecutionBlock {
//                wrapedCollectionView.moveSection(<#T##section: Int##Int#>, toSection: <#T##Int#>)
              //  wrapedCollectionView.moveSection(IndexPath.section, toSection: new)
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard controller == fetchService.controller,
             let _ = collectionView  else  {
            return
        }
        
       blockOperation = BlockOperation()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        guard controller == fetchService.controller,
             let unWrappedCollectionView = collectionView else {
            return
        }
        unWrappedCollectionView.reloadData()
        
//        unWrappedCollectionView.performBatchUpdates({
//            print("RELOAD ___")
//            OperationQueue.main.addOperation(blockOperation)
//
//        }) {  complited in
//            print("Did change content ", complited ?"yes":"false")
//        }
    }
}
