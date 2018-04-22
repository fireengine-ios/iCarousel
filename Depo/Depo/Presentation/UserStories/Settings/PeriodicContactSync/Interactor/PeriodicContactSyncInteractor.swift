//
//  PeriodicContactSyncInteractor.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Contacts

final class PeriodicContactSyncInteractor {
    weak var output: PeriodicContactSyncInteractorOutput!
    
    private var dataStorage = PeriodicContactSyncDataStorage()
    
    private let contactsService = ContactService()
}

// MARK: - PeriodicContactSyncInteractorInput

extension PeriodicContactSyncInteractor: PeriodicContactSyncInteractorInput {
    
    func prepareCellModels() {
        let settings = dataStorage.settings

        DispatchQueue.main.async { [weak self] in
            self?.output.prepaire(syncSettings: settings)
        }
    }
    
    func onSave(settings: PeriodicContactsSyncSettings) {
        dataStorage.save(periodicContactSyncSettings: settings)
    }
    
    func checkPermission() {
        DispatchQueue.main.async {
            self.contactsService.askPermissionForContactsFramework(redirectToSettings: false, completion: { [weak self] isAccessGranted in
                if isAccessGranted {
                    self?.output.permissionSuccess()
                } else {
                    self?.output.permissionFail()
                }
            })
        }
    }
    
}
