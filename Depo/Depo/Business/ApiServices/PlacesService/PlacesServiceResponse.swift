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
    static let name = "name"
    static let locationInfos = "locationInfos"
}

final class PlacesItemResponse: ObjectRequestResponse {
    
    var id: Int64?
    var adminLevel: String?
    var thumbnail: URL?
    var name: String?
    
    override func mapping() {
        id = json?[PlacesJsonKey.id].int64
        adminLevel = json?[PlacesJsonKey.adminLevel].string
        thumbnail = json?[PlacesJsonKey.thumbnail].url
        name = json?[PlacesJsonKey.name].string

    }
}

final class PlacesServiceResponse: ObjectRequestResponse {
    var list: Array<PlacesItemResponse> = []
    
    override func mapping() {
        if let result = json?.array?.flatMap( {PlacesItemResponse(withJSON: $0)}) {
            list = result
        }
    }
}

final class PlacesPageResponse: ObjectRequestResponse {
    var list: Array<PlacesItemResponse> = []
    
    override func mapping() {
        if let result = json?[PlacesJsonKey.locationInfos].array?.flatMap( {PlacesItemResponse(withJSON: $0)}) {
            list = result
        }
    }
}

final class DeletePhotosFromPlacesAlbum: DeletePhotosFromAlbum {
    
}
