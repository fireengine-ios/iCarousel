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
    
    var pageSize: Int = 100
    
    private let coreData = CoreDataStack.default
    
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
        guard let lastItem = pageItems.last else {
            compoundedCallback([], [])
            return
        }
        
        
        //
        let requestContext = coreData.newChildBackgroundContext
        
        let request = NSFetchRequest<MediaItem>()
        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                    in: requestContext)
        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
        
        //check in BASE GREED if dataCore still appending, then only time is avilable
        let sortingTypePredicate = getSortingPredicateFirstPage(sortType: sortType, lastItem: lastItem)
        
        let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, sortingTypePredicate])
        request.predicate = compundedPredicate
        
        
        //
        
        
        //pageSize
//       USE // sortByCurrentType // in compoundedCallback
        
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
    
    fileprivate func sortByCurrentType(items: [WrapData], sortType: SortedRules) -> [WrapData] {
        var tempoArray = items
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            tempoArray.sort{$0.creationDate! > $1.creationDate!}
        case .timeDown, .timeDownWithoutSection:
            tempoArray.sort{$0.creationDate! < $1.creationDate!}
        case .lettersAZ, .albumlettersAZ:
            tempoArray.sort{String($0.name!.first!).uppercased() > String($1.name!.first!).uppercased()}
        case .lettersZA, .albumlettersZA:
            tempoArray.sort{String($0.name!.first!).uppercased() < String($1.name!.first!).uppercased()}
        case .sizeAZ:
            tempoArray.sort{$0.fileSize > $1.fileSize}
        case .sizeZA:
            tempoArray.sort{$0.fileSize < $1.fileSize}
        case .metaDataTimeUp:
            tempoArray.sort{$0.metaDate > $1.metaDate}
        case .metaDataTimeDown:
            tempoArray.sort{$0.metaDate < $1.metaDate}
        }
        return tempoArray
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

