//
//  WrapperedItemsSorting.swift
//  Depo
//
//  Created by Oleg on 19.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

typealias Item = WrapData

class WrapperedItemsSorting: NSObject {
    
    func sortingArray(array: [BaseDataSourceItem], bySortingRules: SortedRules, items: @escaping([[BaseDataSourceItem]])->()){
        if ((bySortingRules == SortedRules.timeDown) || (bySortingRules == SortedRules.timeUp)){
            
            sortedArrayUsingTimeRule(array: array, bySortingRyles: bySortingRules, items: { (itemsArray) in
                items(itemsArray)
            })
            
        }else{
            sortedArrayUsingNameRule(array: array, bySortingRyles: bySortingRules, items: { (itemsArray) in
                items(itemsArray)
            })
        }
    }
    
    private func moreActionsConfigTypeByFileType(file: FileType) -> MoreActionsConfig.MoreActionsFileType {
        switch file {
        case .image:
            return .Photo
        case .video:
            return .Video
        case .audio:
            return .Music
        case .folder:
            return .Folder
        case .photoAlbum:
            return .Album
        case .musicPlayList:
            return .None
        case .application:
            return .Docs
        default:
            return .None
        }
    }
    
    func sortingArray(array: [BaseDataSourceItem], bySortingRules: SortedRules, types: [MoreActionsConfig.MoreActionsFileType], items: @escaping([[BaseDataSourceItem]])->()){
        
        var newArray = [BaseDataSourceItem]()
        if (types.count == 0){
            newArray.append(contentsOf: array)
        }else{
            for item in array {
                let type = moreActionsConfigTypeByFileType(file: item.fileType)
                if (types.contains(type)){
                    newArray.append(item)
                }
            }
        }
        
        sortingArray(array: newArray, bySortingRules: bySortingRules) { (sortedArray) in
            items(sortedArray)
        }
    }
    
    func sortingArray(array: [BaseDataSourceItem], bySortingRules: SortedRules, types: [MoreActionsConfig.MoreActionsFileType], syncType: MoreActionsConfig.CellSyncType, items: @escaping([[BaseDataSourceItem]])->()){
        
        var newArray = [BaseDataSourceItem]()
        for item in array {
            switch syncType {
            case .all:
                newArray.append(item)
                break
            case .notSync:
                if (!item.isSynced()){
                    newArray.append(item)
                }
                break
            case .sync:
                if (item.isSynced()){
                    newArray.append(item)
                }
                break
            }
        }
        
        sortingArray(array: newArray, bySortingRules: bySortingRules, types: types) { (sortedArray) in
            items(sortedArray)
        }
    }
    
    /*
     case timeUp
     case timeDown
     case lettersAZ
     case lettersZA
     */
    
    private func sortedArrayUsingTimeRule(array: [BaseDataSourceItem], bySortingRyles: SortedRules, items:@escaping ([[BaseDataSourceItem]])->()){
        DispatchQueue.global(qos: .userInitiated).async {
            var resultArray = [[BaseDataSourceItem]]()
            
            if (array.count > 1){
                
                let sortedArray = array.sorted { (file1, file2) -> Bool in
                    if (bySortingRyles == SortedRules.timeUp){
                        return file1.creationDate! < file2.creationDate!
                    }else{
                        return file1.creationDate! > file2.creationDate!
                    }
                }
                
                var dateArray:[BaseDataSourceItem] = [BaseDataSourceItem]()
                let currentYear = Date().getYear()
                
                let firstObject = sortedArray[0]
                dateArray.append(firstObject)
                var year = firstObject.creationDate!.getYear()
                //var month = firstObject.dateOfCreation.getMonth()
                for i in 1...sortedArray.count - 1{
                    let obj = sortedArray[i]
                    let objYear = obj.creationDate!.getYear()
                    if (objYear != year){
                        resultArray.append(dateArray)
                        dateArray = [BaseDataSourceItem]()
                        dateArray.append(obj)
                        year = obj.creationDate!.getYear()
                        
                    }else{
                        let previousObject = dateArray[dateArray.count - 1]
                        if (currentYear == objYear){
                            if (obj.creationDate!.getMonth() != previousObject.creationDate!.getMonth()){
                                resultArray.append(dateArray)
                                dateArray = [BaseDataSourceItem]()
                                dateArray.append(obj)
                                //month = obj.dateOfCreation.getMonth()
                            }else{
                                dateArray.append(obj)
                            }
                        }else{
                            dateArray.append(obj)
                        }
                    }
                    
                }
                
                resultArray.append(dateArray)
            }else{
                if (array.count > 0){
                    resultArray.append(array)
                }
            }
            DispatchQueue.main.async {
                items(resultArray)
            }
        }
    }
    
    private func getFirsLetter(string: String?) -> Character{
        return string?.uppercased().first ?? " "
    }
    
    private func sortedArrayUsingNameRule(array: [BaseDataSourceItem], bySortingRyles: SortedRules, items:@escaping([[BaseDataSourceItem]])->()){
        DispatchQueue.global(qos: .userInitiated).async {
            var resultArray = [[BaseDataSourceItem]]()
            
            if (array.count > 1){
                
                let sortedArray = array.sorted { (file1, file2) -> Bool in
                    if (bySortingRyles == SortedRules.lettersAZ){
                        return file1.name!.uppercased() < file2.name!.uppercased()
                    }else{
                        return file1.name!.uppercased() > file2.name!.uppercased()
                    }
                }
                
                var dateArray:[BaseDataSourceItem] = [BaseDataSourceItem]()
                
                let firstObject = sortedArray[0]
                dateArray.append(firstObject)
                var letter = self.getFirsLetter(string: firstObject.name)
                for i in 1...sortedArray.count - 1{
                    let obj = sortedArray[i]
                    let currentLetter = self.getFirsLetter(string: obj.name)
                    if (currentLetter != letter){
                        resultArray.append(dateArray)
                        dateArray = [BaseDataSourceItem]()
                        dateArray.append(obj)
                        letter = self.getFirsLetter(string: obj.name)
                    }else{
                        dateArray.append(obj)
                    }
                    
                }
                
                resultArray.append(dateArray)
            }else{
                if (array.count > 0){
                    resultArray.append(array)
                }
            }
            
            DispatchQueue.main.async {
                items(resultArray)
            }
        }
    }
       
    func filterByType(itemsArray:[BaseDataSourceItem], types: [FileType]) -> [BaseDataSourceItem] {
        let array = itemsArray.filter{
            return types.contains($0.fileType)
        }
        return array
    }
    
    func filterSync(items:[BaseDataSourceItem], key: MoreActionsConfig.CellSyncType) -> [BaseDataSourceItem] {
        return items.filter{$0.fileType == .application(.doc) }
    }
    
}
