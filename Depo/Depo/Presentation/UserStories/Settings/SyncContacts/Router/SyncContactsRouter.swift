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
    
    func goToDuplicatedContacts(with analyzeResponse: [ContactSync.AnalyzedContact], moduleOutput: DuplicatedContactsModuleOutput?) {
        let viewController = router.duplicatedContacts(analyzeResponse: analyzeResponse, moduleOutput: moduleOutput)
        router.pushViewController(viewController: viewController)
    }
}
