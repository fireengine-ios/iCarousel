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
    
    let id: String
    let name: String
    let image: SpotifyImage?
    
    init(id: String, name: String, image: SpotifyImage?) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    static func == (lhs: SpotifyObject, rhs: SpotifyObject) -> Bool {
        return lhs.id == rhs.id
    }
}

final class SpotifyPlaylist: SpotifyObject {
    
    let count: Int
    
    init(id: String, name: String, count: Int, image: SpotifyImage?) {
        self.count = count
        super.init(id: id, name: name, image: image)
    }
    
    convenience init?(json: JSON) {
        guard
            let id = json["playlistId"].string,
            let name = json["name"].string,
            let count = json["count"].int
            else {
                assertionFailure()
                return nil
        }
        let image = SpotifyImage(json: json["image"])
        self.init(id: id, name: name, count: count, image: image)
    }
}

final class SpotifyTrack: SpotifyObject {
    
    let albumName: String
    let artistName: String
    
    init(id: String, name: String, albumName: String, artistName: String, image: SpotifyImage?) {
        self.albumName = albumName
        self.artistName = artistName
        super.init(id: id, name: name, image: image)
    }
    
    convenience init?(json: JSON) {
        guard
            let id = json["isrc"].string,
            let name = json["name"].string,
            let albumName = json["albumName"].string,
            let artistName = json["artistName"].string
            else {
                assertionFailure()
                return nil
        }
        
        let image = SpotifyImage(json: json["image"])
        self.init(id: id, name: name, albumName: albumName, artistName: artistName, image: image)
    }
}
