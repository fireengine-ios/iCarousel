//
//  PlacesServiceResponse.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 22.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

struct PlacesJsonKey {
    static let id = "id"
    static let adminLevel = "adminLevel"
    static let thumbnail = "thumbnail"
    static let locationInfoNames = "locationInfoNames"
}

class PlacesItemResponse: ObjectRequestResponse {
    
    var id: Int64?
    var adminLevel: String?
    var thumbnail: URL?
    var locationInfoNames: [String]?
    
    override func mapping() {
        id = json?[PlacesJsonKey.id].int64
        adminLevel = json?[PlacesJsonKey.adminLevel].string
        thumbnail = json?[PlacesJsonKey.thumbnail].url
        locationInfoNames = json?[PlacesJsonKey.locationInfoNames].array?.flatMap{ $0.string }
    }
}

class PlacesServiceResponse: ObjectRequestResponse {
    
    var list: Array<PlacesItemResponse> = []
    
    override func mapping() {
        let  tmpList = json?.array
        if let result = tmpList?.flatMap( {PlacesItemResponse(withJSON: $0)}) {
            list = result
        }
    }
}
