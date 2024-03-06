//
//  HomeCardResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeCardResponse : Equatable {
    static func == (lhs: HomeCardResponse, rhs: HomeCardResponse) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int?
    var type: HomeCardTypes?
    var saved: Bool = false
    var actionable: Bool = false
    var details: JSON?
    var content: JSON?
    var fileList: [JSON]?
    var order = 0
    
    func getOperationType() -> OperationType? {
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
//        case .movie:
//            return .movieCard
//        case .collage:
//            return .collage
//        case .stylizedPhoto:
//            return .stylizedPhoto
        case .contactBackup:
            if ContactBackupOld.isContactInfoObjectEmpty(object: details) {
                return .contactBacupEmpty
            }
            return .contactBacupOld
//        case .album:
//            return .albumCard
        case .autoSyncWatingForWifi:
            return .waitingForWiFi
        case .autoSyncOff:
            return .autoUploadIsOff
        case .freeUpSpace:
            return .freeAppSpace
//        case .animation:
//            return .animationCard
        case .launchCampaign:
            return .launchCampaign
        case .instaPick:
            return .instaPick
//        case .tbMatik:
//            return .tbMatik
        case .campaign:
            return .campaignCard
        case .promotion:
            return .promotion
        case .divorce:
            return .divorce
        case .invitation:
            return .invitation
        case .thingsDocument:
            return .documents
        case .paycell:
            return .paycell
        case .drawCampaign:
            return .drawCampaign
        case .photoPrint:
            return .photoPrint
        case .milliPiyango:
            return .milliPiyango
        case .biOgrenci:
            return .biOgrenci
        case .discoverCard:
            return .discoverCard
        case .drawCampaignApply:
            return .drawCampaignApply
        case .garenta:
            return .garenta
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
        content = json["details"]["content"]
        if type == .thingsDocument {
            fileList = json["fileList"].array
        }
    }
}

enum HomeCardTypes: String {
    case emptyStorage = "EMPTY_STORAGE"
    case storageAlert = "STORAGE_ALERT"
    case latestUploads = "LATEST_UPLOADS"
    //case movie = "MOVIE"
    //case collage = "COLLAGE"
    //case stylizedPhoto = "STYLIZED_PHOTO"
    case contactBackup = "CONTACT_BACKUP"
    //case album = "ALBUM"
    case autoSyncWatingForWifi = "AUTO_SYNC_WAITING_FOR_WIFI"
    case autoSyncOff = "AUTO_SYNC_OFF"
    case freeUpSpace = "FREE_UP_SPACE"
    //case rating = "RATING"
    //case animation = "ANIMATION"
    case launchCampaign = "LAUNCH_CAMPAIGN"
    case instaPick = "INSTAGRAM_LIKE"
    //case tbMatik = "TBMATIC"
    case campaign = "CAMPAIGN"
    case promotion = "PROMOTION"
    case divorce = "DIVORCE"
    case invitation = "INVITATION"
    case thingsDocument = "THINGS_DOCUMENT"
    case photoPrint = "PRINT"
    case paycell = "PAYCELL"
    case drawCampaign = "DRAW_CAMPAIGN"
    case milliPiyango = "MILLIPIYANGO"
    case biOgrenci = "BI_OGRENCI"
    case discoverCard = "BEST_SCENE_CARD"
    case drawCampaignApply = "DRAW_CAMPAIGN_APPLY"
    case garenta = "GARENTA"
}

