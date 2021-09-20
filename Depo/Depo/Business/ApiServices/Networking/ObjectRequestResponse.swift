//
//  ObjectRequestResponse.swift
//  Depo_LifeTech
//
//  Created by Maksim Vakula on 9/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ObjectFromRequestResponse: AnyObject {
    init(json: Data?, headerResponse: HTTPURLResponse?)
    func mapping()
}

class ObjectRequestResponse: NSObject, ObjectFromRequestResponse {
    var json: JSON?
    var response: HTTPURLResponse?
    var jsonString: String?
    private var data: Data?
    
    required init(json: Data?, headerResponse: HTTPURLResponse?) {
        self.data = json

        if let data = json {
            let jsonFromData = JSON(data)
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

    func decodedResponse<T: Decodable>(_ type: T.Type) throws -> T {
        guard let data = self.data else {
            throw DecodingError.noData()
        }
        return try JSONDecoder().decode(type, from: data)
    }
}

extension JsonMap where Self: ObjectRequestResponse {
    init?(json: JSON) {
        self.init(withJSON: json)
    }
}

extension Optional where Wrapped == ObjectFromRequestResponse {
    func decodedResponse<T: Decodable>(_ type: T.Type) throws -> T {
        guard let instance = self as? ObjectRequestResponse else {
            throw DecodingError.noData()
        }

        return try instance.decodedResponse(type)
    }
}

extension DecodingError {
    static func noData() -> DecodingError {
        DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))
    }
}
