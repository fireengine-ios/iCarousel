//
//  HomeCardResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeCardResponse {
    var id: Int?
    var type: HomeCardTypes?
    var saved: Bool = false
    var actionable: Bool = false
    var details: JSON?
    var order = 0
    
    func getOperationType() -> OperationType?{
        guard let type = type else {
            return nil
        }
        switch type {
        case .emptyStorage:
            return .emptyStorage
        case .storageAlert:
            return .freeAppSpaceCloudWarning
        case .latestUploads:
            return .latestUploads
        case .movie:
            return .movieCard
        case .collage:
            return .collage
        case .stylizedPhoto:
            return .stylizedPhoto
        case .contactBackup:
            return .contactBacupEmpty
        case .album:
            return .albumCard
        case .autoSyncWatingForWifi:
            return .waitingForWiFi
        case .autoSyncOff:
            return .autoUploadIsOff
        case .freeUpSpace:
            return .freeAppSpace
        }
    }
}

extension HomeCardResponse: Map {
    convenience init?(json: JSON) {
        self.init()
        
        id = json["id"].int
        if let typeString = json["type"].string, let type = HomeCardTypes(rawValue: typeString) {
            self.type = type
        }
        saved = json["saved"].boolValue
        actionable = json["actionable"].boolValue
        details = json["details"]
    }
}

enum HomeCardTypes: String {
    case emptyStorage = "EMPTY_STORAGE"
    case storageAlert = "STORAGE_ALERT"
    case latestUploads = "LATEST_UPLOADS"
    case movie = "MOVIE"
    case collage = "COLLAGE"
    case stylizedPhoto = "STYLIZED_PHOTO"
    case contactBackup = "CONTACT_BACKUP"
    case album = "ALBUM"
    case autoSyncWatingForWifi = "AUTO_SYNC_WAITING_FOR_WIFI"
    case autoSyncOff = "AUTO_SYNC_OFF"
    case freeUpSpace = "FREE_UP_SPACE"
    //case rating = "RATING"
    //case animation = "ANIMATION"
}
