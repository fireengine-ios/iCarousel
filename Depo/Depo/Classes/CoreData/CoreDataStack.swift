//
//  CoreDataStack.swift
//  Depo
//
//  Created by Alexander Gurin on 7/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import CoreData
import Photos

class CoreDataStack: NSObject {
    
    @objc static let `default` = CoreDataStack()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        guard let modelURL = Bundle.main.url(forResource: "LifeBoxModel",
                                             withExtension:"momd"),
              let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Error loading model from bundle")
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        do {
            let storeURL = Device.documentsFolderUrl(withComponent: "DataModel.sqlite")
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                configurationName: nil,
                                                at: storeURL,
                                                options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        
        return coordinator
    }()
    
    var rootBackgroundContext: NSManagedObjectContext
    
    var mainContext: NSManagedObjectContext
    
    var newChildBackgroundContext: NSManagedObjectContext {
        let children =  NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        children.parent = mainContext
        return children
    }
    
    override init() {
        
        rootBackgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        super.init()
        rootBackgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        mainContext.parent = rootBackgroundContext
        
        let name = NSNotification.Name.NSManagedObjectContextDidSave
        let selector = #selector(managedObjectContextObjectsDidSave)
        NotificationCenter.default.addObserver(self,
                                               selector: selector,
                                               name: name,
                                               object: nil)
    }
    
    func saveMainContext() {
        mainContext.processPendingChanges()
        saveDataForContext(context: mainContext, saveAndWait: true)
    }
    
    @objc func saveDataForContext(context: NSManagedObjectContext,saveAndWait: Bool = false) {
        
        let saveBlock: () -> Void = {
            do {
                try context.save()
            } catch {
                print("Error saving context ___ ")
            }
        }
        
        if context.hasChanges {
            if (saveAndWait) {
                context.performAndWait(saveBlock)
            } else {
                context.perform(saveBlock)
            }
        }
        
        if context.parent == mainContext {
            DispatchQueue.main.async {
                self.saveMainContext()
            }
        }
    }
    
    @objc func managedObjectContextObjectsDidSave(notification: Notification) {
        
        if let context = notification.object as? NSManagedObjectContext,
            let parent = context.parent {
            parent.mergeChanges(fromContextDidSave: notification)
            if parent == rootBackgroundContext {
                print("SAVE MAIN CONTEXT %@ ", Date() )
            }
        }
  
    }
    
}
