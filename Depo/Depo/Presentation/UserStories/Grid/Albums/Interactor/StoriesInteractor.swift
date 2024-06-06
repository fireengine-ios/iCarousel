//
//  StoriesInteractor.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikov on 15.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StoriesInteractor: BaseFilesGreedInteractor {
    
    private lazy var service = ForYouService()

    override func getAllItems(sortBy: SortedRules) {
        debugLog("StoriesInteractor getAllItems")
        getStories()
    }
    
    private func getStories() {
        service.forYouStories() { [weak self] result in
            switch result {
            case .success(let response):
                var array = [[BaseDataSourceItem]]()
                array.append(response.fileList)
                self?.output.getContentWithSuccess(array: array)
            case .failed(let error):
                debugLog("StoriesInteractor: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    override func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.StoriesScreen())
        analyticsManager.logScreen(screen: .myStories)
        analyticsManager.trackDimentionsEveryClickGA(screen: .myStories)
    }
}
