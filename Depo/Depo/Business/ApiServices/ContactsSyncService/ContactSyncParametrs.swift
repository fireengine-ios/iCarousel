//
//  ContactSyncParametrs.swift
//  Depo_LifeTech
//
//  Created by Raman on 1/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class GetContacts: BaseRequestParametrs {
    let page: Int
    
    init(page: Int) {
        self.page = page
        super.init()
    }
    
    override var patch: URL {
        let path = String(format: RouteRequests.getContacts, page)
        return URL(string: path, relativeTo: RouteRequests.BaseContactsUrl)!
    }
}

class SearchContacts: BaseRequestParametrs {
    let query: String
    let page: Int
    
    init(query: String, page: Int) {
        self.query = query
        self.page = page
        super.init()
    }
    
    override var patch: URL {
        let path = String(format: RouteRequests.searchContacts, query, page)
        return URL.encodingURL(string: path, relativeTo: RouteRequests.BaseContactsUrl)!
    }
}

class DeleteContacts: BaseRequestParametrs {
    let contactIDs: [String]
    
    init(contactIDs: [String]) {
        self.contactIDs = contactIDs
        super.init()
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.deleteContacts, relativeTo: RouteRequests.BaseContactsUrl)!
    }
    
    override var requestParametrs: Any {
        return contactIDs
    }
}
