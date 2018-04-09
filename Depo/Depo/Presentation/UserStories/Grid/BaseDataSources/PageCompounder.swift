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
    
    private var notAllowedMD5s = Set<String>()
    private var notAllowedLocalIDs = Set<String>()
    
    var pageSize: Int = NumericConstants.numberOfLocalItemsOnPage
    
    private let coreData = CoreDataStack.default
    
    private func compoundItems(pageItems: [WrapData],
                               sortType: SortedRules,
                               predicate: NSCompoundPredicate,
                               compoundedCallback: @escaping CompoundedPageCallback) {
        
        notAllowedMD5s = notAllowedMD5s.union(pageItems.map{$0.md5})
        notAllowedLocalIDs = notAllowedLocalIDs.union(pageItems.map{$0.getUUIDAsLocal()})///there should be no similar UID on BackEnd so this is fine
        
        
        let filterPredicate = getFilteringPredicate(md5s: notAllowedMD5s, localIDs: notAllowedLocalIDs)
        
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, predicate])
        
        let requestContext = coreData.newChildBackgroundContext
        
        let request = NSFetchRequest<MediaItem>()
        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                    in: requestContext)
        request.fetchLimit = pageSize
        
        request.predicate = compoundedPredicate
        
        guard let savedLocalals = try? requestContext.fetch(request) else {
            compoundedCallback(pageItems, [])
            return
        }

        var tempoArray = pageItems
        
        let wrapedLocals = savedLocalals.map{ return WrapData(mediaItem: $0) }
        tempoArray.append(contentsOf: wrapedLocals)
        tempoArray = sortByCurrentType(items: tempoArray, sortType: sortType)
        
        notAllowedLocalIDs = notAllowedLocalIDs.union(wrapedLocals.compactMap{$0.asset?.localIdentifier})
        
        let actualArray = tempoArray.prefix(pageSize)
        let leftovers = (tempoArray.count - actualArray.count > 0) ? tempoArray.suffix(from: actualArray.count) : []
        compoundedCallback(Array(actualArray), Array(leftovers))
        
    }
    
    func dropData() {
        notAllowedMD5s.removeAll()
        notAllowedLocalIDs.removeAll()
    }
    
    func compoundFirstPage(pageItems: [WrapData],
                           filesType: FileType, sortType: SortedRules,
                                   compoundedCallback: @escaping CompoundedPageCallback) {
        guard let lastItem = pageItems.last else {
            compoundedCallback(pageItems, [])
            return
        }
        
        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
        let sortingTypePredicate = getSortingPredicateFirstPage(sortType: sortType, lastItem: lastItem)
        let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, sortingTypePredicate])

        compoundItems(pageItems: pageItems,
                      sortType: sortType,
                      predicate: compundedPredicate,
                      compoundedCallback: compoundedCallback)
    }
    
    func compoundMiddlePage(pageItems: [WrapData],
                            filesType: FileType, sortType: SortedRules,
                                    compoundedCallback: @escaping CompoundedPageCallback) {
        guard let lastItem = pageItems.last, let firstItem = pageItems.first else {
            compoundedCallback(pageItems, [])
            return
        }
        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
        let sortingTypePredicate = getSortingPredicateMidPage(sortType: sortType, firstItem: firstItem, lastItem: lastItem)
        let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, sortingTypePredicate])
        compoundItems(pageItems: pageItems,
                      sortType: sortType,
                      predicate: compundedPredicate,
                      compoundedCallback: compoundedCallback)
        //
//        if coreData.inProcessAppendingLocalFiles, !savedLocalals.isEmpty,
//            !coreData.originalAssetsBeingAppended.assets(afterDate: lastItem.metaDate, mediaType: filesType.convertedToPHMediaType).isEmpty {
//
//            coreData.pageAppendedCallBack = { [weak self]  dbSaveLocals in
//                guard let `self` = self else {
//                    compoundedCallback(pageItems, [])//actualy no need for that, cuz class is dead
//                    return
//                }
//                self.coreData.pageAppendedCallBack = nil
//                //                    if let lastSavedObject = dbSaveLocals.last,
//                //                        lastSavedObject.metaDate < lastItem.metaDate {
//
//                self.compoundMiddlePage(pageItems: pageItems, filesType: filesType, sortType: sortType, notAllowedMD5: notAllowedMD5, notAllowedLocalIDs: notAllowedLocalIDs, compoundedCallback: compoundedCallback)
//                return
//                //                    } else {
//                //
//                //                    }
//            }
//        }
    }
    
    func compoundLastPage(pageItems: [WrapData],
                          filesType: FileType, sortType: SortedRules,
                          dropFirst: Bool = false,
                                  compoundedCallback: @escaping CompoundedPageCallback) {
        var tempoArray = pageItems
        guard let firstItem = pageItems.first else {
            compoundedCallback(pageItems, [])
            return
        }
        if dropFirst {
            tempoArray.removeFirst()
        }
        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
        
        let sortingTypePredicate = getSortingPredicateLastPage(sortType: sortType, firstItem: firstItem)
        let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, sortingTypePredicate])
        compoundItems(pageItems: tempoArray,
                      sortType: sortType,
                      predicate: compundedPredicate,
                      compoundedCallback: compoundedCallback)
//        guard let savedLocalals = try? requestContext.fetch(request), !savedLocalals.isEmpty else {
//
//            if coreData.inProcessAppendingLocalFiles,
//                !coreData.originalAssetsBeingAppended.assets(afterDate: firstItem.metaDate, mediaType: filesType.convertedToPHMediaType).isEmpty {
//
//                coreData.pageAppendedCallBack = { [weak self]  dbSaveLocals in
//                    guard let `self` = self else {
//                        compoundedCallback(pageItems, [])//actualy no need for that, cuz class is dead
//                        return
//                    }
//                    self.coreData.pageAppendedCallBack = nil
//                    //                    if let lastSavedObject = dbSaveLocals.last,
//                    //                        lastSavedObject.metaDate < lastItem.metaDate {
//
//                    self.compoundLastPage(pageItems: pageItems, filesType: filesType, sortType: sortType, notAllowedMD5: notAllowedMD5, notAllowedLocalIDs: notAllowedLocalIDs, compoundedCallback: compoundedCallback)
//                    return
//                    //                    } else {
//                    //
//                    //                    }
//                }
//            } else if firstItem.isLocalItem {
//                compoundedCallback([], [])
//            } else {
//                compoundedCallback(pageItems, [])
//            }
////            compoundedCallback(pageItems, [])
//            return
//        }
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
    
    private func getFilteringPredicate(md5s: Set<String>, localIDs: Set<String>) -> NSCompoundPredicate {
        let md5Predicate = NSPredicate(format:"NOT (md5Value IN %@)", md5s)
        let predicate = NSPredicate(format: "localFileID != Nil AND NOT (localFileID IN %@)", localIDs)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, md5Predicate])
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

