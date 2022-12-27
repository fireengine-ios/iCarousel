//
//  PhotoVideoPredicateManager.swift
//  Depo
//
//  Created by Aleksandr on 9/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


typealias PredicateCallback = (_ predicate: NSPredicate) -> Void

final class PhotoVideoPredicateManager {

    private lazy var hiddenPredicate: NSPredicate = {
        let hiddenStatusValue = ItemStatus.hidden.valueForCoreDataMapping()

        let remoteUnhidden = NSPredicate(format:"(\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.status) != %ui)", hiddenStatusValue)
        let relatedRemotesAreEmpty = NSPredicate(format:"(\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.relatedRemotes).@count = 0)")
        let relatedRemotesHasUnhidden = NSPredicate(format:"(\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.relatedRemotes).@count != 0 AND SUBQUERY(\(MediaItem.PropertyNameKey.relatedRemotes), $x, $x.\(MediaItem.PropertyNameKey.status) != %ui).@count != 0)")
 
        return NSCompoundPredicate(orPredicateWithSubpredicates: [remoteUnhidden,
                                                                  relatedRemotesAreEmpty,
                                                                  relatedRemotesHasUnhidden])
    }()
    

    func getMainCompoundedPredicate(fileTypes: [FileType]) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            getFiltrationPredicate(fileTypes: fileTypes),
            getDuplicationPredicate(),
            hiddenPredicate
        ])
    }
    
    func getDuplicationPredicate() -> NSPredicate {
        // This Predicate based on assumption that all remotes were downloaded before all locals are
        return NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = true"),
                NSPredicate(format: "\(MediaItem.PropertyNameKey.hasMissingDateRemotes) = true || \(MediaItem.PropertyNameKey.relatedRemotes).@count = 0"),
            ]),
            NSPredicate(format: "\(MediaItem.PropertyNameKey.isLocalItemValue) = false")
        ])
    }

    func getSyncPredicate(fileTypes: [FileType]) -> NSPredicate {
        let hiddenStatusValue = ItemStatus.hidden.valueForCoreDataMapping()
        
        let unhidden = NSPredicate(format: "(\(MediaItem.PropertyNameKey.isLocalItemValue) = false AND \(MediaItem.PropertyNameKey.status) != %ui)", hiddenStatusValue)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [getFiltrationPredicate(fileTypes: fileTypes), unhidden])
    }
    
    func getUnsyncPredicate(fileTypes: [FileType]) -> NSPredicate {
        let localWithoutRemotes = NSPredicate(format:"(\(MediaItem.PropertyNameKey.isLocalItemValue) = true AND \(MediaItem.PropertyNameKey.relatedRemotes).@count = 0)")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [getFiltrationPredicate(fileTypes: fileTypes), localWithoutRemotes])
    }
    
    private func getFiltrationPredicate(fileTypes: [FileType]) -> NSPredicate {
        let rawFileTypes = fileTypes.map { $0.valueForCoreDataMapping() }
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(MediaItem.PropertyNameKey.fileTypeValue) IN %@", rawFileTypes),
            NSPredicate(format: "\(MediaItem.PropertyNameKey.isAvailable) = true")
        ])
    }
}
