//
//  SyncContactsSyncContactsRouter.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class SyncContactsRouter: SyncContactsRouterInput {
    let router = RouterVC()
    
    func goToConnectedToNetworkFailed() {
        UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
    }
    
    func goToManageContacts(moduleOutput: ManageContactsModuleOutput?) {
        router.pushViewController(viewController: router.manageContacts(moduleOutput: moduleOutput))
    }
    
    func goToDuplicatedContacts(with analyzeResponse: [ContactSync.AnalyzedContact]) {
        let viewController = router.deleteContactDuplicates(analyzeResponse: analyzeResponse)
        router.pushViewController(viewController: viewController)
    }
    
    func goToPremium() {
        router.pushViewController(viewController: router.premium(source: .contactSync))
    }
    
    func showError(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func showFullQuotaPopUp() {
        let popUpType: FullQuotaWarningPopUpType = .contact
        router.showFullQuotaPopUp(popUpType)
    }
}
