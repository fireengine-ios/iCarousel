//
//  AutoSyncAutoSyncRouter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncRouter: AutoSyncRouterInput {
 
    func routNextVC() {
        let router = RouterVC()
        router.setNavigationController(controller: router.tabBarScreen)
    }

}
