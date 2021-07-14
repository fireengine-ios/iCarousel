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
    static let demo = "demo"
    static let rank = "rank"
    static let alternateThumbnail = "alternateThumbnail"
}


final class PeopleItemResponse: ObjectRequestResponse {

    var id: Int64?
    var ugglaId: Int64?
    var name: String?
    var thumbnail: URL?
    var visible: Bool?
    var isDemo: Bool?
    var rank: Int64?
    var alternateThumbnail: URL?

    override func mapping() {
        id = json?[PeopleJsonKey.id].int64
        ugglaId = json?[PeopleJsonKey.ugglaId].int64
        name = json?[PeopleJsonKey.name].string
        thumbnail = json?[PeopleJsonKey.thumbnail].url
        visible = json?[PeopleJsonKey.visible].bool
        isDemo = json?[PeopleJsonKey.demo].bool
        rank = json?[PeopleJsonKey.rank].int64
        alternateThumbnail = json?[PeopleJsonKey.alternateThumbnail].url
    }
}

struct PeopleOnPhotoJsonKey {
    static let personInfoId = "personInfoId"
    static let name = "name"
    static let thumbnailURL = "thumbnailURL"
}

final class PeopleOnPhotoItemResponse: ObjectRequestResponse {

    var personInfoId: Int64?
    var name: String?
    var thumbnailURL: URL?

    override func mapping() {
        personInfoId = json?[PeopleOnPhotoJsonKey.personInfoId].int64
        name = json?[PeopleOnPhotoJsonKey.name].string
        thumbnailURL = json?[PeopleOnPhotoJsonKey.thumbnailURL].url
    }
}

final class PeopleServiceResponse: ObjectRequestResponse {
    
    var list: Array<PeopleItemResponse> = []
    
    override func mapping() {
        if let result = json?.array?.compactMap({ PeopleItemResponse(withJSON: $0) }) {
            list = result
        }
    }
}

final class PeoplePageResponse: ObjectRequestResponse, Map {
    
    var list: [PeopleItemResponse] = []
    
    override func mapping() {
        if let result = json?[PeopleJsonKey.personInfos].array?.compactMap({ PeopleItemResponse(withJSON: $0) }) {
            list = result
        }
    }
}

final class FaceImageThumbnailsResponse: ObjectRequestResponse {
    
    var list: [String] = []
    
    override func mapping() {
        if let result = json?.arrayObject as? [String] {
            list = result
        }
    }

}

final class PeopleThumbnailsResponse: ObjectRequestResponse, Map {
    
    var list: [PeopleOnPhotoItemResponse] = []
    
    override func mapping() {
        if let result = json?.array?.compactMap({ PeopleOnPhotoItemResponse(withJSON: $0) }) {
            list = result
        }
    }
}
