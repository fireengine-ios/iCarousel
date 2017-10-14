//
//  ImportPhotosRouter.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class ImportFromFBRouter: ImportFromFBRouterInput {
    func goToOnboarding(){
        let router = RouterVC()
        router.setNavigationController(controller: router.onboardingScreen)
    }
}

class ImportFromDropboxRouter: ImportFromDropboxRouterInput {
    func goToOnboarding(){
        let router = RouterVC()
        router.setNavigationController(controller: router.onboardingScreen)
    }
}
