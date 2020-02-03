//
//  HelpAndSupportHelpAndSupportInteractor.swift
//  Depo
//
//  Created by Oleg on 12/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class HelpAndSupportInteractor: HelpAndSupportInteractorInput {

    weak var output: HelpAndSupportInteractorOutput!
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.FAQScreen())
        analyticsManager.logScreen(screen: .FAQ)
        analyticsManager.trackDimentionsEveryClickGA(screen: .FAQ)
    }
}
