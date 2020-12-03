//
//  PrivateShareAnalytics.swift
//  Depo
//
//  Created by Andrei Novikau on 12/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class PrivateShareAnalytics {
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    enum SharedScreen {
        case sharedWithMe
        case sharedByMe
        case whoHasAccess
        case sharedAccess
        case shareInfo
    }
    
    func openAllSharedFiles() {
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .click,
                                            eventLabel: .privateShare(.seeAll))
    }
    
    func trackScreen(_ screen: SharedScreen) {
        let gaScreen: AnalyticsAppScreens
        
        switch screen {
        case .sharedWithMe:
            gaScreen = .sharedWithMe
        case .sharedByMe:
            gaScreen = .sharedByMe
        case .whoHasAccess:
            gaScreen = .whoHasAccess
        case .sharedAccess:
            gaScreen = .sharedAccess
        case .shareInfo:
            gaScreen = .shareInfo
        }
        
        analyticsService.logScreen(screen: gaScreen)
        analyticsService.trackDimentionsEveryClickGA(screen: gaScreen)
    }
    
    func openPrivateShare() {
        analyticsService.trackCustomGAEvent(eventCategory: .sharedFolder,
                                            eventActions: .click,
                                            eventLabel: .privateShare(.privateShare))
    }
    
    func endShare() {
        
    }
}
