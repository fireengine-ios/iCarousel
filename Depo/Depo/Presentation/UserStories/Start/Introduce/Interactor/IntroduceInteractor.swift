//
//  IntroduceIntroduceInteractor.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class IntroduceInteractor: IntroduceInteractorInput {

    weak var output: IntroduceInteractorOutput!
    let introduceDataStorage = IntroduceDataStorage()
    private let analyticsManager: AnalyticsService = factory.resolve()
    private lazy var authenticationService = AuthenticationService()

    func trackScreen(pageNum: Int) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.WelcomePage(pageNum: pageNum))
        analyticsManager.logScreen(screen: .welcomePage(pageNum))
    }
    
    func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.LiveCollectRememberScreen())
        analyticsManager.logScreen(screen: .liveCollectRemember)
    }
    
    func signInWithGoogle(with user: GoogleUser) {
    }
}
