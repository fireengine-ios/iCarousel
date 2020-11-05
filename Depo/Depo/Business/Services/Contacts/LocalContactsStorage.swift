//
//  LocalContactsStorage.swift
//  Depo
//
//  Created by Konstantin Studilin on 05.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import Contacts


enum LocalContactSuggestionSource {
    case name
    case phone
    case email
}


struct SuggestedContact {
    let source: LocalContactSuggestionSource
    let name: String?
    let familyName: String?
    let phones: [String]?
    let emails: [String]?
    
    
    init(with contact: CNContact, source: LocalContactSuggestionSource) {
        self.source = source
        name = contact.givenName
        familyName = contact.familyName
        phones = contact.phoneNumbers.compactMap { $0.value.stringValue }
        emails = contact.emailAddresses.compactMap { $0.value as String }
    }
}


struct LocalContactsStorage {
    static let shared = LocalContactsStorage()
    
    private var cachedContacts = SynchronizedArray<CNContact>()
    
    
    private init() {}
    
    
    func cache(contacts: [CNContact]) {
        cachedContacts.modify { _ in
            return contacts
        }
    }
    
    func getContacts(containing stringToSearch: String) -> [SuggestedContact] {
        var result = [SuggestedContact]()
        cachedContacts.forEach { contact in
            if contact.givenName.contains(stringToSearch) || contact.familyName.contains(stringToSearch)  {
                result.append(SuggestedContact.init(with: contact, source: .name))
                return
            }

            let msisdns = contact.phoneNumbers.compactMap { $0.value }
            if msisdns.first(where: { $0.stringValue.contains(stringToSearch) }) != nil {
                result.append(SuggestedContact.init(with: contact, source: .phone))
                return
            }
            
            let emails = contact.emailAddresses.compactMap { $0.value }
            if emails.first(where: { $0.contains(stringToSearch) }) != nil {
                result.append(SuggestedContact.init(with: contact, source: .email))
                return
            }
        }
        
        return result
    }
}
