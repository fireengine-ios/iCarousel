//
//  PhotoVideoPredicateManager.swift
//  Depo
//
//  Created by Aleksandr on 9/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//


typealias PredicateCallback = (_ predicate: NSPredicate) -> Void

final class PhotoVideoPredicateManager {
    
    private var filtrationPredicate: NSPredicate?
    private var duplicationPredicate: NSPredicate?
    
    private enum Keys {
        static let fileTypeValue = #keyPath(MediaItem.fileTypeValue)
        static let hasMissingDateRemotes = #keyPath(MediaItem.hasMissingDateRemotes)
        static let isAvailable = #keyPath(MediaItem.isAvailable)
        static let isLocalItemValue = #keyPath(MediaItem.isLocalItemValue)
        static let relatedRemotes = #keyPath(MediaItem.relatedRemotes)
        static let status = #keyPath(MediaItem.status)
    }
        
    private lazy var hiddenPredicate: NSPredicate = {
        let hiddenStatusValue = ItemStatus.hidden.valueForCoreDataMapping()

        let remoteUnhidden = NSPredicate(format:"(\(Keys.isLocalItemValue) = false AND \(Keys.status) != %ui)", hiddenStatusValue)
        let relatedRemotesAreEmpty = NSPredicate(format:"(\(Keys.isLocalItemValue) = true AND \(Keys.relatedRemotes).@count = 0)")
        let relatedRemotesHasUnhidden = NSPredicate(format:"(\(Keys.isLocalItemValue) = true AND \(Keys.relatedRemotes).@count != 0 AND SUBQUERY(\(Keys.relatedRemotes), $x, $x.\(Keys.status) != %ui).@count != 0)")
 
        return NSCompoundPredicate(orPredicateWithSubpredicates: [remoteUnhidden,
                                                                  relatedRemotesAreEmpty,
                                                                  relatedRemotesHasUnhidden])
    }()
    
    private var lastCompoundedPredicate: NSPredicate?
    
    func getMainCompoundedPredicate(isPhotos: Bool, createdPredicateCallback: @escaping PredicateCallback) {
        
        if let unwrapedLastCompundedPredicate = lastCompoundedPredicate {
            createdPredicateCallback(unwrapedLastCompundedPredicate)
            return
        }
        
        let filtrationPredicateTmp = getFiltrationPredicate(isPhotos: isPhotos)
        
        getDuplicationPredicate(isPhotos: isPhotos) { [weak self] createdDuplicationPredicate in
            guard let self = self else {
                assertionFailure("Unexpected PhotoVideoPredicateManager == nil")
                return
            }
            let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filtrationPredicateTmp, createdDuplicationPredicate, self.hiddenPredicate])
            self.lastCompoundedPredicate = compoundedPredicate
            
            createdPredicateCallback(compoundedPredicate)
            
        }
    }
    
    func getDuplicationPredicate(isPhotos: Bool, createdPredicateCallback: @escaping PredicateCallback) {
        
        if let unwrapedDuplicationPredicate = duplicationPredicate {
            createdPredicateCallback(unwrapedDuplicationPredicate)
            return
        }
        ///This Predicate based on assumption that all remotes were downloaded before all locals are
        let duplicationPredicateTmp = NSPredicate(format: "(\(Keys.isLocalItemValue) = true AND (\(Keys.hasMissingDateRemotes) = true || \(Keys.relatedRemotes).@count = 0)) OR \(Keys.isLocalItemValue) = false")
        duplicationPredicate = duplicationPredicateTmp
        createdPredicateCallback(duplicationPredicateTmp)
    }

    func getSyncPredicate(isPhotos: Bool) -> NSPredicate {
        let hiddenStatusValue = ItemStatus.hidden.valueForCoreDataMapping()
        
        let remoteUnhidden = NSPredicate(format:"(\(Keys.isLocalItemValue) = false AND \(Keys.status) != %ui)", hiddenStatusValue)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [getFiltrationPredicate(isPhotos: isPhotos), remoteUnhidden])
    }
    
    private func getFiltrationPredicate(isPhotos: Bool) -> NSPredicate {
        guard let unwrapedFiltrationPredicate = filtrationPredicate else {
            let type: FileType = isPhotos ? .image : .video
            return NSPredicate(format: "\(Keys.fileTypeValue) = \(type.valueForCoreDataMapping()) AND \(Keys.isAvailable) = true")
        }
        return unwrapedFiltrationPredicate
    }
    
    private func getCompoundedPredicate() -> NSPredicate? {
        /// OR we can do callback and call individual predicates untill tey are finished
        guard let unwrapedFiltrationPredicate = filtrationPredicate,
            let unwrapedDuplicationPredicate = duplicationPredicate else {
                return nil
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: [unwrapedFiltrationPredicate, unwrapedDuplicationPredicate])
    }
    
}
