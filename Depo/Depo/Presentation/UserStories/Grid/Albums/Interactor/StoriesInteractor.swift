//
//  StoriesInteractor.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikov on 15.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StoriesInteractor: BaseFilesGreedInteractor {

    override func getAllItems(sortBy: SortedRules) {
        debugLog("StoriesInteractor getAllItems")
        
        guard let remote = remoteItems as? StoryService else {
            return
        }
        remote.allStories(sortBy: sortBy.sortingRules, sortOrder: sortBy.sortOder, success: { [weak self] stories in
            debugLog("StoriesInteractor getAllItems StoryService allStories success")
            
            DispatchQueue.main.async {
                var array = [[BaseDataSourceItem]]()
                array.append(stories)
                self?.output.getContentWithSuccess(array: array)
            }
            }, fail: { [weak self] in
                debugLog("StoriesInteractor getAllItems StoryService allStories fail")
                
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
