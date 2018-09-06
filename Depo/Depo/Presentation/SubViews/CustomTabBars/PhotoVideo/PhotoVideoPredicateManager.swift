//
//  PhotoVideoPredicateManager.swift
//  Depo
//
//  Created by Aleksandr on 9/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

typealias PredicateCallback = (_ predicate: NSPredicate?) -> Void

final class PhotoVideoPredicateManager {
    
    private var filtrationPredicate: NSPredicate?
    private var duplicationPredicate: NSPredicate?
    
    func getMainCompundedPredicate(isPhotos: Bool, createdPredicateCallback: @escaping PredicateCallback) {
    
        guard !CacheManager.shared.processingRemoteItems else {
            CacheManager.shared.remotePageAdded = { [weak self] in
                self?.getMainCompundedPredicate(isPhotos: isPhotos, createdPredicateCallback: createdPredicateCallback)
            }
            return
        }
        MediaItemOperationsService.shared.getAllRemotesMediaItem(allRemotes: { allRemotes in
            var remoteMD5s = [String]()
            var remoteLocalIDs = [String]()
            allRemotes.forEach {
                remoteMD5s.append($0.md5Value ?? "")
                remoteLocalIDs.append($0.trimmedLocalFileID ?? "")
            }
            let duplicationPredicateTmp = NSPredicate(format: "(isLocalItemValue == true AND NOT (md5Value IN %@) AND NOT (trimmedLocalFileID IN %@)) OR isLocalItemValue == FALSE", remoteMD5s, remoteLocalIDs)
            
            createdPredicateCallback(duplicationPredicateTmp)
        })
  
    }

    func getSyncPredicate(isPhotos: Bool, syncPredicate: @escaping PredicateCallback) {
        
    }
    
    private func getCompoundedPredicate() -> NSPredicate? {
        guard let unwrapedFiltrationPredicate = filtrationPredicate,
            let unwrapedDuplicationPredicate = duplicationPredicate else {
                return nil
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [unwrapedFiltrationPredicate, unwrapedDuplicationPredicate])
    }
    
}
