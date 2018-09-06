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
    
    private var lastCompundedPredicate: NSPredicate?
    
    func getMainCompoundedPredicate(isPhotos: Bool, createdPredicateCallback: @escaping PredicateCallback) {
        
        if let unwrapedLastCompundedPredicate = lastCompundedPredicate {
            createdPredicateCallback(unwrapedLastCompundedPredicate)
            return
        }
        
        let filtrationPredicateTmp = getFiltrationPredicate(isPhotos: isPhotos)
        
        getDuplicationPredicate(isPhotos: isPhotos) { [weak self] createdDuplicationPredicate in
            let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filtrationPredicateTmp, createdDuplicationPredicate])
            self?.lastCompundedPredicate = compundedPredicate
            
            createdPredicateCallback(compundedPredicate)
            
        }
        
        
    }
    
    func getDuplicationPredicate(isPhotos: Bool, createdPredicateCallback: @escaping PredicateCallback) {
        
        if let unwrapedDuplicationPredicate = duplicationPredicate {
            createdPredicateCallback(unwrapedDuplicationPredicate)
            return
        }
        
        guard !CacheManager.shared.processingRemoteItems else {
            CacheManager.shared.remotePageAdded = { [weak self] in
                self?.getDuplicationPredicate(isPhotos: isPhotos, createdPredicateCallback: createdPredicateCallback)
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
            let duplicationPredicateTmp = NSPredicate(format: "(isLocalItemValue == true AND NOT (md5Value IN %@) AND NOT (trimmedLocalFileID IN %@)) OR isLocalItemValue == FALSE", remoteMD5s, remoteLocalIDs)
            self?.duplicationPredicate = duplicationPredicateTmp
            createdPredicateCallback(duplicationPredicateTmp)
        })
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
