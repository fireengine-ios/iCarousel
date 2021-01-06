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

    
    private func compoundItems(pageItems: [WrapData],
                               sortType: SortedRules,
                               predicate: NSCompoundPredicate,
                               compoundedCallback: @escaping CompoundedPageCallback) {
        
        notAllowedMD5s = notAllowedMD5s.union(pageItems.filter{!$0.isLocalItem}.map{$0.md5})
        notAllowedLocalIDs = notAllowedLocalIDs.union(pageItems.map{$0.getTrimmedLocalID()})///there should be no similar UID on BackEnd so this is fine
        
        compoundedCallback(pageItems, [])
    }
    
    func appendNotAllowedItems(items: [Item]) {
        notAllowedMD5s = notAllowedMD5s.union(items.filter{!$0.isLocalItem}.map{$0.md5})
        notAllowedLocalIDs = notAllowedLocalIDs.union(items.map{$0.getTrimmedLocalID()})
    }
    
    func dropData() {
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
                            
                            compoundedCallback(compundedPage, leftovers)
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
                        
                        compoundedCallback(compoundedPage, leftovers)
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
                        guard let self = self else {
                            return
                        }
                        compoundedCallback(compoundedPage, leftovers)
        })
    }
    
    
    
    // MARK: - sorting
    fileprivate func sortByCurrentType(items: [WrapData], sortType: SortedRules) -> [WrapData] {
        return WrapDataSorting.sort(items: items, sortType: sortType)
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
        case .metaDataTimeUp, .timeUp, .timeUpWithoutSection, .lastModifiedTimeUp:
            return NSSortDescriptor(key: "creationDateValue", ascending: false)
        case .metaDataTimeDown, .timeDown, .timeDownWithoutSection, .lastModifiedTimeDown:
            return NSSortDescriptor(key: "creationDateValue", ascending: true)
        }
    }

}

extension PageCompounder: PageSortingPredicates {
    
    func getSortingPredicateMidPage(sortType: SortedRules, firstItem: Item,  lastItem: Item) -> NSPredicate {
        switch sortType {
        case .timeUp, .timeUpWithoutSection, .lastModifiedTimeUp:
            return NSPredicate(format: "creationDateValue >= %@ AND creationDateValue <= %@",
                               (lastItem.creationDate ?? Date()) as NSDate, (firstItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection, .lastModifiedTimeDown:
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
        case .timeUp, .timeUpWithoutSection, .lastModifiedTimeUp:
            return NSPredicate(format: "creationDateValue <= %@", (firstItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection, .lastModifiedTimeDown:
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
        case .timeUp, .timeUpWithoutSection, .lastModifiedTimeUp:
            return NSPredicate(format: "creationDateValue >= %@", (lastItem.creationDate ?? Date()) as NSDate)
        case .timeDown, .timeDownWithoutSection, .lastModifiedTimeDown:
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

