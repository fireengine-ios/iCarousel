//
//  UploadResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class UploadBaseURLResponse: ObjectRequestResponse {
    
    var url: URL?
    var uniqueValueByBaseUrl: String = ""
    
    override func mapping() {
        url = json?["value"].url
        let list = json?["value"].string?
            .components(separatedBy: "/")
            .filter { $0.hasPrefix("AUTH_") }
        uniqueValueByBaseUrl = list?.first ?? ""
    }
}
