//
//  AnimationInteractor.swift
//  Depo
//
//  Created by Ozan Salman on 29.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class AnimationInteractor: BaseFilesGreedInteractor {
    
    private lazy var service = ForYouService()

    override func getAllItems(sortBy: SortedRules) {
        debugLog("AnimationInteractor getAllItems")
        
        getAnimation()
    }
    
    private func getAnimation() {
        debugLog("ForYou getAnimation")
        service.forYouAnimations() { [weak self] result in
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
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.AnimationsScreen())
        analyticsManager.logScreen(screen: .myAnimations)
        analyticsManager.trackDimentionsEveryClickGA(screen: .myAnimations)
    }
}
