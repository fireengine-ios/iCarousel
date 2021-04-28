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
        case .autoSyncWatingForWifi:
            return .waitingForWiFi
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
    case autoSyncWatingForWifi = "AUTO_SYNC_WAITING_FOR_WIFI"
    //case rating = "RATING"
}
