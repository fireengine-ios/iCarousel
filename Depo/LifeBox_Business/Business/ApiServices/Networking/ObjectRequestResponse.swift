//
//  ObjectRequestResponse.swift
//  Depo_LifeTech
//
//  Created by Maksim Vakula on 9/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ObjectFromRequestResponse: class {
    init(json: Data?, headerResponse: HTTPURLResponse?)
    func mapping()
}

class ObjectRequestResponse: NSObject, ObjectFromRequestResponse {
    var json: JSON?
    var response: HTTPURLResponse?
    var jsonString: String?
    
    required init(json: Data?, headerResponse: HTTPURLResponse?) {
        if let data = json {
            let jsonFromData: JSON = JSON(data: data)
            self.json = jsonFromData
            
            /// JSON(data: data) can not correct string
            if ((json?.count)!>0 && jsonFromData.type == Type.null) {
                jsonString = String(data: json! as Data, encoding: .utf8)
            }
            
        } else {
            self.json = nil
        }
        response = headerResponse
        super.init()
        mapping()
    }
    
    required init(withJSON: JSON?) {
        self.json = withJSON
        self.response = nil
        super.init()
        mapping()
    }
    
    override init() {
        super.init()
    }
    
    func mapping() {}
    
    var isOkStatus: Bool {
        
        guard let status = json?[LbResponseKey.status].string else {
                return false
        }
        return Bool(status.uppercased() == "OK")
    }
    
    var valueDict: [String: JSON]? {
        
        guard let value = json?[LbResponseKey.value].dictionary else {
            return nil
        }
        return value
    }
    
    var responseHeader: [AnyHashable: Any]? {
        return response?.allHeaderFields
    }
}

extension JsonMap where Self: ObjectRequestResponse {
    init?(json: JSON) {
        self.init(withJSON: json)
    }
}
