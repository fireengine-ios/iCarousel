//
//  NotificationParameters.swift
//  Depo
//
//  Created by yilmaz edis on 13.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct NotificationPath {
    static let accountBase = "notification/communication"
    static let fetch = accountBase + "/fetch"
    static let read = accountBase + "/read"
}

class NotificationFetchParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: NotificationPath.fetch, relativeTo: super.patch)!
    }
}

class NotificationReadParameters: BaseRequestParametrs {
    
    let id: String
    
    init(id: String) {
        self.id = id
    }
    
    override var patch: URL {
        return URL(string: NotificationPath.read + "/" + id, relativeTo: super.patch)!
    }
}
