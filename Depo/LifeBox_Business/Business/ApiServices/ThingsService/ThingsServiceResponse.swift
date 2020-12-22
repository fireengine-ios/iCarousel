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
    static let objectInfos = "objectInfos"
    static let demo = "demo"
    static let rank = "rank"
    static let alternateThumbnail = "alternateThumbnail"
}

final class ThingsItemResponse: ObjectRequestResponse {
    
    var id: Int64?
    var code: String?
    var thumbnail: URL?
    var name: String?
    var isDemo: Bool?
    var rank: Int64?
    var alternateThumbnail: URL?
    
    override func mapping() {
        id = json?[ThingsJsonKey.id].int64
        code = json?[ThingsJsonKey.code].string
        thumbnail = json?[ThingsJsonKey.thumbnail].url
        name = json?[ThingsJsonKey.name].string
        isDemo = json?[ThingsJsonKey.demo].bool
        rank = json?[ThingsJsonKey.rank].int64
        alternateThumbnail = json?[ThingsJsonKey.alternateThumbnail].url

    }
}

//final class ThingsServiceResponse: ObjectRequestResponse {
//    var list: Array<ThingsItemResponse> = []
//    
//    override func mapping() {
//        if let result = json?.array?.flatMap({ ThingsItemResponse(withJSON: $0) }) {
//            list = result
//        }
//    }
//}

final class ThingsPageResponse: ObjectRequestResponse, Map {
    var list: [ThingsItemResponse] = []
    
    override func mapping() {
        if let result = json?[ThingsJsonKey.objectInfos].array?.flatMap({ ThingsItemResponse(withJSON: $0) }) {
            list = result
        }
    }
}
