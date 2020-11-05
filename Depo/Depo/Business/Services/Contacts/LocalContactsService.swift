//
//  LocalContactsService.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import Contacts


protocol ContactsSuggestionService {
    func fetchAllContacts(completion: VoidHandler?)
    func suggestContacts(for stringToSearch: String) -> [SuggestedContact]
}


final class ContactsSuggestionServiceImpl: ContactsSuggestionService {
    
    private let contactStore = CNContactStore()
    private let queue = DispatchQueue(label: DispatchQueueLabels.localContactsServiceQueue)
    private let contactsStorage = LocalContactsStorage.shared
    
    
    //add BoolHandler if needed
    func fetchAllContacts(completion: VoidHandler?) {
        checkAuthorization { [weak self] isAuthorized in
            guard let self = self else {
                completion?()
                return
            }
            
            guard isAuthorized else {
                printLog("Local Contacts. Access denied.")
                completion?()
                return
            }
            
            self.queue.async { [weak self] in
                guard let self = self else {
                    completion?()
                    return
                }
                
                var contacts = [CNContact]()
                
                do {
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                    let request = CNContactFetchRequest(keysToFetch: keys)
                    try self.contactStore.enumerateContacts(with: request, usingBlock: { contact, _ in
                        contacts.append(contact)
                    })
                    
                } catch {
                    printLog("Failed to enumerate contacts. \(error)")
                }
                
                self.contactsStorage.cache(contacts: contacts)
                
                completion?()
            }
        }
    }
    
    func suggestContacts(for stringToSearch: String) -> [SuggestedContact] {
        contactsStorage.getContacts(containing: stringToSearch)
    }
    
    
    private func checkAuthorization(completion: @escaping BoolHandler) {
        contactStore.requestAccess(for: .contacts) { isAllowed, error in
            if let error = error {
                printLog("Contacts auth error: \(error)")
            }
            
            completion(isAllowed)
        }
    }
}
