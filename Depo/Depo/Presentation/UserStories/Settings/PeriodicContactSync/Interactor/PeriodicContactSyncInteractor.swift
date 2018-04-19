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
    private let localMediaStorage = LocalMediaStorage.default
}

// MARK: - PeriodicContactSyncInteractorInput

extension PeriodicContactSyncInteractor: PeriodicContactSyncInteractorInput {
    
    func prepareCellModels() {
        DispatchQueue.main.async { [weak self] in
            self?.output.prepaire(syncSettings: self.dataStorage.settings)
        }
    }
    
    func onSave(settings: AutoSyncSettings) {
        dataStorage.save(autoSyncSettings: settings)
        SyncServiceManager.shared.update(syncSettings: settings)
    }
    
}
