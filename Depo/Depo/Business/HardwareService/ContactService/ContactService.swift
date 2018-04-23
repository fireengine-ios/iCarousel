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
        log.debug("ContactService showAccessAlert")
        
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completion(true)
        case .denied:
            completion( false)
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
