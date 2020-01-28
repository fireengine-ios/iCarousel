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
        
        var periodicBackUp: SYNCPeriodic = SYNCPeriodic.none
        
        if settings.isPeriodicContactsSyncOptionEnabled {
            switch settings.timeSetting.option {
            case .daily:
                periodicBackUp = SYNCPeriodic.daily
                MenloworksTagsService.shared.onPeriodicContactSync("daily")
            case .weekly:
                periodicBackUp = SYNCPeriodic.every7
                MenloworksTagsService.shared.onPeriodicContactSync("weekly")
            case .monthly:
                periodicBackUp = SYNCPeriodic.every30
                MenloworksTagsService.shared.onPeriodicContactSync("monthly")
            case .none:
                periodicBackUp = SYNCPeriodic.none
                MenloworksTagsService.shared.onPeriodicContactSync("off")
            }
        } else {
            MenloworksTagsService.shared.onPeriodicContactSync("off")
        }
        
        contactsService.setPeriodicForContactsSync(periodic: periodicBackUp)
    }
    
    func checkPermission() {
        self.contactsService.askPermissionForContactsFramework(redirectToSettings: false, completion: { [weak self] isAccessGranted in
            if isAccessGranted {
                AnalyticsPermissionNetmeraEvent.sendContactPermissionNetmeraEvents(true)
                self?.output.permissionSuccess()
            } else {
                AnalyticsPermissionNetmeraEvent.sendContactPermissionNetmeraEvents(false)
                self?.output.permissionFail()
            }
        })
    }
    
}
