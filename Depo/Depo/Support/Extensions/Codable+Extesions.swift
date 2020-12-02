//
//  Codable+Extesions.swift
//  Depo
//
//  Created by Andrei Novikau on 11/11/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}
