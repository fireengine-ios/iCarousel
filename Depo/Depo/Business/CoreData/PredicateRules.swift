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
        
        return NSPredicate(format: "fileTypeValue BETWEEN %@ ", list)
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
        let predicate = NSPredicate(format: "(isLocalItemValue == true) AND trimmedLocalFileID IN %@", list)
        return predicate
    }
    
    // MARK: By favorite staus
    
    var favorite: NSPredicate {
        return NSPredicate(format: "favoritesValue == true")
    }
    
    
    // MARK: By sync status
    
    private static func predicateFromFileType(type: MoreActionsConfig.MoreActionsFileType) -> NSPredicate? {
        return NSPredicate(format: "fileTypeValue == %d", type.convertToFileType().valueForCoreDataMapping() )
    }
    
    private func predicateFromGeneralFilterType(type: GeneralFilesFiltrationType) -> NSPredicate? {
        switch type {
        case .favoriteStatus(.all):
            return nil
        case .favoriteStatus(.favorites):
            return NSPredicate(format: "favoritesValue == true")
        case .favoriteStatus(.notFavorites):
            return NSPredicate(format: "favoritesValue == false")
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
                return NSPredicate(format: "fileTypeValue == %d", specificType.valueForCoreDataMapping())
            }
        case .syncStatus(let syncFlag):
            return NSPredicate(format: "syncStatusValue == %i", syncFlag.valueForCoreDataMapping())
        case .localStatus(let localFlag):
            switch localFlag {
            case .nonLocal:
                return NSPredicate(format: "isLocalItemValue == false")
            case .local:
                return NSPredicate(format: "isLocalItemValue == true")
            case .all:
                return nil
            }
//        case .duplicates:
//            let server = NSPredicate(format: "(isLocalItemValue == false) AND (fileTypeValue == %d)", FileType.image.valueForCoreDataMapping())
//            let serverList = MediaItemOperationsService.shared.executeRequest(predicate: server, context: CoreDataStack.default.mainContext)
//            let list = serverList.map { $0.md5Value }
//            let predicate = NSPredicate(format: "(isLocalItemValue == true) AND md5Value IN %@", list)
//            return predicate
        case .rootFolder(let rootUUID):
            let rootFolderPredicate = NSPredicate(format: "parent = %@", rootUUID)
            return rootFolderPredicate
        case .rootAlbum(let albumUUID):
            let rootAlbumPredicate = NSPredicate(format: "ANY albums.uuid == %@", albumUUID) //LR-2356
            return rootAlbumPredicate
        case .name(let text):
            return NSPredicate(format: "nameValue CONTAINS[cd] %@", text)
        case .parentless:
            let rootFolderPredicate = NSPredicate(format: "(parent == nil OR parent == %@)", "")
            return rootFolderPredicate
        }
    }
    
    func predicate(filters: [GeneralFilesFiltrationType]? = nil) -> NSPredicate? {
        var filtersPredicates: [NSPredicate]?
        filtersPredicates = filters?.compactMap {
            self.predicateFromGeneralFilterType(type: $0)
        }
        
        if let list = filtersPredicates,
            list.count > 0 {
            let fil = NSCompoundPredicate(andPredicateWithSubpredicates: list)
            let fetchTest = NSFetchRequest<MediaItem>(entityName: "MediaItem")
            fetchTest.predicate = fil
            return fil
        }
        
        return nil
    }
    
}
