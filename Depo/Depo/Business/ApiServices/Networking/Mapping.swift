//
//  Mapping.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias Map = JsonMap & DataMap & DataMapArray

// MARK: - JsonMap

protocol JsonMap {
    init?(json: JSON)
}

// MARK: - DataMap

protocol DataMap {
    init?(data: Data)
}
extension DataMap where Self: JsonMap {
    init?(data: Data) {
        self.init(json: JSON(data))
    }
}

// MARK: - DataMapArray

protocol DataMapArray {
    static func array(from data: Data) -> [Self]
}
extension DataMapArray where Self: JsonMap {
    static func array(from data: Data) -> [Self] {
        let jsonArray = JSON(data)
        return jsonArray.array?.compactMap { json in
            self.init(json: json)
        } ?? []
    }
}

// MARK: - MapToJSON

protocol MapToJSON {
    var json: [String: Any] { get }
}
extension MapToJSON {
    var json: [String: Any] {
        let bookMirror = Mirror(reflecting: self)
        var dict: [String: Any] = [:]
        for (name, value) in bookMirror.children {
            guard let name = name else { continue }
            dict[name] = unwrapOptional(any: value)
        }
        return dict
    }
    
    private func unwrapOptional(any: Any) -> Any {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }
        if mi.children.count == 0 {
            return NSNull()
        }
        let (_, some) = mi.children.first!
        return some
    }
}
