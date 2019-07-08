//
//  URL+TrimmedQuery.swift
//  Depo
//
//  Created by Konstantin on 10/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


extension URL {
    var byTrimmingQuery: URL? {
        if let substring = absoluteString.split(separator: "?").first {
            let stringValue = String(substring)
            return URL(string: stringValue)
        }
        return nil
    }
    
    var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        else {
            return nil
        }
        
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    func queryParameterValue(name: String) -> String? {
        return queryParameters?[name]
    }
    
    var isExpired: Bool {
        let expirationDateKey = "temp_url_expires"
        guard
            let expirationDateString = queryParameterValue(name: expirationDateKey),
            let expirationDate = Date.from(string: expirationDateString)
        else {
            return false
        }
        
        return true//Date() >= expirationDate
    }
}
