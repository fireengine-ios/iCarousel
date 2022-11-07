//
//  ThrowbackServiceResponse.swift
//  Depo
//
//  Created by Burak Donat on 4.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

struct ThrowbackData: Codable {
    let id: Int?
    let name: String?
    let coverPhoto: ThrowbackCoverPhoto?
}

// MARK: - ThrowbackCoverPhoto
struct ThrowbackCoverPhoto: Codable {
    let createdDate, lastModifiedDate, id: Int?
    let hash, name, uuid: String?
    let bytes: Int?
    let folder: Bool?
    let status: String?
    let tempDownloadURL: String?
    let ugglaID, contentType: String?
    let metadata: ThrowbackMetadata?

    enum CodingKeys: String, CodingKey {
        case createdDate, lastModifiedDate, id, hash, name, uuid, bytes, folder, status, tempDownloadURL
        case ugglaID = "ugglaId"
        case contentType = "content_type"
        case metadata
    }
}

// MARK: - ThrowbackMetadata
struct ThrowbackMetadata: Codable {
    let thumbnailLarge: String?
    let thumbnailSmall: String?
    let imageHeight, imageWidth: String?
    let thumbnailMedium: String?
    let imageDateTime: String?

    enum CodingKeys: String, CodingKey {
        case thumbnailLarge = "Thumbnail-Large"
        case thumbnailSmall = "Thumbnail-Small"
        case imageHeight = "Image-Height"
        case imageWidth = "Image-Width"
        case thumbnailMedium = "Thumbnail-Medium"
        case imageDateTime = "Image-DateTime"
    }
}

struct ThrowbackDetailsData: Codable {
    let id: Int?
    let name: String?
    let fileList: [ThrowbackCoverPhoto?]
}
