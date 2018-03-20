//
//  ContactSyncResponse.swift
//  Depo_LifeTech
//
//  Created by Raman on 1/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

struct ContactSyncJsonKey {
    static let id = "id"
    static let name = "displayname"
    static let currentPage = "currentPage"
    static let numberOfPages = "numOfPages"
    static let items = "items"
    static let data = "data"
}

class RemoteContact: ObjectRequestResponse {
    var id: String = "-1"
    var name: String = ""
    
    override func mapping() {
        id = String(json?[ContactSyncJsonKey.id].int ?? -1)
        name = json?[ContactSyncJsonKey.name].string ?? ""
    }
}

class ContactsResponse: ObjectRequestResponse {
    var contacts = [RemoteContact]()
    var currentPage = 0
    var numberOfPages = 0
    
    override func mapping() {
        json = json?[ContactSyncJsonKey.data]
        currentPage = json?[ContactSyncJsonKey.currentPage].intValue ?? 0
        numberOfPages = json?[ContactSyncJsonKey.numberOfPages].intValue ?? 0
        
        guard let list = json?[ContactSyncJsonKey.items].array else {
            return
        }
        contacts = list.flatMap { RemoteContact(withJSON: $0) }
    }
}
