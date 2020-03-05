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
    
    func goToDuplicatedContacts(with analyzeResponse: [ContactSync.AnalyzedContact], moduleOutput: DuplicatedContactsModuleOutput?) {
        let viewController = router.duplicatedContacts(analyzeResponse: analyzeResponse, moduleOutput: moduleOutput)
        router.pushViewController(viewController: viewController)
    }
    
    func goToPremium() {
        router.pushViewController(viewController: router.premium(title: TextConstants.duplicatedContacts, headerTitle: TextConstants.deleteDuplicatedContactsForPremiumTitle))
        
    }
    
    func showError(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func showFullQuotaPopUp() {
        let popUpType: FullQuotaWarningPopUpType = .contactType
        router.showFullQuotaPopUp(popUpType)
    }
}
