//
//  BestSceneResponseWithId.swift
//  Depo
//
//  Created by Rustam Manafov on 04.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

struct BurstGroupsWithId: Codable {
    let id: Int?
    let groupDate: Int?
    let coverPhoto: Photo
    let fileList: [Photo]
    
    struct Photo: Codable {
        let createdDate: Int?
        let lastModifiedDate: Int?
        let id: Int?
        let hash: String?
        let name: String?
        let uuid: String?
        let bytes: Int?
        let folder: Bool?
        let status: String?
        let uploaderDeviceType: String?
        let tempDownloadURL: String?
        let contentType: String?
        let metadata: Metadata
        let album: [String]
        let location: Location
        
        enum CodingKeys: String, CodingKey {
            case createdDate, lastModifiedDate, id, hash, name, uuid, bytes, folder, status, uploaderDeviceType, tempDownloadURL, album, location
            case contentType = "content_type"
            case metadata
        }
        
        
        struct Metadata: Codable {
            let thumbnailLarge: String?
            let originalHash: String?
            let thumbnailSmall: String?
            let originalBytes: String?
            let imageHeight: String?
            let imageWidth: String?
            let thumbnailMedium: String?
            let imageOrientation: String?
            let imageDateTime: String?
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
        
        struct Location: Codable {
            
        }
        
    }
}
