//
//  NSManagedObjectContext+Extensions.swift
//  EventsCountdown
//
//  Created by Bondar Yaroslav on 30/07/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import CoreData

typealias CoreDataSaveStatusHandler = (CoreDataSaveStatus) -> Void

enum CoreDataSaveStatus {
    case saved
    case hasNoChanges
    case rolledBack(Error)
}

extension NSManagedObjectContext {
    
    func saveAsync(completion: CoreDataSaveStatusHandler? = nil) {
        guard hasChanges else {
            completion?(.hasNoChanges)
            return
        }
        
        guard UIApplication.shared.isProtectedDataAvailable else {
            rollback()
            completion?(.rolledBack(ErrorResponse.string(TextConstants.NotLocalized.dataProtectedAndDeviceLocked)))
            return
        }
        
        /// weak ???
        perform { [weak self] in
            do {
                try self?.save()
                completion?(.saved)
            } catch {
                self?.rollback()
                completion?(.rolledBack(error))
            }
        }
    }
    
    func saveSync(completion: CoreDataSaveStatusHandler? = nil) {
        guard hasChanges else {
            completion?(.hasNoChanges)
            return
        }
        
        guard UIApplication.shared.isProtectedDataAvailable else {
            rollback()
            completion?(.rolledBack(ErrorResponse.string(TextConstants.NotLocalized.dataProtectedAndDeviceLocked)))
            return
        }
        
        /// weak ???
        performAndWait {
            do {
                try self.save()
                completion?(.saved)
            } catch {
                self.rollback()
                completion?(.rolledBack(error))
            }
        }
    }
    
    /// saveAsync + saveSync method with if statement
    func save(async: Bool, completion: CoreDataSaveStatusHandler? = nil) {
        guard hasChanges else {
            completion?(.hasNoChanges)
            return
        }
        
        guard UIApplication.shared.isProtectedDataAvailable else {
            rollback()
            completion?(.rolledBack(ErrorResponse.string(TextConstants.NotLocalized.dataProtectedAndDeviceLocked)))
            return
        }

        let performBlock = { [weak self] in
            do {
                try self?.save()
                completion?(.saved)
            } catch {
                self?.rollback()
                completion?(.rolledBack(error))
            }
        }
        
        if async {
            perform(performBlock)
        } else {
            performAndWait(performBlock)
        }
    }
    
    // TODO: need to test without NSManagedObjectContextDidSave notification
//    func saveAsyncWithParantMerge(async: Bool, completion: CoreDataSaveStatusHandler? = nil) {
//        save(async: async) { [weak self] status in
//            switch status {
//            case .saved:
//                let mainContext = CoreDataStack.shared.mainContext
//                if self != mainContext, self?.parent == mainContext {
//                    mainContext.saveAsync(completion: completion)
//                } else {
//                    completion?(.saved)
//                }
//            default:
//                completion?(status)
//            }
//        }
//    }
    
    @discardableResult
    func saveSyncUnsafe() -> CoreDataSaveStatus {
        if hasChanges {
            do {
                try save()
                return .saved
            } catch {
                rollback()
                return .rolledBack(error)
            }
        }
        return .hasNoChanges
    }
}
