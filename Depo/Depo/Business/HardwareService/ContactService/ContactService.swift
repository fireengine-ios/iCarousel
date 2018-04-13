//
//  ContactService.swift
//  Depo
//
//  Created by  Harbros on 13/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Contacts

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
    
}
