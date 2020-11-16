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


struct SuggestedContact: Equatable {
    let source: LocalContactSuggestionSource
    let name: String
    let familyName: String
    let phones: [String]
    let emails: [String]
    let isLocal: Bool
    
    var displayName: String {
        if !name.isEmpty, !familyName.isEmpty {
            return "\(name) \(familyName)"
        } else if !name.isEmpty {
            return name
        } else {
            return familyName
        }
    }
    
    init(with contact: CNContact, source: LocalContactSuggestionSource) {
        self.source = source
        name = contact.givenName
        familyName = contact.familyName
        phones = contact.phoneNumbers.compactMap { $0.value.stringValue }
        emails = contact.emailAddresses.compactMap { $0.value as String }
        isLocal = true
    }
    
    init(with contact: SuggestedApiContact, names: LocalContactNames = ("", "")) {
        source = .phone
        name = names.givenName
        familyName = names.familyName
        
        if let phone = contact.username {
            phones = [phone]
        } else {
            phones = []
        }
        
        if let email = contact.email {
            emails = [email]
        } else {
            emails = []
        }
        
        isLocal = false
    }
}

typealias LocalContactNames = (givenName: String, familyName: String)

struct LocalContactsStorage {
    static let shared = LocalContactsStorage()
    
    private var cachedContacts = SynchronizedArray<CNContact>()
    private let maxNumberOfCompareDigits = 10
    
    private init() {}
    
    
    func cache(contacts: [CNContact]) {
        cachedContacts.modify { _ in
            return contacts
        }
    }
    
    func getContacts(containing stringToSearch: String) -> [SuggestedContact] {
        var result = [SuggestedContact]()
        let lowercasedString = stringToSearch.lowercased()
        cachedContacts.forEach { contact in
            if contact.givenName.lowercased().contains(lowercasedString) || contact.familyName.lowercased().contains(lowercasedString)  {
                result.append(SuggestedContact(with: contact, source: .name))
                return
            }
            
            let displayNameWithoutWhitespaces = "\(contact.givenName)\(contact.familyName)".lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if displayNameWithoutWhitespaces.contains(lowercasedString) {
                result.append(SuggestedContact(with: contact, source: .name))
                return
            }

            let msisdns = contact.phoneNumbers.compactMap { $0.value }
            if msisdns.first(where: { $0.stringValue.digits.contains(stringToSearch.digits) }) != nil {
                result.append(SuggestedContact(with: contact, source: .phone))
                return
            }
            
            let emails = contact.emailAddresses.compactMap { $0.value.lowercased }
            if emails.first(where: { $0.contains(stringToSearch.lowercased()) }) != nil {
                result.append(SuggestedContact(with: contact, source: .email))
                return
            }
        }
        
        return result
    }
    
    func getContactName(for phone: String, email: String) -> LocalContactNames {
        var searchContact: CNContact?
        let lowercasedEmail = email.lowercased()
        let searchPhone = phone.digits.suffix(maxNumberOfCompareDigits)
            
        cachedContacts.forEach { contact in
            let msisdns = contact.phoneNumbers.compactMap { $0.value }
            
            let phones = msisdns.filter { $0.stringValue.digits.suffix(maxNumberOfCompareDigits) == searchPhone }
            if phones.count == 1 {
                searchContact = contact
                return
            }
            
            let emails = contact.emailAddresses.compactMap { $0.value.lowercased as String }
            if emails.first(where: { $0 == lowercasedEmail }) != nil {
                searchContact = contact
                return
            }
        }
        if let searchContact = searchContact {
            return (givenName: searchContact.givenName, familyName: searchContact.familyName)
        }
        return ("", "")
    }
}
