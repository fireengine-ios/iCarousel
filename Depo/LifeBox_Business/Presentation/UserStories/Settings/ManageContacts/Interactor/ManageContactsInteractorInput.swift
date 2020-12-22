//
//  ManageContactsInteractorInput.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol ManageContactsInteractorInput {
    func loadContacts()
    func cancelSearch()
    func searchContacts(query: String)
    func continueLoading()
    func deleteContact(_ contact: RemoteContact)
}
