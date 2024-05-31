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

    override func getAllItems(sortBy: SortedRules) {
        debugLog("CollageInteractor getAllItems")
        
        getCollages(sortBy: sortBy)
    }
    
    private func getCollages(sortBy: SortedRules) {
        debugLog("ForYou getCollages")
        service.forYouCollages() { [weak self] result in
            switch result {
            case .success(let response):
                var array = [[BaseDataSourceItem]]()
                var sortedList: [BaseDataSourceItem] = response.fileList
                var wrapData: [WrapData] = response.fileList as? [WrapData] ?? []
                
                switch sortBy {
                case .lettersAZ:
                    sortedList.sort { (item1: BaseDataSourceItem, item2: BaseDataSourceItem) -> Bool in
                        (item1.name ?? "") < (item2.name ?? "")
                    }
                case .lettersZA:
                    sortedList.sort { (item1: BaseDataSourceItem, item2: BaseDataSourceItem) -> Bool in
                        (item1.name ?? "") > (item2.name ?? "")
                    }
                case .timeUp:
                    sortedList.sort { (item1: BaseDataSourceItem, item2: BaseDataSourceItem) -> Bool in
                        (item1.creationDate ?? Date.distantPast) < (item2.creationDate ?? Date.distantPast)
                    }
                case .timeDown:
                    sortedList.sort { (item1: BaseDataSourceItem, item2: BaseDataSourceItem) -> Bool in
                        (item1.creationDate ?? Date.distantPast) > (item2.creationDate ?? Date.distantPast)
                    }
                case .sizeAZ:
                    wrapData.sort { (item1: WrapData, item2: WrapData) -> Bool in
                        item1.fileSize < item2.fileSize
                    }
                    sortedList = wrapData
                case .sizeZA:
                    wrapData.sort { (item1: WrapData, item2: WrapData) -> Bool in
                        item1.fileSize > item2.fileSize
                    }
                    sortedList = wrapData
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

