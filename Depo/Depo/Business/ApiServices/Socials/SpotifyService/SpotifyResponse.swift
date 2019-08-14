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
    var monthValue = ""
    var nameFirstLetter = ""
    
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
        
        if let date = lastModifiedDate {
            monthValue = date.getDateInTextForCollectionViewHeader()
        }
        self.nameFirstLetter = String(name.first ?? Character(""))
    }
    
    func equalTo(rhs: SpotifyObject) -> Bool {
        return id == rhs.id
    }
    
    static func == (lhs: SpotifyObject, rhs: SpotifyObject) -> Bool {
        return lhs.equalTo(rhs: rhs)
    }
}

final class SpotifyPlaylist: SpotifyObject {
    
    let playlistId: String
    var count: Int
    
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
    
    override func equalTo(rhs: SpotifyObject) -> Bool {
        if id != nil, rhs.id != nil {
            return super.equalTo(rhs: rhs)
        }
        guard let rhs_playlistId = (rhs as? SpotifyPlaylist)?.playlistId else {
            return super.equalTo(rhs: rhs)
        }
        return playlistId == rhs_playlistId
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
 
    override func equalTo(rhs: SpotifyObject) -> Bool {
        if id != nil, rhs.id != nil {
            return super.equalTo(rhs: rhs)
        }
        guard let rhs_isrc = (rhs as? SpotifyTrack)?.isrc else {
            return super.equalTo(rhs: rhs)
        }
        return isrc == rhs_isrc
    }
}
