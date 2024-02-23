//
//  BestSceneResponse.swift
//  Depo
//
//  Created by Rustam Manafov on 15.02.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

typealias BurstGroup = [BurstGroups]

struct BurstGroups: Codable {
    let id, groupDate: Int?
    let coverPhoto: CoverPhoto
    
    // MARK: - CoverPhoto
    struct CoverPhoto: Codable {
        let createdDate, lastModifiedDate, id: Int?
        let hash, name, uuid: String?
        let bytes: Int?
        let folder: Bool?
        let status: Status
        let uploaderDeviceType: UploaderDeviceType
        let tempDownloadURL: String?
        let contentType: ContentType
        let metadata: Metadata
        let album: [JSONAny]
        let location: Location
        enum CodingKeys: String, CodingKey {
            case createdDate, lastModifiedDate, id, hash, name, uuid, bytes, folder, status, uploaderDeviceType, tempDownloadURL
            case contentType = "content_type"
            case metadata, album, location
        }
        
        enum ContentType: String, Codable {
            case imageJPEG = "image/jpeg"
        }
        // MARK: - Location
        struct Location: Codable {
        }
        // MARK: - Metadata
        struct Metadata: Codable {
            let thumbnailLarge: String?
            let originalHash: String?
            let thumbnailSmall: String?
            let originalBytes, imageHeight, imageWidth: String?
            let thumbnailMedium: String?
            let imageOrientation, imageDateTime: String?
            let xObjectMetaIosMetadataHash: String?
            enum CodingKeys: String, CodingKey {
                case thumbnailLarge = "Thumbnail-Large"
                case originalHash = "Original-Hash"
                case thumbnailSmall = "Thumbnail-Small"
                case originalBytes = "Original-Bytes"
                case imageHeight = "Image-Height"
                case imageWidth = "Image-Width"
                case thumbnailMedium = "Thumbnail-Medium"
                case imageOrientation = "Image-Orientation"
                case imageDateTime = "Image-DateTime"
                case xObjectMetaIosMetadataHash = "X-Object-Meta-Ios-Metadata-Hash"
            }
        }
        enum Status: String, Codable {
            case active = "ACTIVE"
        }
        enum UploaderDeviceType: String, Codable {
            case android = "ANDROID"
            case iphone = "IPHONE"
        }
    }
}
