//
//  TimelineResponse.swift
//  Depo
//
//  Created by Ozan Salman on 10.10.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

// MARK: - Timeline
struct TimelineResponse: Codable {
    let id: Int
    let saved: Bool
    let details: Details
    
    
    // MARK: - Details
    struct Details: Codable {
        let createdDate, lastModifiedDate: Int
            let hash, name, uuid: String
            let bytes: Int
            let status: String
            let tempDownloadURL: String
            let contentType: String
            let metadata: Metadata

            enum CodingKeys: String, CodingKey {
                case createdDate, lastModifiedDate, hash, name, uuid, bytes, status, tempDownloadURL
                case contentType = "content_type"
                case metadata
            }
    }
    
    // MARK: - Metadata
    struct Metadata: Codable {
        let thumbnailLarge: String
        let videoPreview: String
        let thumbnailSmall: String
        let imageHeight, imageWidth, duration: String
        let thumbnailMedium: String
        let imageDateTime: String

        enum CodingKeys: String, CodingKey {
            case thumbnailLarge = "Thumbnail-Large"
            case videoPreview = "Video-Preview"
            case thumbnailSmall = "Thumbnail-Small"
            case imageHeight = "Image-Height"
            case imageWidth = "Image-Width"
            case duration = "Duration"
            case thumbnailMedium = "Thumbnail-Medium"
            case imageDateTime = "Image-DateTime"
        }
    }
}


// MARK: - WinterThemeVideoResponse

struct WinterThemeVideoResponse: Codable {
    let id: Int?
    let title, description: String?
    let saved: Bool?
    let details: Details?

// MARK: - Details
struct Details: Codable {
    let createdDate, lastModifiedDate, id: Int?
    let hash, name, uuid: String?
    let bytes: Int?
    let folder: Bool?
    let status: String?
    let tempDownloadURL: String?
    let contentType: String?
    let metadata: Metadata?
    let album: [JSONAny]
    let location: Location?

    enum CodingKeys: String, CodingKey {
        case createdDate, lastModifiedDate, id, hash, name, uuid, bytes, folder, status, tempDownloadURL
        case contentType = "content_type"
        case metadata, album, location
    }
}

// MARK: - Location
struct Location: Codable {
}

// MARK: - Metadata
    struct Metadata: Codable {
        let thumbnailLarge: String?
        let videoPreview: String?
        let thumbnailSmall: String?
        let imageHeight, imageWidth, duration: String?
        let thumbnailMedium: String?
        let videoHLSPreview: String?
        let imageDateTime: String?
        
        enum CodingKeys: String, CodingKey {
            case thumbnailLarge = "Thumbnail-Large"
            case videoPreview = "Video-Preview"
            case thumbnailSmall = "Thumbnail-Small"
            case imageHeight = "Image-Height"
            case imageWidth = "Image-Width"
            case duration = "Duration"
            case thumbnailMedium = "Thumbnail-Medium"
            case videoHLSPreview = "Video-Hls-Preview"
            case imageDateTime = "Image-DateTime"
        }
    }
}
