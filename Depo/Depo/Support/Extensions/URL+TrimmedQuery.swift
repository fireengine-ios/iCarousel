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
}
