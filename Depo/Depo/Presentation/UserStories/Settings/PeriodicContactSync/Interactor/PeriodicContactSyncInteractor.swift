//
//  PeriodicContactSyncInteractor.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PeriodicContactSyncInteractor {
    weak var output: PeriodicContactSyncInteractorOutput!
    
    private var dataStorage = AutoSyncDataStorage()
    private var uniqueUserID: String? = ""
    private let localMediaStorage = LocalMediaStorage.default
    
    private func fail(error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.output.operationFinished()
            self?.output.showError(error: error)
        }
    }
}

// MARK: - PeriodicContactSyncInteractorInput

extension PeriodicContactSyncInteractor: PeriodicContactSyncInteractorInput {
    
    func prepareCellModels() {
        dataStorage.getAutoSyncSettingsForCurrentUser(success: { [weak self] settings, uniqueUserId in
            self?.output.prepaire(syncSettings: settings)
            self?.uniqueUserID = uniqueUserId
        })
    }
    
    func onSave(settings: AutoSyncSettings) {
        dataStorage.save(autoSyncSettings: settings, uniqueUserId: uniqueUserID ?? "")
        SyncServiceManager.shared.update(syncSettings: settings)
    }
    
}
