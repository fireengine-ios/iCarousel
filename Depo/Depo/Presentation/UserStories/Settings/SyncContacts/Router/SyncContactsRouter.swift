//
//  SyncContactsSyncContactsRouter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SyncContactsRouter: SyncContactsRouterInput {
    let router = RouterVC()
    
    func goToManageContacts() {
        router.pushViewController(viewController: router.manageContacts)
    }
}
