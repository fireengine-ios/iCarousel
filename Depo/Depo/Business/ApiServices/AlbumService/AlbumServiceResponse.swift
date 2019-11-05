//
//  AlbumServiceResponse.swift
//  Depo
//
//  Created by Oleg on 22.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct AlbumJsonKey {
    
    static let createdDate = "createdDate"
    static let lastModifiedDate = "lastModifiedDate"
    static let uuid = "uuid"
    static let name = "label"
    static let bytes = "bytes"
    static let content_type = "contentType"
    static let imageCount = "imageCount"
    static let videoCount = "videoCount"
    static let audioCount = "audioCount"
    static let coverPhoto = "coverPhoto"
    static let readOnly = "readOnly"
    static let icon = "icon"
}


final class AlbumServiceResponse: ObjectRequestResponse, Map {
    
    var createdDate: Date?
    var lastModifiedDate: Date?
    var uuid: String?
    var name: String?
    var contentType: String?
    var imageCount: Int?
    var videoCount: Int?
    var audioCount: Int?
    var coverPhoto: SearchItemResponse?
    var readOnly: Bool?
    var icon: String?
    
    override func mapping() {
        createdDate = json?[AlbumJsonKey.createdDate].date
        lastModifiedDate = json?[AlbumJsonKey.lastModifiedDate].date
        uuid = json?[AlbumJsonKey.uuid].string
        name = json?[AlbumJsonKey.name].string
        contentType = json?[AlbumJsonKey.content_type].string
        imageCount = json?[AlbumJsonKey.imageCount].int
        videoCount = json?[AlbumJsonKey.videoCount].int
        audioCount = json?[AlbumJsonKey.audioCount].int
        coverPhoto = SearchItemResponse(withJSON: json?[AlbumJsonKey.coverPhoto])
        readOnly = json?[AlbumJsonKey.readOnly].bool
        icon = json?[AlbumJsonKey.icon].string
    }
}

class AlbumResponse: ObjectRequestResponse {
    
    var list: Array<AlbumServiceResponse> = []
    
    override func mapping() {
        let  tmpList = json?.array
        if let result = tmpList?.flatMap({ AlbumServiceResponse(withJSON: $0) }) {
            list = result
        }
    }
}
