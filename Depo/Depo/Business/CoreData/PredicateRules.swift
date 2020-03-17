//
//  PredicateList.swift
//  Depo
//
//  Created by Alexander Gurin on 9/10/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import CoreData

class PredicateRules {

    private enum Keys {
        static let albumUUID = "\(#keyPath(MediaItem.albums)).\(#keyPath(MediaItemsAlbum.uuid))"
        static let favoritesValue = #keyPath(MediaItem.favoritesValue)
        static let fileTypeValue = #keyPath(MediaItem.fileTypeValue)
        static let isLocalItemValue = #keyPath(MediaItem.isLocalItemValue)
        static let nameValue = #keyPath(MediaItem.nameValue)
        static let parent = #keyPath(MediaItem.parent)
        static let syncStatusValue = #keyPath(MediaItem.syncStatusValue)
        static let trimmedLocalFileID  = #keyPath(MediaItem.trimmedLocalFileID)
    }
        
// MARK: By file type
    
    var music: NSPredicate {
        return PredicateRules.predicateFromFileType(type: .Music)!
    }
    
    var video: NSPredicate {
        return PredicateRules.predicateFromFileType(type: .Video)!
    }
    
    var image: NSPredicate {
        return PredicateRules.predicateFromFileType(type: .Photo)!
    }
    
    var imageAndVideo: NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [image, video])
    }
    
    var folder: NSPredicate {
        return PredicateRules.predicateFromFileType(type: .Folder)!
    }
    
    var document: NSPredicate {
        
        let start = FileType.application(.unknown).valueForCoreDataMapping() - 1
        let end = FileType.application(.ppt).valueForCoreDataMapping() + 1
        let list = [start, end]
        
        return NSPredicate(format: "\(Keys.fileTypeValue) BETWEEN %@ ", list)
    }
    
    var all: NSPredicate {
        let list = [music, video, image, folder, document]
        return NSCompoundPredicate(andPredicateWithSubpredicates: list)
    }
    
    func allLocalObjectsForObjects(objects: [Item]) -> NSPredicate {
        let serverObjects = objects.filter {
            !$0.isLocalItem
        }
        let list = serverObjects.map { $0.getTrimmedLocalID() }
        let predicate = NSPredicate(format: "\(Keys.isLocalItemValue) = true AND \(Keys.trimmedLocalFileID) IN %@", list)
        return predicate
    }
    
    // MARK: By favorite staus
    
    var favorite: NSPredicate {
        return NSPredicate(format: "\(Keys.favoritesValue) = true")
    }
    
    
    // MARK: By sync status
    
    private static func predicateFromFileType(type: MoreActionsConfig.MoreActionsFileType) -> NSPredicate? {
        return NSPredicate(format: "\(Keys.fileTypeValue) = %d", type.convertToFileType().valueForCoreDataMapping() )
    }
    
    private func predicateFromGeneralFilterType(type: GeneralFilesFiltrationType) -> NSPredicate? {
        switch type {
        case .favoriteStatus(.all):
            return nil
        case .favoriteStatus(.favorites):
            return NSPredicate(format: "\(Keys.favoritesValue) = true")
        case .favoriteStatus(.notFavorites):
            return NSPredicate(format: "\(Keys.favoritesValue) = false")
        case .fileType(let specificType):
            switch specificType {
            case .allDocs:
                let allDocsTypes: [GeneralFilesFiltrationType] =
                    [.fileType(.application(.doc)), .fileType(.application(.txt)),
                     .fileType(.application(.pdf)), .fileType(.application(.xls)),
                     .fileType(.application(.html)), .fileType(.application(.ppt))]
                let predicates = allDocsTypes.flatMap { predicateFromGeneralFilterType(type: $0) }
                return NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
            default:
                return NSPredicate(format: "\(Keys.fileTypeValue) = %d", specificType.valueForCoreDataMapping())
            }
        case .syncStatus(let syncFlag):
            return NSPredicate(format: "\(Keys.syncStatusValue) = %i", syncFlag.valueForCoreDataMapping())
        case .localStatus(let localFlag):
            switch localFlag {
            case .nonLocal:
                return NSPredicate(format: "\(Keys.isLocalItemValue) = false")
            case .local:
                return NSPredicate(format: "\(Keys.isLocalItemValue) = true")
            case .all:
                return nil
            }
//        case .duplicates:
//            let server = NSPredicate(format: "(isLocalItemValue == false) AND (fileTypeValue == %d)", FileType.image.valueForCoreDataMapping())
//            let serverList = MediaItemOperationsService.shared.executeRequest(predicate: server, context: CoreDataStack.shared.mainContext)
//            let list = serverList.map { $0.md5Value }
//            let predicate = NSPredicate(format: "(isLocalItemValue == true) AND md5Value IN %@", list)
//            return predicate
        case .rootFolder(let rootUUID):
            let rootFolderPredicate = NSPredicate(format: "\(Keys.parent) = %@", rootUUID)
            return rootFolderPredicate
        case .rootAlbum(let albumUUID):
            let rootAlbumPredicate = NSPredicate(format: "ANY \(Keys.albumUUID) = %@", albumUUID) //LR-2356
            return rootAlbumPredicate
        case .name(let text):
            return NSPredicate(format: "\(Keys.nameValue) CONTAINS[cd] %@", text)
        case .parentless:
            let rootFolderPredicate = NSPredicate(format: "\(Keys.parent) = nil OR \(Keys.parent) = %@", "")
            return rootFolderPredicate
        }
    }
    
    func predicate(filters: [GeneralFilesFiltrationType]? = nil) -> NSPredicate? {
        let filtersPredicates = filters?.compactMap {
            self.predicateFromGeneralFilterType(type: $0)
        }
        
        guard let list = filtersPredicates, !list.isEmpty else {
            return nil
        }
        
        let fil = NSCompoundPredicate(andPredicateWithSubpredicates: list)
        let fetchTest: NSFetchRequest = MediaItem.fetchRequest()
        fetchTest.predicate = fil
        return fil
    }
    
}
