//
//  EULAResponse.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class EULAResponse {

    private enum EULAResponseKey {
        static let id = "id"
        static let createDate = "createDate"
        static let locale = "locale"
        static let content = "content"
    }
    
    var id: Int?
    var createDate: Date?
    var locale: String?
    var content: String?
    
}

extension EULAResponse: Map {
    convenience init?(json: JSON) {
        self.init()
        id = json[EULAResponseKey.id].intValue
        locale = json[EULAResponseKey.locale].stringValue
        content = json[EULAResponseKey.content].stringValue
        if let date = json[EULAResponseKey.createDate].double  {
            createDate = Date(timeIntervalSince1970: date)
        }
    }
}
