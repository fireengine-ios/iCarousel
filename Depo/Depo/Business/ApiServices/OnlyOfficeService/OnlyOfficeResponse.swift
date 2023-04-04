//
//  OnlyOfficeResponse.swift
//  Depo
//
//  Created by Ozan Salman on 31.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct OnlyOfficeJsonKey {
    static let accountUuid = "accountUuid"
    static let fileUuid = "fileUuid"
}

final class OnlyOfficeServiceResponse: ObjectRequestResponse, Map {
    
    var accountUuid: String?
    var fileUuid: String?
    
    override func mapping() {
        accountUuid = json?[OnlyOfficeJsonKey.accountUuid].string
        fileUuid = json?[OnlyOfficeJsonKey.fileUuid].string
    }
}

final class OnlyOfficeResponse: ObjectRequestResponse, Map {
    
    var accountUuid: String?
    var fileUuid: String?
    
    override func mapping() {
        accountUuid = json?[OnlyOfficeJsonKey.accountUuid].string
        fileUuid = json?[OnlyOfficeJsonKey.fileUuid].string
    }
}

