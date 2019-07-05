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

final class PageCompounder {
    
    private var notAllowedMD5s = Set<String>()
    private var notAllowedLocalIDs = Set<String>()
    
    var pageSize: Int = NumericConstants.numberOfLocalItemsOnPage
    
    private let coreData = MediaItemOperationsService.shared
    
    private var lastLocalPageAddedAction: AppendingLocalItemsPageAppended?

    
    private func compoundItems(pageItems: [WrapData],
                               sortType: SortedRules,
                               predicate: NSCompoundPredicate,
                               compoundedCallback: @escaping CompoundedPageCallback) {
        
        notAllowedMD5s = notAllowedMD5s.union(pageItems.filter{!$0.isLocalItem}.map{$0.md5})
        notAllowedLocalIDs = notAllowedLocalIDs.union(pageItems.map{$0.getTrimmedLocalID()})///there should be no similar UID on BackEnd so this is fine
        
        let filterPredicate = getFilteringPredicate(md5s: notAllowedMD5s, localIDs: notAllowedLocalIDs)
        
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterPredicate, predicate])
        
        let requestContext = CoreDataStack.default.newChildBackgroundContext
        
        let request = NSFetchRequest<MediaItem>()
        request.entity = NSEntityDescription.entity(forEntityName: MediaItem.Identifier,
                                                    in: requestContext)

            request.fetchLimit = pageSize

        
        request.predicate = compoundedPredicate
        
        request.sortDescriptors = [getSortingDescription(sortingRule: sortType)]
        
        guard let savedLocalals = try? requestContext.fetch(request) else {
            compoundedCallback(pageItems, [])
            return
        }
        
        requestContext.perform { [weak self] in ///for now this will help the reduce possibility for crash - better solution is to return media items in callback which is called inside context
            guard let `self` = self else {
                compoundedCallback(pageItems, [])
                return
            }
            var tempoArray = pageItems
            
            let wrapedLocals = savedLocalals.map{ return WrapData(mediaItem: $0) }
            
            tempoArray.append(contentsOf: wrapedLocals)
            tempoArray = self.sortByCurrentType(items: tempoArray, sortType: sortType)
            
            self.notAllowedLocalIDs = self.notAllowedLocalIDs.union(wrapedLocals.flatMap{$0.getTrimmedLocalID()})
            
            let actualArray = tempoArray.prefix(self.pageSize)
            let leftovers = (tempoArray.count - actualArray.count > 0) ? tempoArray.suffix(from: actualArray.count) : []
            compoundedCallback(Array(actualArray), Array(leftovers))
        }
    }
    
    func appendNotAllowedItems(items: [Item]) {
        notAllowedMD5s = notAllowedMD5s.union(items.filter{!$0.isLocalItem}.map{$0.md5})
        notAllowedLocalIDs = notAllowedLocalIDs.union(items.map{$0.getTrimmedLocalID()})
    }
    
    func dropData() {
        lastLocalPageAddedAction = nil
        notAllowedMD5s.removeAll()
        notAllowedLocalIDs.removeAll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func compoundFirstPage(pageItems: [WrapData],
                           filesType: FileType,
                           sortType: SortedRules,
                           compoundedCallback: @escaping CompoundedPageCallback) {
        
        let fileTypePredicate = NSPredicate(format: "fileTypeValue = %ui", filesType.valueForCoreDataMapping())
        if let lastItem = getLastNonEmpty(items: pageItems, fileType: filesType) {
            let sortingTypePredicate = getSortingPredicateFirstPage(sortType: sortType, lastItem: lastItem)
            let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate, sortingTypePredicate])
            
            compoundItems(pageItems: pageItems,
                          sortType: sortType,
                          predicate: compundedPredicate,
                          compoundedCallback: { [weak self] compundedPage, leftovers in
                            guard let `self` = self else {
                                return
                            }
                            if compundedPage.count < self.pageSize, self.coreData.inProcessAppendingLocalFiles {
                                self.monitorDBLastAppendedPageFirst(lastItem: lastItem,
                                                                    pageItems: compundedPage,
                                                                    sortType: sortType,
                                                                    predicate: compundedPredicate,
                                                                    compoundedCallback: compoundedCallback)
                            } else {
                                compoundedCallback(compundedPage, leftovers)
                            }
                            
            })
            
        } else {
            let compundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fileTypePredicate])
            
            compoundItems(pageItems: pageItems,
                          sortType: sortType,
                          predicate: compundedPredicate,
                          compoundedCallback: compoundedCallback)
        }
    }
    
    private func getLastNonEmpty(items: [WrapData], fileType: FileType) -> WrapData? {
        guard fileType == .video else {
            return items.last
        }
        return items.filter{
            if !$0.isLocalItem {
                return ($0.metaData?.takenDate != nil)
            } else {
                return true
            }
//            return $0.metaData != nil
        }.last
        
    }
    
    func compoundMiddlePage(pageItems: [WrapData],
                            filesType: FileType,
                            sortType: SortedRules,
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
                      compoundedCallback: { [weak self] compoundedPage, leftovers in
                        guard let `self` = self else {
                            return
                        }
                        if compoundedPage.count < self.pageSize, self.coreData.inProcessAppendingLocalFiles {
                            self.monitorDBLastAppendedPageMiddle(firstItem: firstItem, lastItem: lastItem, pageItems: compoundedPage, sortType: sortType, predicate: compundedPredicate, compoundedCallback: compoundedCallback)
                        } else {
                            compoundedCallback(compoundedPage, leftovers)
                        }
        })
    }
    
    func compoundLastPage(pageItems: [WrapData],
                          filesType: FileType,
                          sortType: SortedRules,
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
                      compoundedCallback: { [weak self] compoundedPage, leftovers in
                        guard let `self` = self else {
                            return
                        }
                        if compoundedPage.count < self.pageSize, self.coreData.inProcessAppendingLocalFiles {
                            self.monitorDBLastAppendedPageLast(firstItem: firstItem, pageItems: compoundedPage, sortType: sortType, predicate: compundedPredicate, compoundedCallback: compoundedCallback)
                            return
                            
                        } else {
                           compoundedCallback(compoundedPage, leftovers)
                        }
        })
    }
    
    //MARK: - DB appending
    private func monitorDBLastAppendedPageLast(firstItem: WrapData,
                                        pageItems: [WrapData],
                                           sortType: SortedRules,
                                           predicate: NSCompoundPredicate,
                                           compoundedCallback: @escaping CompoundedPageCallback) {

            lastLocalPageAddedAction = { [weak self] freshlyDBAppendedItems in
            self?.lastLocalPageAddedAction = nil
                
            guard let lastFreshLocalItem = freshlyDBAppendedItems.last,
                lastFreshLocalItem.metaDate <= firstItem.metaDate else {
                    
                    debugPrint("!!!? time for a recurcieve callback loop monitorDBLastAppendedPageLast")
                    
                    self?.compoundItems(pageItems: pageItems,
                                        sortType: sortType,
                                        predicate: predicate,
                                        compoundedCallback: { [weak self] compoundedPage, leftovers  in
                                            guard let `self` = self else {
                                                compoundedCallback(pageItems, [])
                                                return
                                            }
                                            if self.coreData.inProcessAppendingLocalFiles,
                                                compoundedPage.isEmpty {
                                                self.monitorDBLastAppendedPageLast(firstItem: firstItem, pageItems: pageItems, sortType: sortType, predicate: predicate, compoundedCallback: compoundedCallback)
                                                return
                                            } else if !compoundedPage.isEmpty {
                                               ///latesst change
                                                self.compoundItems(pageItems: pageItems,
                                                                    sortType: sortType,
                                                                    predicate: predicate,
                                                                    compoundedCallback: compoundedCallback)
                                            } else {
                                                debugPrint("!!!? monitorDBLastAppendedPageLast last non empty")
                                                compoundedCallback(compoundedPage, leftovers)
                                            }
                                            
                    })
                    
                    return
            }
            debugPrint("!!!? regular callback monitorDBLastAppendedPageLast")
            self?.compoundItems(pageItems: pageItems,
                                sortType: sortType,
                                predicate: predicate,
                                compoundedCallback: { [weak self] compoundedPage, leftovers  in
                                    guard !compoundedPage.isEmpty else {
                                        self?.monitorDBLastAppendedPageLast(firstItem: firstItem, pageItems: pageItems, sortType: sortType, predicate: predicate, compoundedCallback: compoundedCallback)
                                        return
                                    }
                                    debugPrint("!!!? last non empty")
                                    compoundedCallback(compoundedPage, leftovers)
            })
        }
    }
    
    private func monitorDBLastAppendedPageFirst(lastItem: WrapData,
                                           pageItems: [WrapData],
                                           sortType: SortedRules,
                                           predicate: NSCompoundPredicate,
                                           compoundedCallback: @escaping CompoundedPageCallback) {
        
            lastLocalPageAddedAction = { [weak self] freshlyDBAppendedItems in
            self?.lastLocalPageAddedAction = nil
                
            guard let lastFreshLocalItem = freshlyDBAppendedItems.last,
                lastFreshLocalItem.metaDate <= lastItem.metaDate else {
                    guard let `self` = self else {
                        return
                    }
                    guard self.coreData.inProcessAppendingLocalFiles else {
                        self.compoundItems(pageItems: pageItems,
                                           sortType: sortType,
                                           predicate: predicate,
                                           compoundedCallback: compoundedCallback)
                        return
                    }
                    self.monitorDBLastAppendedPageFirst(lastItem: lastItem, pageItems: pageItems, sortType: sortType, predicate: predicate, compoundedCallback: compoundedCallback)
                    return
            }
            debugPrint("!!!? regular callback monitorDBLastAppendedPageFirst")
            self?.compoundItems(pageItems: pageItems,
                                sortType: sortType,
                                predicate: predicate,
                                compoundedCallback: { [weak self] compoundedPage, leftovers  in
                                    
                                    guard !compoundedPage.isEmpty else {
                                        debugPrint("!!!? regular callback monitorDBLastAppendedPageFirst else")
                                        /* or shpuld I use compundedPage.count >= self.pageSize ?*/
                                        self?.monitorDBLastAppendedPageFirst(lastItem: lastItem, pageItems: pageItems, sortType: sortType, predicate: predicate, compoundedCallback: compoundedCallback)
                                        return
                                    }
                                    debugPrint("!!!? first non empty")
                                    compoundedCallback(compoundedPage, leftovers)
            })
        }
    }
    
    private func monitorDBLastAppendedPageMiddle(firstItem: WrapData,
                                                 lastItem: WrapData,
                                           pageItems: [WrapData],
                                           sortType: SortedRules,
                                           predicate: NSCompoundPredicate,
                                           compoundedCallback: @escaping CompoundedPageCallback) {
        
            lastLocalPageAddedAction = { [weak self] freshlyDBAppendedItems in
            self?.lastLocalPageAddedAction = nil
                
            guard let lastFreshLocalItem = freshlyDBAppendedItems.last,
                lastFreshLocalItem.metaDate <= firstItem.metaDate
                else {
                    
                    guard let `self` = self else {
                        return
                    }
                    guard self.coreData.inProcessAppendingLocalFiles else {
                        self.compoundItems(pageItems: pageItems,
                                            sortType: sortType,
                                            predicate: predicate,
                                            compoundedCallback: compoundedCallback)
                        return
                    }
                    self.monitorDBLastAppendedPageMiddle(firstItem: firstItem, lastItem: lastItem, pageItems: pageItems, sortType: sortType, predicate: predicate, compoundedCallback: compoundedCallback)
                    return
            }
            debugPrint("!!!? regular callback monitorDBLastAppendedPageMiddle")
            self?.compoundItems(pageItems: pageItems,
                                sortType: sortType,
                                predicate: predicate,
                                compoundedCallback: { [weak self] compoundedPage, leftovers  in
                                    guard !compoundedPage.isEmpty else {
                                       
                                        debugPrint("!!!? regular callback monitorDBLastAppendedPageMiddle else")
                                        guard let `self` = self else {
                                            return
                                        }
                                        guard self.coreData.inProcessAppendingLocalFiles else {
                                            self.compoundItems(pageItems: pageItems,
                                                               sortType: sortType,
                                                               predicate: predicate,
                                                               compoundedCallback: compoundedCallback)
                                            return
                                        }
                                        self.monitorDBLastAppendedPageMiddle(firstItem: firstItem, lastItem: lastItem, pageItems: pageItems, sortType: sortType, predicate: predicate, compoundedCallback: compoundedCallback)
                                        return
                                    }
                                    debugPrint("!!!? middle non empty")
                                    compoundedCallback(compoundedPage, leftovers)
            })
        }
    }
    
    
    // MARK: - sorting
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
    
    private func getFilteringPredicate(md5s: Set<String>, localIDs: Set<String>, sizeLimit: UInt64 = NumericConstants.fourGigabytes) -> NSCompoundPredicate {
        let md5Predicate = NSPredicate(format:"NOT (md5Value IN %@)", md5s)
        let predicate = NSPredicate(format: "trimmedLocalFileID != Nil AND NOT (trimmedLocalFileID IN %@) AND fileSizeValue < \(sizeLimit)", localIDs)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, md5Predicate])
    }
    
    private func getSortingDescription(sortingRule: SortedRules) -> NSSortDescriptor {
        switch sortingRule {
        case .lettersAZ, .albumlettersAZ:
            return NSSortDescriptor(key: "nameValue", ascending: false)
        case .lettersZA, .albumlettersZA:
            return NSSortDescriptor(key: "nameValue", ascending: true)
        case .sizeAZ:
            return NSSortDescriptor(key: "fileSizeValue", ascending: false)
        case .sizeZA:
            return NSSortDescriptor(key: "fileSizeValue", ascending: true)
        case .metaDataTimeUp, .timeUp, .timeUpWithoutSection:
            return NSSortDescriptor(key: "creationDateValue", ascending: false)
        case .metaDataTimeDown, .timeDown, .timeDownWithoutSection:
            return NSSortDescriptor(key: "creationDateValue", ascending: true)
        }
    }

}

