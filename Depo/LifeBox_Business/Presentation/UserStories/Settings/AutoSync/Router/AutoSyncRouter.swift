//
//  AutoSyncAutoSyncRouter.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AutoSyncRouter: AutoSyncRouterInput {
    
    private let router = RouterVC()
 
    func routNextVC() {
        DispatchQueue.toMain {
            self.router.setNavigationController(controller: self.router.tabBarScreen)
        }
    }

}
