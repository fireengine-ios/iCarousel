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
        
        getCollages()
    }
    
    private func getCollages() {
        debugLog("ForYou getCollages")
        service.forYouCollages() { [weak self] result in
            switch result {
            case .success(let response):
                var array = [[BaseDataSourceItem]]()
                array.append(response.fileList)
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

