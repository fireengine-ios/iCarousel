//
//  ContactService.swift
//  Depo
//
//  Created by  Harbros on 13/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Contacts

typealias ContactsLibraryGranted = (_ granted: Bool) -> Void

final class ContactService {
    
    private let passcodeStorage: PasscodeStorage = factory.resolve()
    

    func getContactsCount() -> Int? {
        let contactStore = CNContactStore()
        var contactsCount: Int = 0
        let contactFetchRequest = CNContactFetchRequest(keysToFetch: [])
        do {
            try contactStore.enumerateContacts(with: contactFetchRequest) { (contact, error) in
                contactsCount += 1
            }
        } catch {
            return nil
        }
        
        return contactsCount
    }
    
    func askPermissionForContactsFramework(redirectToSettings: Bool, completion: @escaping ContactsLibraryGranted) {
        debugLog("ContactService showAccessAlert")
        
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completion(true)
            
        case .denied:
            completion(false)
            
        case .restricted, .notDetermined:
            passcodeStorage.systemCallOnScreen = true
            
            store.requestAccess(for: .contacts) { [weak self] granted, error in
                self?.passcodeStorage.systemCallOnScreen = false
                
                if granted {
                    completion(true)
                } else if redirectToSettings {
                    self?.showSettingsAlert(completionHandler: completion)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func showSettingsAlert(completionHandler: @escaping ContactsLibraryGranted) {
        let controller = PopUpController.with(title: nil,
                                              message: TextConstants.settingsContactsPermissionDeniedMessage,
                                              image: .none,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              firstAction: { vc in
                                                vc.close { completionHandler(false) }
        },
                                              secondAction: { vc in
                                                vc.close { completionHandler(false) }
                                                UIApplication.shared.openSettings()
        })
        
        DispatchQueue.toMain {
            RouterVC().presentViewController(controller: controller, animated: false)
        }
    }
    
    func setPeriodicForContactsSync(periodic: SYNCPeriodic) {
        SyncSettings.shared().periodicBackup = periodic
    }
}
