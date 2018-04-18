//
//  PeriodicContactSyncPresenter.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PeriodicContactSyncPresenter: BasePresenter {
    
    weak var view: PeriodicContactSyncViewInput?
    var interactor: PeriodicContactSyncInteractorInput!
    var router: PeriodicContactSyncRouter!
}

// MARK: - PeriodicContactSyncViewOutput

extension PeriodicContactSyncPresenter: PeriodicContactSyncViewOutput {
    
    func viewIsReady() {
        startAsyncOperationDisableScreen()
        interactor.prepareCellModels()
    }
    
    func save(settings: AutoSyncSettings) {
        interactor.onSave(settings: settings)
    }
    
}

// MARK: - PeriodicContactSyncInteractorOutput

extension PeriodicContactSyncPresenter: PeriodicContactSyncInteractorOutput {
    
    func operationFinished() {
        view?.stopActivityIndicator()
    }
    
    func showError(error: String) {
        UIApplication.showErrorAlert(message: error)
    }
    
    func prepaire(syncSettings: AutoSyncSettings) {
        completeAsyncOperationEnableScreen()
        view?.prepaire(syncSettings: syncSettings)
    }
    
}
