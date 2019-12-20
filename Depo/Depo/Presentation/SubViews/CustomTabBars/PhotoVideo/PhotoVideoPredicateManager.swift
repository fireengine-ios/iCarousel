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
    
    private lazy var hiddenPredicate: NSPredicate = {
        let hiddenStatusValue = ItemStatus.hidden.valueForCoreDataMapping()
        
        let isLocalItemValue = #keyPath(MediaItem.isLocalItemValue)
        let relatedRemotes = #keyPath(MediaItem.relatedRemotes)
        let status = #keyPath(MediaItem.status)
        
        let remoteUnhidden = NSPredicate(format:"(\(isLocalItemValue) = false AND \(status) != %ui)", hiddenStatusValue)
        let relatedRemotesAreEmpty = NSPredicate(format:"(\(isLocalItemValue) = true AND \(relatedRemotes).@count = 0)")
        let relatedRemotesHasUnhidden = NSPredicate(format:"(\(isLocalItemValue) = true AND \(relatedRemotes).@count != 0 AND SUBQUERY(\(relatedRemotes), $x, $x.\(status) != %ui).@count != 0)")
 
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
        let duplicationPredicateTmp = NSPredicate(format: "(isLocalItemValue = true AND (hasMissingDateRemotes = true || relatedRemotes.@count = 0)) OR isLocalItemValue = false")
        duplicationPredicate = duplicationPredicateTmp
        createdPredicateCallback(duplicationPredicateTmp)
    }

    func getSyncPredicate(isPhotos: Bool) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [getFiltrationPredicate(isPhotos: isPhotos), NSPredicate(format: "isLocalItemValue == false")])
    }
    
    private func getFiltrationPredicate(isPhotos: Bool) -> NSPredicate {
        guard let unwrapedFiltrationPredicate = filtrationPredicate else {
            let type = isPhotos ? FileType.image.valueForCoreDataMapping() :
                FileType.video.valueForCoreDataMapping()
            let predicateFormat = "fileTypeValue == \(type)"
            return NSPredicate(format: predicateFormat)
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
