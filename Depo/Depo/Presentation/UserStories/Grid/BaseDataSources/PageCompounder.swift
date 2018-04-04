//
//  PageCompounder.swift
//  Depo
//
//  Created by Aleksandr on 4/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

typealias CompoundedPageCallback = (_ compundedPage: [WrapData], _ leftoversRemotes: [WrapData])->Void

fileprivate protocol PageSortingPredicates {
    func getSortingPredicateMidPage(sortType: SortedRules, firstItem: Item,  lastItem: Item) -> NSPredicate
    func getSortingPredicateLastPage(sortType: SortedRules, lastItem: Item) -> NSPredicate
    func getSortingPredicateFirstPage(sortType: SortedRules, lastItem: Item) -> NSPredicate
}

class PageCompounder {
    
    let coreData = CoreDataStack.default
    
    private func compoundItems(pageItems: [WrapData],
                       notAllowedMD5: [String],
                       notAllowedLocalIDs: [String],
                       compoundedCallback:@escaping CompoundedPageCallback) {
        let requestContext = coreData.newChildBackgroundContext
        
        let request = NSFetchRequest<MediaItem>()
        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                    in: requestContext)
        
        
     
        
    }
    
    func compoundFirstPage(pageItems: [WrapData],
                           filesType: FileType, sortType: SortedRules,
                                   notAllowedMD5: [String],
                                   notAllowedLocalIDs: [String],
                                   compoundedCallback:@escaping CompoundedPageCallback) {
        
        
    }
    
    func compoundMiddlePage(pageItems: [WrapData],
                            filesType: FileType, sortType: SortedRules,
                                    notAllowedMD5: [String],
                                    notAllowedLocalIDs: [String],
                                    compoundedCallback:@escaping CompoundedPageCallback) {
        
        
    }
    
    func compoundLastPage(pageItems: [WrapData],
                          filesType: FileType, sortType: SortedRules,
                                  notAllowedMD5: [String],
                                  notAllowedLocalIDs: [String],
                                  compoundedCallback:@escaping CompoundedPageCallback) {
        
        
    }
    
    func getLocalFilesForPhotoVideoPage(filesType: FileType, sortType: SortedRules,
                                        paginationEnd: Bool,
                                        firstPage: Bool,
                                        pageRemoteItems: [Item],
                                        notAllowedMD5: [String],
                                        notAllowedLocalIDs: [String],
                                        filesCallBack: @escaping LocalFilesCallBack) {
    
    
    
    }
    
}

extension PageCompounder: PageSortingPredicates {
    
    func getSortingPredicateMidPage(sortType: SortedRules, firstItem: Item,  lastItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue > %@ AND creationDateValue < %@",
                               (lastItem.creationDate ?? Date()) as NSDate, (firstItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue < %@ AND creationDateValue > %@", (lastItem.creationDate ?? Date()) as NSDate, (firstItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue > %@ AND nameValue < %@",
                               lastItem.name ?? "", firstItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue < %@ AND nameValue > %@",
                               lastItem.name ?? "", firstItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue > %ui AND fileSizeValue < %ui",
                               lastItem.fileSize, firstItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue < %ui AND fileSizeValue > %ui",
                               lastItem.fileSize, firstItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue > %@ AND creationDateValue < %@",
                               lastItem.metaDate as NSDate, firstItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue < %@ AND creationDateValue > %@",
                               lastItem.metaDate as NSDate, firstItem.metaDate as NSDate)
        }
    }
    
    func getSortingPredicateLastPage(sortType: SortedRules, lastItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue < %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue > %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue < %@", lastItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue > %@", lastItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue < %ui", lastItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue > %ui", lastItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue < %@", lastItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue > %@", lastItem.metaDate as NSDate)
        }
    }
    
    func getSortingPredicateFirstPage(sortType: SortedRules, lastItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue > %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue < %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue > %@", lastItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue < %@", lastItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue > %ui", lastItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue < %ui", lastItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue > %@", lastItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue < %@", lastItem.metaDate as NSDate)
        }
    }
    
}

