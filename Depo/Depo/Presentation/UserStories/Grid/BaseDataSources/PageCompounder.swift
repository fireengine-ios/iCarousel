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
    func getSortingPredicateLastPage(sortType: SortedRules, firstItem: Item) -> NSPredicate
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
            compoundedCallback(pageItems, [])
            return
        }
        
        var tempoArray = pageItems
        
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
        
        guard let savedLocalals = try? requestContext.fetch(request) else {
            compoundedCallback(pageItems, [])
            return
        }
        if coreData.inProcessAppendingLocalFiles, !savedLocalals.isEmpty,
            !coreData.originalAssetsBeingAppended.assets(afterDate: lastItem.metaDate, mediaType: filesType.convertedToPHMediaType).isEmpty {

                coreData.pageAppendedCallBack = { [weak self]  dbSaveLocals in
                    guard let `self` = self else {
                        compoundedCallback(pageItems, [])//actualy no need for that, cuz class is dead
                        return
                    }
                    self.coreData.pageAppendedCallBack = nil
//                    if let lastSavedObject = dbSaveLocals.last,
//                        lastSavedObject.metaDate < lastItem.metaDate {
                    
                        self.compoundFirstPage(pageItems: pageItems, filesType: filesType, sortType: sortType, notAllowedMD5: notAllowedMD5, notAllowedLocalIDs: notAllowedLocalIDs, compoundedCallback: compoundedCallback)
                        return
//                    } else {
//
//                    }
                }
        }
        
        
        let wrapedLocals = savedLocalals.map{ return WrapData(mediaItem: $0) }
        tempoArray.append(contentsOf: wrapedLocals)
        tempoArray = sortByCurrentType(items: tempoArray, sortType: sortType)
        
        let actualArray = tempoArray.prefix(pageSize)
        let leftoversFirstIndex = (tempoArray.count - actualArray.count > 0) ? actualArray.count : 0
        let leftovers = tempoArray.suffix(from: leftoversFirstIndex)
        compoundedCallback(Array(actualArray), Array(leftovers))
    }
    
    func compoundMiddlePage(pageItems: [WrapData],
                            filesType: FileType, sortType: SortedRules,
                                    notAllowedMD5: [String],
                                    notAllowedLocalIDs: [String],
                                    compoundedCallback:@escaping CompoundedPageCallback) {
        
        guard let lastItem = pageItems.last, let firstItem = pageItems.first else {
            compoundedCallback(pageItems, [])
            return
        }
        
        var tempoArray = pageItems
        
        //
        let requestContext = coreData.newChildBackgroundContext
        
        let request = NSFetchRequest<MediaItem>()
        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                    in: requestContext)
        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
        
        //check in BASE GREED if dataCore still appending, then only time sorting is avilable
        let sortingTypePredicate = getSortingPredicateMidPage(sortType: sortType, firstItem: firstItem, lastItem: lastItem)
        
        let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, sortingTypePredicate])
        request.predicate = compundedPredicate
        
        guard let savedLocalals = try? requestContext.fetch(request), !savedLocalals.isEmpty else {
            compoundedCallback(pageItems, [])
            return
        }
        //
        if coreData.inProcessAppendingLocalFiles, !savedLocalals.isEmpty,
            !coreData.originalAssetsBeingAppended.assets(afterDate: lastItem.metaDate, mediaType: filesType.convertedToPHMediaType).isEmpty {
            
            coreData.pageAppendedCallBack = { [weak self]  dbSaveLocals in
                guard let `self` = self else {
                    compoundedCallback(pageItems, [])//actualy no need for that, cuz class is dead
                    return
                }
                self.coreData.pageAppendedCallBack = nil
                //                    if let lastSavedObject = dbSaveLocals.last,
                //                        lastSavedObject.metaDate < lastItem.metaDate {
                
                self.compoundMiddlePage(pageItems: pageItems, filesType: filesType, sortType: sortType, notAllowedMD5: notAllowedMD5, notAllowedLocalIDs: notAllowedLocalIDs, compoundedCallback: compoundedCallback)
                return
                //                    } else {
                //
                //                    }
            }
        }
        //
        let wrapedLocals = savedLocalals.map{ return WrapData(mediaItem: $0) }
        tempoArray.append(contentsOf: wrapedLocals)
        tempoArray = sortByCurrentType(items: tempoArray, sortType: sortType)
        
        let actualArray = tempoArray.prefix(pageSize)
        let leftoversFirstIndex = (tempoArray.count - actualArray.count > 0) ? actualArray.count : 0
        let leftovers = tempoArray.suffix(from: leftoversFirstIndex)
        compoundedCallback(Array(actualArray), Array(leftovers))
    }
    
    func compoundLastPage(pageItems: [WrapData],
                          filesType: FileType, sortType: SortedRules,
                                  notAllowedMD5: [String],
                                  notAllowedLocalIDs: [String],
                                  compoundedCallback:@escaping CompoundedPageCallback) {
        
        guard let firstItem = pageItems.first else {
            compoundedCallback(pageItems, [])
            return
        }
        
        var tempoArray = pageItems
        
        //
        let requestContext = coreData.newChildBackgroundContext
        
        let request = NSFetchRequest<MediaItem>()
        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                    in: requestContext)
        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
        
        //check in BASE GREED if dataCore still appending, then only time is avilable
        let sortingTypePredicate = getSortingPredicateLastPage(sortType: sortType, firstItem: firstItem)
        
        let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, sortingTypePredicate])
        request.predicate = compundedPredicate
        
        guard let savedLocalals = try? requestContext.fetch(request), !savedLocalals.isEmpty else {
            compoundedCallback(pageItems, [])
            return
        }
        
        //
        if coreData.inProcessAppendingLocalFiles, !savedLocalals.isEmpty,
            !coreData.originalAssetsBeingAppended.assets(afterDate: firstItem.metaDate, mediaType: filesType.convertedToPHMediaType).isEmpty {
            
            coreData.pageAppendedCallBack = { [weak self]  dbSaveLocals in
                guard let `self` = self else {
                    compoundedCallback(pageItems, [])//actualy no need for that, cuz class is dead
                    return
                }
                self.coreData.pageAppendedCallBack = nil
                //                    if let lastSavedObject = dbSaveLocals.last,
                //                        lastSavedObject.metaDate < lastItem.metaDate {
                
                self.compoundLastPage(pageItems: pageItems, filesType: filesType, sortType: sortType, notAllowedMD5: notAllowedMD5, notAllowedLocalIDs: notAllowedLocalIDs, compoundedCallback: compoundedCallback)
                return
                //                    } else {
                //
                //                    }
            }
        }
        //
        
        let wrapedLocals = savedLocalals.map{ return WrapData(mediaItem: $0) }
        tempoArray.append(contentsOf: wrapedLocals)
        tempoArray = sortByCurrentType(items: tempoArray, sortType: sortType)
        
        let actualArray = tempoArray.prefix(pageSize)
        let leftoversFirstIndex = (tempoArray.count - actualArray.count > 0) ? actualArray.count : 0
        let leftovers = tempoArray.suffix(from: leftoversFirstIndex)
        compoundedCallback(Array(actualArray), Array(leftovers))
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
    
    func getSortingPredicateLastPage(sortType: SortedRules, firstItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue < %@", (firstItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue > %@", (firstItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue < %@", firstItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue > %@", firstItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue < %ui", firstItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue > %ui", firstItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue < %@", firstItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue > %@", firstItem.metaDate as NSDate)
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

