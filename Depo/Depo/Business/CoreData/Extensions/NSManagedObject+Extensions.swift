//
//  NSManagedObject+Extensions.swift
//  EventsCountdown
//
//  Created by Bondar Yaroslav on 30/07/2018.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import CoreData

typealias ManagedObjectDeleteStatusHandler = (ManagedObjectDeleteStatus) -> Void

enum ManagedObjectDeleteStatus {
    case deleted
    case thereIsNoContext
    case error(Error)
}

extension NSManagedObject {
    /// delete NSManagedObject on same context that was fetched
    func delete(completion: ManagedObjectDeleteStatusHandler? = nil) {
        guard let context = managedObjectContext else {
            completion?(.thereIsNoContext)
            return
        }
        /// weak?
        context.perform {
            context.delete(self)
            do {
                try context.save()
                completion?(.deleted)
            } catch {
                completion?(.error(error))
            }
            
        }
    }
    
    class func entityDescription(context: NSManagedObjectContext) -> NSEntityDescription {
        return self.entity()
    }
}
