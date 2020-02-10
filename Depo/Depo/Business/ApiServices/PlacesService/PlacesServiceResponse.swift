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
    static let demo = "demo"
    static let rank = "rank"
    static let alternateThumbnail = "alternateThumbnail"
}

final class PlacesItemResponse: ObjectRequestResponse {
    
    var id: Int64?
    var adminLevel: String?
    var thumbnail: URL?
    var name: String?
    var isDemo: Bool?
    var rank: Int64?
    var alternateThumbnail: URL?
    
    override func mapping() {
        id = json?[PlacesJsonKey.id].int64
        adminLevel = json?[PlacesJsonKey.adminLevel].string
        thumbnail = json?[PlacesJsonKey.thumbnail].url
        name = json?[PlacesJsonKey.name].string
        isDemo = json?[PlacesJsonKey.demo].bool
        rank = json?[PlacesJsonKey.rank].int64
        alternateThumbnail = json?[PlacesJsonKey.alternateThumbnail].url

    }
}

final class PlacesServiceResponse: ObjectRequestResponse {
    var list: Array<PlacesItemResponse> = []
    
    override func mapping() {
        if let result = json?.array?.flatMap({ PlacesItemResponse(withJSON: $0) }) {
            list = result
        }
    }
}

final class PlacesPageResponse: ObjectRequestResponse, Map {
    var list: Array<PlacesItemResponse> = []
    
    override func mapping() {
        if let result = json?[PlacesJsonKey.locationInfos].array?.flatMap({ PlacesItemResponse(withJSON: $0) }) {
            list = result
        }
    }
}

final class DeletePhotosFromPlacesAlbum: DeletePhotosFromAlbum {
    
}
