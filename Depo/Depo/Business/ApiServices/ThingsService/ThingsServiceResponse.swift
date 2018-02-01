//
//  ThingsServiceResponse.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

struct ThingsJsonKey {
    static let id = "id"
    static let code = "code"
    static let thumbnail = "thumbnail"
    static let name = "name"
}

class ThingsItemResponse: ObjectRequestResponse {
    
    var id: Int64?
    var code: String?
    var thumbnail: URL?
    var name: String?
    
    override func mapping() {
        id = json?[ThingsJsonKey.id].int64
        code = json?[ThingsJsonKey.code].string
        thumbnail = json?[ThingsJsonKey.thumbnail].url
        name = json?[ThingsJsonKey.name].string

    }
}

class ThingsServiceResponse: ObjectRequestResponse {
    var list: Array<ThingsItemResponse> = []
    
    override func mapping() {
        if let result = json?.array?.flatMap( {ThingsItemResponse(withJSON: $0)}) {
            list = result
        }
    }
}
