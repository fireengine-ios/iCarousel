//
//  PeopleServiceResponse.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

struct PeopleJsonKey {
    static let id = "id"
    static let ugglaId = "ugglaId"
    static let name = "name"
    static let thumbnail = "thumbnail"
    static let visible = "visible"
    static let personInfos = "personInfos"
}


class PeopleItemResponse: ObjectRequestResponse {

    var id: Int64?
    var ugglaId: Int64?
    var name: String?
    var thumbnail: URL?
    var visible: Bool?

    override func mapping() {
        id = json?[PeopleJsonKey.id].int64
        ugglaId = json?[PeopleJsonKey.ugglaId].int64
        name = json?[PeopleJsonKey.name].string
        thumbnail = json?[PeopleJsonKey.thumbnail].url
        visible = json?[PeopleJsonKey.visible].bool
    }
}

class PeopleServiceResponse: ObjectRequestResponse {
    
    var list: Array<PeopleItemResponse> = []
    
    override func mapping() {
        if let result = json?.array?.flatMap( {PeopleItemResponse(withJSON: $0)}) {
            list = result
        }
    }
}

class PeoplePageResponse: ObjectRequestResponse {
    
    var list: [PeopleItemResponse] = []
    
    override func mapping() {
        if let result = json?[PeopleJsonKey.personInfos].array?.flatMap( {PeopleItemResponse(withJSON: $0)}) {
            list = result
        }
    }
}
