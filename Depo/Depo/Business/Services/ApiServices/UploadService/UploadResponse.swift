//
//  UploadResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class UploadNotifyResponse: ObjectRequestResponse {
    
    var itemResponse : SearchItemResponse?
    
    override func mapping() {
        itemResponse = SearchItemResponse(withJSON: self.json)
    }
}

class UploadResponse: ObjectRequestResponse {
    
    var url: URL?
    var userUniqueValue: String?
    
    override func mapping() {
        
        if let st = json?["value"].string, isOkStatus {
            
            url = json?["value"].url
            
            userUniqueValue = st.components(separatedBy: "/")
                .filter{ $0.hasPrefix("AUTH_")}
                .first
        }
    }
}

class UloadSuccess: ObjectRequestResponse {
    override func mapping() {
        print("A")
    }
}

class UploadBaseURLResponse: ObjectRequestResponse {
    
    var url: URL?
    var uniqueValueByBaseUrl: String = ""
    
    override func mapping() {
        url = json?["value"].url
        let list = json?["value"].string?
            .components(separatedBy: "/")
            .filter{ $0.hasPrefix("AUTH_")}
        uniqueValueByBaseUrl = list?.first ?? ""
    }
}
