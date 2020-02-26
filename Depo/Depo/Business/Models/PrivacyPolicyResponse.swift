//
//  PrivacyPolicyResponse.swift
//  Depo
//
//  Created by Maxim Soldatov on 2/6/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PrivacyPolicyResponse {
    
    private enum ResponseKey {
        static let id = "id"
        static let createDate = "createDate"
        static let locale = "locale"
        static let content = "content"
    }
    
    let id: Int
    let createDate: Date
    let locale: String
    let content: String
    
    init(id: Int, createDate: Date, locale: String, content: String) {
        self.id = id
        self.createDate = createDate
        self.locale = locale
        self.content = content
    }
    
    init?(json: JSON) {
        guard
            let id = json[ResponseKey.id].int,
            let createDate = json[ResponseKey.createDate].date,
            let locale = json[ResponseKey.locale].string,
            let content = json[ResponseKey.content].string
        else {
            assertionFailure()
            return nil
        }
    
        self.init(id: id, createDate: createDate, locale: locale, content: content)
    }
    
}
