//
//  SpotifyResponse.swift
//  Depo
//
//  Created by Andrei Novikau on 8/5/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class SpotifyStatus {
    
    enum JobStatus: String {
        case unowned = "UNKNOWN"
        case pending = "PENDING"
        case running = "RUNNING"
        case finished = "FINISHED"
        case cancelled = "CANCELED"
        case failed = "FAILED"
    }
    
    let jobStatus: JobStatus
    let isConnected: Bool
    let lastModifiedDate: Date?
    let userName: String?
    
    init(jobStatus: JobStatus, isConnected: Bool, lastModifiedDate: Date?, userName: String?) {
        self.jobStatus = jobStatus
        self.isConnected = isConnected
        self.lastModifiedDate = lastModifiedDate
        self.userName = userName
    }
}

extension SpotifyStatus {
    convenience init?(json: JSON) {
        guard
            let jobStatusString = json["jobStatus"].string,
            let jobStatus = JobStatus(rawValue: jobStatusString),
            let isConnected = json["connected"].bool
            else {
                assertionFailure()
                return nil
        }
        
        let lastModifiedDate = json["lastModifiedDate"].date
        let userName = json["userName"].string
        
        self.init(jobStatus: jobStatus, isConnected: isConnected, lastModifiedDate: lastModifiedDate, userName: userName)
    }
}

class SpotifyObject: Equatable {
    
    final class SpotifyImage {
        let height: Int?
        let width: Int?
        let url: URL?
        
        init?(json: JSON) {
            height = json["height"].int
            width = json["width"].int
            url = json["url"].url
        }
    }
    
    let name: String
    let image: SpotifyImage?
    
    /// for imported objects
    let id: Int?
    let createdDate: Date?
    let lastModifiedDate: Date?
    let imagePath: URL?
    
    var monthValue: String {
        if let date = lastModifiedDate {
            return date.getDateInTextForCollectionViewHeader()
        }
        return ""
    }
    
    required init?(json: JSON) {
        guard let name = json["name"].string else {
            assertionFailure()
            return nil
        }
        
        self.name = name
        self.image = SpotifyImage(json: json["image"])
        self.id = json["id"].int
        self.createdDate = json["createdDate"].date
        self.lastModifiedDate = json["lastModifiedDate"].date
        self.imagePath = json["imagePath"].url
    }
    
    static func == (lhs: SpotifyObject, rhs: SpotifyObject) -> Bool {
        return lhs.id == rhs.id
    }
}

final class SpotifyPlaylist: SpotifyObject {
    
    let playlistId: String
    let count: Int
    
    required init?(json: JSON) {
        guard
            let playlistId = json["playlistId"].string,
            let count = json["count"].int
            else {
                assertionFailure()
                return nil
        }
        self.playlistId = playlistId
        self.count = count
        
        super.init(json: json)
    }
    
    static func == (lhs: SpotifyPlaylist, rhs: SpotifyPlaylist) -> Bool {
        return lhs.playlistId == rhs.playlistId
    }
}

final class SpotifyTrack: SpotifyObject {
    
    let isrc: String
    let albumName: String
    let artistName: String
    
    required init?(json: JSON) {
        guard
            let isrc = json["isrc"].string,
            let albumName = json["albumName"].string,
            let artistName = json["artistName"].string
            else {
                assertionFailure()
                return nil
        }
        
        self.isrc = isrc
        self.albumName = albumName
        self.artistName = artistName
        super.init(json: json)
    }
    
    static func == (lhs: SpotifyTrack, rhs: SpotifyTrack) -> Bool {
        return lhs.isrc == rhs.isrc
    }
}
