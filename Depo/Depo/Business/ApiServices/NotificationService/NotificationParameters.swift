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
    static let fetch = accountBase + "/fetch?language=tr"
    static let read = accountBase + "/read"
    static let delete = accountBase
}

class NotificationFetchParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: NotificationPath.fetch, relativeTo: super.patch)!
    }
}

class NotificationDeleteParameters: BaseRequestParametrs {
    
    var idList: [Int] = []
        
    init(with idList: [Int]) {
        self.idList = idList
    }
    
    override var patch: URL {
        return URL(string: NotificationPath.delete, relativeTo: super.patch)!
    }
    
    override var requestParametrs: Any {
        return idList
    }
}

class NotificationReadParameters: BaseRequestParametrs {
    
    let id: String
    
    init(with id: String) {
        self.id = id
    }
    
    override var patch: URL {
        return URL(string: NotificationPath.read + "/" + id, relativeTo: super.patch)!
    }
}
