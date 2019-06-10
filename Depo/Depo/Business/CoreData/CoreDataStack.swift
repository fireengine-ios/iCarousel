//
//  CoreDataStack.swift
//  Depo
//
//  Created by Alexander Gurin on 7/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack: NSObject {
    
    typealias AppendingLocaclItemsFinishCallback = () -> Void
    typealias AppendingLocaclItemsProgressCallback = (Float) -> Void
    
    typealias AppendingLocalItemsPageAppended = ([Item])->Void
    
    static let notificationNewLocalPageAppendedFilesKey = "notificationNewLocalPageAppendedFilesKey"
    
    @objc static let `default` = CoreDataStack()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        guard let modelURL = Bundle.main.url(forResource: "LifeBoxModel", withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else { fatalError("Error loading model from bundle") }

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        do {
            let storeURL = Device.documentsFolderUrl(withComponent: "DataModel.sqlite")
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                configurationName: nil,
                                                at: storeURL,
                                                options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                          NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        
        return coordinator
    }()
    
    var mainContext: NSManagedObjectContext
    
    var newChildBackgroundContext: NSManagedObjectContext {
        let children = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        children.parent = mainContext
        return children
    }
    
    var backgroundContext: NSManagedObjectContext
    
    let privateQueue = DispatchQueue(label: DispatchQueueLabels.coreDataStack, attributes: .concurrent)
    
    var inProcessAppendingLocalFiles = false
    
    var originalAssetsBeingAppended = AssetsCache()
    var nonCloudAlreadySavedAssets = AssetsCache()
    
    override init() {
        
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        super.init()
        mainContext.persistentStoreCoordinator = persistentStoreCoordinator
        backgroundContext.parent = mainContext
    }
    
    func clearDataBase() {
        deleteRemoteFiles()
    }
    
    func deleteRemoteFiles() {
        // Album has remote status by default for now
        let albumFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItemsAlbum.Identifier)
        
        let mediaItemFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        let predicateRules = PredicateRules()
        guard let predicate = predicateRules.predicate(filters: [.localStatus(.nonLocal)]) else {
            return
        }
        mediaItemFetchRequest.predicate = predicate
        
        self.deleteObjects(fromFetches: [albumFetchRequest, mediaItemFetchRequest])
    }

    func deleteLocalFiles() {
        
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
            let predicateRules = PredicateRules()
            guard let predicate = predicateRules.predicate(filters: [.localStatus(.local)]) else {
                return
            }
            fetchRequest.predicate = predicate
            self.deleteObjects(fromFetch: fetchRequest)
        
    }
    
    func getLocalDuplicates(remoteItems: [Item], duplicatesCallBack: @escaping LocalFilesCallBack) {
        var remoteMd5s = [String]()
        var trimmedIDs = [String]()
        remoteItems.forEach {
            remoteMd5s.append($0.md5)
            trimmedIDs.append($0.getTrimmedLocalID())
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        fetchRequest.predicate = NSPredicate(format: "(md5Value IN %@) OR (trimmedLocalFileID IN %@)", remoteMd5s, trimmedIDs)
        let sort = NSSortDescriptor(key: "creationDateValue", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        let context = CoreDataStack.default.newChildBackgroundContext
        context.perform {
            guard let localDuplicatesMediaItems = (try? context.fetch(fetchRequest)) as? [MediaItem] else {
                duplicatesCallBack([])
                return
            }
            var array = [Item]()
            array = localDuplicatesMediaItems.flatMap { WrapData(mediaItem: $0) }

            duplicatesCallBack(array)
        }
    }

    func getLocalFilteredItem(remoteOriginalItem: Item, localFilteredPhotosCallBack: @escaping (Item?) -> Void) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: MediaItem.Identifier)
        fetchRequest.predicate = NSPredicate(format: "(md5Value = %@) AND (isFiltered == true)", remoteOriginalItem.md5, remoteOriginalItem.getTrimmedLocalID())
        
        let context = CoreDataStack.default.newChildBackgroundContext
        context.perform {
            guard let localDuplicatesMediaItems = (try? context.fetch(fetchRequest)) as? [MediaItem] else {
                localFilteredPhotosCallBack(nil)
                return
            }
            var array = [Item]()
            array = localDuplicatesMediaItems.flatMap { WrapData(mediaItem: $0) }
            localFilteredPhotosCallBack(array.first)
        }
        
    }
    
    private func deleteObjects(fromFetches fetchRequests: [NSFetchRequest<NSFetchRequestResult>]) {
        for fetchRequest in fetchRequests {
            self.deleteObjects(fromFetch: fetchRequest)
        }
    }
    
    private func deleteObjects(fromFetch fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let context = newChildBackgroundContext
        context.perform { [weak self] in
            guard let fetchResult = try? context.fetch(fetchRequest),
                let unwrapedObjects = fetchResult as? [NSManagedObject],
                unwrapedObjects.count > 0 else {
                    
                    return
            }
            for object in unwrapedObjects {
                context.delete(object)
            }
            self?.saveDataForContext(context: context, saveAndWait: true, savedCallBack: {
                debugPrint("Data base deleted objects")
            })
            
        }
    }
    
    private func saveMainContext(savedMainCallBack: VoidHandler?) {
        if mainContext.hasChanges {
            mainContext.perform { [weak self] in
                do {
                    try self?.mainContext.save()
                    
                    self?.privateQueue.async {
                        savedMainCallBack?()
                    }
                } catch {
                    debugLog("Error saving context mainContext.save()()")
                    print("Error saving context ___ ")
                }
            }
        } else {
            privateQueue.async {
                savedMainCallBack?()
            }
        }
    }
    
    @objc func saveDataForContext(context: NSManagedObjectContext, saveAndWait: Bool = true,
                                  savedCallBack: VoidHandler?) {
        let saveBlock: VoidHandler = { [weak self] in
            guard let `self` = self else {
                return
            }
            do {
                try context.save()
            } catch {
                debugLog("saveDataForContext() save() Error saving contex")
                print("Error saving context ___ ")
            }
            
            if context.parent == self.mainContext, context != self.mainContext {
                self.saveMainContext(savedMainCallBack: {
                    savedCallBack?()
                })
                return
            }
        }
        
        if context.hasChanges {
            context.perform(saveBlock)
        } else {
            privateQueue.async {
                savedCallBack?()
            }
        }
    }
    
}
