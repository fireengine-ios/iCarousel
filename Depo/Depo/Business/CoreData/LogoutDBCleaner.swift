//
//  LogoutDBCleaner.swift
//  Depo
//
//  Created by Konstantin Studilin on 05/05/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


protocol LogoutDBCleanerDelegate {
    func didClean()
}

protocol LogoutDBCleaner {
    static var shared: LogoutDBCleaner { get }
    
    var mustClean: Bool { get }
    var delegates: MulticastDelegate<LogoutDBCleanerDelegate> { get }
    
    func clean(completion: @escaping BoolHandler)
}

final class LogoutDBCleanerImpl: LogoutDBCleaner {
    static let shared: LogoutDBCleaner = LogoutDBCleanerImpl()
    
    let delegates = MulticastDelegate<LogoutDBCleanerDelegate>()
    
    private (set) var mustClean = false
    
    private let coreDataStack: CoreDataStack = factory.resolve()
    
    
    private init() { }
    
    func clean(completion: @escaping BoolHandler) {
        mustClean = true
        
        guard coreDataStack.isReady else {
            coreDataStack.delegates.add(self)
            debugLog("DB cannot be cleaned. Waiting for CoreData to be ready.")
            completion(false)
            return
        }
        
        MediaItemOperationsService.shared.deleteRemoteEntities { _ in
            debugLog("Remote entities are deleted from DB")
            
            MediaItemsAlbumOperationService.shared.resetLocalAlbums(completion: { [weak self] in
                debugLog("Local albums has been reset")
                debugLog("DB has been cleaned")
                
                guard let self = self else {
                    completion(true)
                    return
                }
                
                self.mustClean = false
                
                completion(true)
            })
        }
        
    }
}

extension LogoutDBCleanerImpl: CoreDataStackDelegate {
    func onCoreDataStackSetupCompleted() {
        guard mustClean else {
            return
        }
        
        clean { _ in
            //
        }
    }
}
