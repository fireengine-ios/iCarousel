//
//  SyncContactsSyncContactsRouterInput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SyncContactsRouterInput {
    func goToConnectedToNetworkFailed()
    func goToManageContacts(moduleOutput: ManageContactsModuleOutput?)
    func goToDuplicatedContacts(with analyzeResponse: [ContactSync.AnalyzedContact], moduleOutput: DuplicatedContactsModuleOutput?)
    func goToPremium()
    func showError(errorMessage: String)
    func showFullQuotaPopUp()
}
