//
//  LogoutDBCleaner.swift
//  Depo
//
//  Created by Konstantin Studilin on 05/05/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol LogoutDBCleaner {
    var completionHandler: VoidHandler { get }
    
    func start()
}

final class LogoutDBCleanerImpl: LogoutDBCleaner {
    
    private (set) var completionHandler: VoidHandler
    
    private var mustClean = false
    private let coreDataStack: CoreDataStack = factory.resolve()
    
    
    init(completion: @escaping VoidHandler) {
        completionHandler = completion
    }
    
    func set(completion: @escaping VoidHandler) {
        completionHandler = completion
    }
    
    func start() {
        guard !mustClean else {
            return
        }
        
        mustClean = true
        
        clean()
    }
    
    private func clean() {
        guard coreDataStack.isReady else {
            coreDataStack.delegates.add(self)
            debugLog("DB cannot be cleaned. Waiting for CoreData to be ready.")
            return
        }
        
        coreDataStack.delegates.remove(self)
        
        MediaItemOperationsService.shared.deleteRemoteEntities { [weak self] _ in
            debugLog("Remote entities are deleted from DB")
            
            guard let self = self else {
                return
            }
            
            MediaItemsAlbumOperationService.shared.resetLocalAlbums(completion: nil)
            
            self.mustClean = false
            self.completionHandler()
        }
    }
}

extension LogoutDBCleanerImpl: CoreDataStackDelegate {
    func onCoreDataStackSetupCompleted() {
        guard mustClean else {
            return
        }
        
        clean()
    }
}
