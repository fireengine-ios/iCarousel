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
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PeriodicContactSync(action: .on, type: .daily))
                periodicBackUp = SYNCPeriodic.daily
            case .weekly:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PeriodicContactSync(action: .on, type: .weekly))
                periodicBackUp = SYNCPeriodic.every7
            case .monthly:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PeriodicContactSync(action: .on, type: .monthly))
                periodicBackUp = SYNCPeriodic.every30
            case .off:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PeriodicContactSync(action: .off, type: nil))
                periodicBackUp = SYNCPeriodic.none
            }
        } else {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.PeriodicContactSync(action: .off, type: nil))
        }
        
        contactsService.setPeriodicForContactsSync(periodic: periodicBackUp)
    }
    
    func checkPermission() {
        self.contactsService.askPermissionForContactsFramework(redirectToSettings: false, completion: { [weak self] isAccessGranted in
            AnalyticsPermissionNetmeraEvent.sendContactPermissionNetmeraEvents(isAccessGranted)
            DispatchQueue.main.async {
                if isAccessGranted {
                    self?.output.permissionSuccess()
                } else {
                    self?.output.permissionFail()
                }
            }
        })
    }
    
}
