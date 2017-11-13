//
//  SortingRules.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 9/20/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

typealias SortingAgregate = (sortDescriptors:[NSSortDescriptor], section:String? )

class CollectionSortingRules {
    
    let rule: SortingAgregate
    
    init(sortingRules : SortedRules) {
        
        switch sortingRules {
        case .lettersAZ:
            rule = CollectionSortingRules.sortByFileName(ascending: true)
            
        case .lettersZA:
            rule = CollectionSortingRules.sortByFileName(ascending: false)
            
        case .timeUp:
            rule = CollectionSortingRules.sortByCreateDate(ascending: false)
            
        case .timeDown:
            rule = CollectionSortingRules.sortByCreateDate(ascending: true)
            
        case .sizeAZ:
            rule = CollectionSortingRules.sortByFileSize(ascending: false)
            
        case .sizeZA:
            rule = CollectionSortingRules.sortByFileSize(ascending: true)
        case .albumlettersAZ, .albumlettersZA:
            rule = CollectionSortingRules.sortByFileSize(ascending: true)//FIXME: albumbs are not currently supported
        }
    }
    
    static func sortByFileName(ascending: Bool) -> SortingAgregate {
        return sorting(sortingFieldName: "nameValue", ascending: ascending, needSepareteBySection: true, sectionFieldName: "fileNameFirstChar")
    }
    
    static func sortByCreateDate(ascending: Bool) -> SortingAgregate {
        return sorting(sortingFieldName: "creationDateValue", ascending: ascending, needSepareteBySection: true, sectionFieldName: "monthValue")
    }
    
    static func sortByFileSize(ascending: Bool) -> SortingAgregate {
        return sorting(sortingFieldName: "fileSizeValue", ascending: ascending)
    }
    
    private static func sorting(sortingFieldName:String, ascending: Bool, needSepareteBySection: Bool = false, sectionFieldName: String? = nil) -> SortingAgregate {
        var array = [NSSortDescriptor]()
        let sortDescr = NSSortDescriptor(key: sortingFieldName, ascending: ascending)
        array.append(sortDescr)
        
        if needSepareteBySection {
            let firstSort = NSSortDescriptor(key: sectionFieldName, ascending: ascending)
            array.insert(firstSort, at: 0)
        }
        
        let sectionName: String? = needSepareteBySection ? sectionFieldName : nil
        return (array, sectionName)
    }
}
