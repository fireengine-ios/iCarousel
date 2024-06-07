//
//  CollageInteractor.swift
//  Depo
//
//  Created by Ozan Salman on 28.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class CollageInteractor: BaseFilesGreedInteractor {
    
    private lazy var service = ForYouService()
    private var isLoading = false

    override func getAllItems(sortBy: SortedRules) {
        debugLog("CollageInteractor getAllItems")
        
        getCollages(sortBy: sortBy)
    }
    
    private func getCollages(sortBy: SortedRules) {
        
        guard !isLoading else { return }
        
        isLoading = true
        
        debugLog("ForYou getCollages")
        
        service.forYouCollages() { [weak self] result in
            
            defer { self?.isLoading = false }
            
            switch result {
            case .success(let response):
                var array = [[BaseDataSourceItem]]()
                var sortedList: [BaseDataSourceItem] = response.fileList
                var wrapData: [WrapData] = response.fileList as? [WrapData] ?? []
                
                switch sortBy {
                case .lettersAZ:
                    sortedList.sort { (item1: BaseDataSourceItem, item2: BaseDataSourceItem) -> Bool in
                        let name1 = item1.name ?? ""
                        let name2 = item2.name ?? ""
                        
                        if name1.isEmpty && !name2.isEmpty {
                            return false
                        } else if !name1.isEmpty && name2.isEmpty {
                            return true
                        } else {
                            let firstCharacter1 = name1.prefix(1)
                            let firstCharacter2 = name2.prefix(1)
                            
                            if firstCharacter1.rangeOfCharacter(from: .letters) != nil && firstCharacter2.rangeOfCharacter(from: .letters) == nil {
                                return true
                            } else if firstCharacter1.rangeOfCharacter(from: .letters) == nil && firstCharacter2.rangeOfCharacter(from: .letters) != nil {
                                return false
                            } else {
                                return name1 < name2
                            }
                        }
                    }
                case .lettersZA:
                    sortedList.sort { (item1: BaseDataSourceItem, item2: BaseDataSourceItem) -> Bool in
                        let name1 = item1.name ?? ""
                        let name2 = item2.name ?? ""
                        
                        if name1.isEmpty && !name2.isEmpty {
                            return true
                        } else if !name1.isEmpty && name2.isEmpty {
                            return false
                        } else {
                            let firstCharacter1 = name1.prefix(1)
                            let firstCharacter2 = name2.prefix(1)
                            
                            if firstCharacter1.rangeOfCharacter(from: .letters) != nil && firstCharacter2.rangeOfCharacter(from: .letters) == nil {
                                return false
                            } else if firstCharacter1.rangeOfCharacter(from: .letters) == nil && firstCharacter2.rangeOfCharacter(from: .letters) != nil {
                                return true
                            } else {
                                return name1 > name2
                            }
                        }
                    }
                case .timeUp:
                    sortedList.sort { (item1: BaseDataSourceItem, item2: BaseDataSourceItem) -> Bool in
                        (item1.creationDate ?? Date.distantPast) > (item2.creationDate ?? Date.distantPast)
                    }
                case .timeDown:
                    sortedList.sort { (item1: BaseDataSourceItem, item2: BaseDataSourceItem) -> Bool in
                        (item1.creationDate ?? Date.distantPast) < (item2.creationDate ?? Date.distantPast)
                    }
                case .sizeAZ:
                    wrapData.sort { (item1: WrapData, item2: WrapData) -> Bool in
                        item1.fileSize > item2.fileSize
                    }
                    sortedList = wrapData as [BaseDataSourceItem]
                case .sizeZA:
                    wrapData.sort { (item1: WrapData, item2: WrapData) -> Bool in
                        item1.fileSize < item2.fileSize
                    }
                    sortedList = wrapData as [BaseDataSourceItem]
                case .albumlettersAZ, .albumlettersZA, .metaDataTimeUp, .metaDataTimeDown, .lastModifiedTimeUp, .lastModifiedTimeDown, .timeUpWithoutSection, .timeDownWithoutSection:
                    break
                }
                
                array.append(sortedList)
                self?.output.getContentWithSuccess(array: array)
            case .failed:
                break
            }
        }
    }


    
    override func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.CollagesScreen())
        analyticsManager.logScreen(screen: .myCollages)
        analyticsManager.trackDimentionsEveryClickGA(screen: .myCollages)
    }
}

