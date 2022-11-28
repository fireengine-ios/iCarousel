//
//  CollageInteractor.swift
//  Depo
//
//  Created by Ozan Salman on 28.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class CollageInteractor: BaseFilesGreedInteractor {

    override func getAllItems(sortBy: SortedRules) {
        debugLog("CollageInteractor getAllItems")
        
        guard let remote = remoteItems as? CollageService else {
            return
        }
        remote.allCollage(sortBy: sortBy.sortingRules, sortOrder: sortBy.sortOder, success: { [weak self] collages in
            DispatchQueue.main.async {
                var array = [[BaseDataSourceItem]]()
                array.append(collages)
                self?.output.getContentWithSuccess(array: array)
            }
            }, fail: { [weak self] in
                DispatchQueue.main.async {
                    self?.output.asyncOperationFail(errorMessage: "fail")
                }
        })
    }
    
    override func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.StoriesScreen())
        analyticsManager.logScreen(screen: .myStories)
        analyticsManager.trackDimentionsEveryClickGA(screen: .myStories)
    }
}

