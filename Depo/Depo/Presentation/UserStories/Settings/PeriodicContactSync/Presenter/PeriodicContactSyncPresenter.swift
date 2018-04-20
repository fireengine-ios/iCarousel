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
    
    private let dataSource =  PeriodicContactSyncDataSource()
}

// MARK: - PeriodicContactSyncViewOutput

extension PeriodicContactSyncPresenter: PeriodicContactSyncViewOutput {
    
    func viewIsReady(tableView: UITableView) {
        dataSource.setup(table: tableView)
        dataSource.delegate = self
        
        startAsyncOperationDisableScreen()
        interactor.prepareCellModels()
    }
    
    func saveSettings() {
        interactor.onSave(settings: dataSource.createAutoSyncSettings())
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
    
    func prepaire(syncSettings: PeriodicContactsSyncSettings) {
        completeAsyncOperationEnableScreen()
        dataSource.showCells(from: syncSettings)
    }
    
}

// MARK: - PeriodicContactSyncDataSourceDelegate

extension PeriodicContactSyncPresenter: PeriodicContactSyncDataSourceDelegate {
    
    func onValueChanged() {
        interactor.onSave(settings: dataSource.createAutoSyncSettings())
    }
    
}