extension PageCompounder: PageSortingPredicates {
    
    func getSortingPredicateMidPage(sortType: SortedRules, firstItem: Item,  lastItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue >= %@ AND creationDateValue <= %@",
                               (lastItem.creationDate ?? Date()) as NSDate, (firstItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue <= %@ AND creationDateValue >= %@", (lastItem.creationDate ?? Date()) as NSDate, (firstItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue >= %@ AND nameValue <= %@",
                               lastItem.name ?? "", firstItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue <= %@ AND nameValue >= %@",
                               lastItem.name ?? "", firstItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue >= %ui AND fileSizeValue <= %ui",
                               lastItem.fileSize, firstItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue <= %ui AND fileSizeValue >= %ui",
                               lastItem.fileSize, firstItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue >= %@ AND creationDateValue <= %@",
                               lastItem.metaDate as NSDate, firstItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue <= %@ AND creationDateValue >= %@",
                               lastItem.metaDate as NSDate, firstItem.metaDate as NSDate)
        }
    }
    
    func getSortingPredicateLastPage(sortType: SortedRules, firstItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue <= %@", (firstItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue >= %@", (firstItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue <= %@", firstItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue >= %@", firstItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue <= %ui", firstItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue >= %ui", firstItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue <= %@", firstItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue >= %@", firstItem.metaDate as NSDate)
        }
    }
    
    func getSortingPredicateFirstPage(sortType: SortedRules, lastItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection:
            return NSPredicate(format: "creationDateValue >= %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection:
            return NSPredicate(format: "creationDateValue <= %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .lettersAZ, .albumlettersAZ:
            return NSPredicate(format: "nameValue >= %@", lastItem.name ?? "")
        case .lettersZA, .albumlettersZA:
            return NSPredicate(format: "nameValue <= %@", lastItem.name ?? "")
        case .sizeAZ:
            return NSPredicate(format: "fileSizeValue >= %ui", lastItem.fileSize)
        case .sizeZA:
            return NSPredicate(format: "fileSizeValue <= %ui", lastItem.fileSize)
        case .metaDataTimeUp:
            return NSPredicate(format: "creationDateValue >= %@", lastItem.metaDate as NSDate)
        case .metaDataTimeDown:
            return NSPredicate(format: "creationDateValue <= %@", lastItem.metaDate as NSDate)
        }
    }
    
}

