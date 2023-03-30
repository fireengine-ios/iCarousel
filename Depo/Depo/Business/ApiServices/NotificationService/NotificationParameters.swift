//
//  NotificationParameters.swift
//  Depo
//
//  Created by yilmaz edis on 13.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

enum NotificationType: String {
    case popup = "POP_UP"
    case inapp = "IN_APP"
}

struct NotificationPath {
    static let accountBase = "notification/communication"
    static let fetch = accountBase + "/fetch"
    static let read = accountBase + "/read"
    static let delete = accountBase
}

final class NotificationFetchParameters: BaseRequestParametrs {
    
    var type: String
    let language: String = Locale.current.languageCode ?? ""
    
    init(type: NotificationType) {
        self.type = type.rawValue
    }
    
    override var patch: URL {
        return URL(string: NotificationPath.fetch + "?language=\(language)&type=\(type)", relativeTo: super.patch)!
    }
}

final class NotificationDeleteParameters: BaseRequestParametrs {
    
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

final class NotificationReadParameters: BaseRequestParametrs {
    
    let id: String
    
    init(with id: String) {
        self.id = id
    }
    
    override var patch: URL {
        return URL(string: NotificationPath.read + "/" + id, relativeTo: super.patch)!
    }
}
