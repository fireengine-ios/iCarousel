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
    
    func object(at: IndexPath) -> Item?
}


class FetchService: NSObject {
    
    let batchSize: Int
    
    var controller = NSFetchedResultsController<MediaItem>()
    
    var sortingRules: SortedRules = .timeUp
    
    init(batchSize: Int) {
        self.batchSize = batchSize
        super.init()
    }
    
    static func createController(batchSize: Int,
                                 sortingAgrifate: SortingAgregate,
                                 prediicate: NSPredicate?,
                                 delegate: NSFetchedResultsControllerDelegate?) -> (NSFetchedResultsController<MediaItem>) {
        
        let fetchRequest_ = NSFetchRequest<MediaItem>(entityName: MediaItem.Identifier)
        fetchRequest_.fetchBatchSize = batchSize
        fetchRequest_.sortDescriptors = sortingAgrifate.sortDescriptors
        let folerAtTopPredicate = NSSortDescriptor(key: "isFolder", ascending: false)
        
        fetchRequest_.sortDescriptors?.insert(folerAtTopPredicate, at: 1)

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
        return ""
    }
}

extension FetchService: Iterator {
    
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
            let isAvaliblePrevSection: Bool = indexPath.section > 0
            
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
        guard let allItems: [MediaItem] = controller.fetchedObjects else {
            return []
        }
        let result: [WrapData] =  allItems.flatMap { $0.wrapedObject }
        return result
    }
    
    func object(at: IndexPath) -> WrapData? {
        return self.mediaItemObject(at: at)?.wrapedObject
    }
}
