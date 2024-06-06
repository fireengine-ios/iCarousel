//
//  WrapDataResponse.swift
//  Depo
//
//  Created by Ozan Salman on 3.06.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

// MARK: - WrapDataResponse
struct WrapDataResponse: Codable {
    let createdDate, lastModifiedDate: Int?
    let hash, name, uuid: String?
    let bytes: Int?
    let status: String?
    let tempDownloadURL: String?
    let contentType: String?
    let metadata: Metadata?
    
    enum CodingKeys: String, CodingKey {
        case createdDate, lastModifiedDate, hash, name, uuid, bytes, status, tempDownloadURL, contentType
        case metadata
    }
    
    struct Metadata: Codable {
        let thumbnailLarge, thumbnailSmall: String?
        let imageHeight, imageWidth: String?
        let thumbnailMedium: String?
        
        enum CodingKeys: String, CodingKey {
            case thumbnailLarge = "Thumbnail-Large"
            case thumbnailSmall = "Thumbnail-Small"
            case imageHeight = "Image-Height"
            case imageWidth = "Image-Width"
            case thumbnailMedium = "Thumbnail-Medium"
        }
    }
    
}
