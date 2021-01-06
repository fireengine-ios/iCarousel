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
    func fetchAllContacts(completion: BoolHandler?)
    func suggestContacts(for stringToSearch: String) -> [SuggestedContact]
    func getContactName(for phone: String, email: String) -> LocalContactNames
}


final class ContactsSuggestionServiceImpl: ContactsSuggestionService {
    
    private let contactStore = CNContactStore()
    private let queue = DispatchQueue(label: DispatchQueueLabels.localContactsServiceQueue)
    private let contactsStorage = LocalContactsStorage.shared
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onContactStoreDidChange),
                                               name: .CNContactStoreDidChange,
                                               object: nil)
    }
    
    func fetchAllContacts(completion: BoolHandler?) {
        checkAuthorization { [weak self] result in
            guard let self = self else {
                completion?(false)
                return
            }
            
            guard result.isAllowed else {
                printLog("Local Contacts. Access denied.")
                completion?(false)
                return
            }
            
            self.queue.async(flags: .barrier) { [weak self] in
                guard let self = self else {
                    completion?(false)
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
                    assertionFailure()
                    printLog("Failed to enumerate contacts. \(error)")
                }
                
                self.contactsStorage.cache(contacts: contacts)
                
                completion?(true)
            }
        }
    }
    
    func suggestContacts(for stringToSearch: String) -> [SuggestedContact] {
        contactsStorage.getContacts(containing: stringToSearch)
    }
    
    func getContactName(for phone: String, email: String) -> LocalContactNames {
        contactsStorage.getContactName(for: phone, email: email)
    }
    
    //MARK - Private
    private func checkAuthorization(completion: @escaping ValueHandler<(isAllowed: Bool, askedPermissions: Bool)>) {
        let currentStatus = CNContactStore.authorizationStatus(for: .contacts)
        if currentStatus.isContained(in: [.authorized, .denied]) {
            completion((currentStatus == .authorized, false))
            return
        }
        
        contactStore.requestAccess(for: .contacts) { isAllowed, error in
            if let error = error {
                assertionFailure()
                printLog("Contacts auth error: \(error)")
            }
            
            completion((isAllowed, true))
        }
    }
    
    @objc
    private func onContactStoreDidChange() {
        fetchAllContacts(completion: nil)
    }
}
