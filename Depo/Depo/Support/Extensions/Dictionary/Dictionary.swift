//
//  Dictionary.swift
//  Depo
//
//  Created by Alexander Gurin on 7/9/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

func + <K, V>(left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {
    
    var map = left
    
    for (k, v) in right {
        map[k] = v
    }
    return map
}

extension Dictionary {
    mutating func removeValueSafely(forKey key: Key) -> Value? {
        if keys.contains(key), self[key] != nil {
            return removeValue(forKey: key)
        } else {
            return nil
        }
    }
}

extension Dictionary where Key == AnyHashable, Value == Any {
    func toStringAny() -> [String: Any] {
        var dict = [String: Any]()
        self.forEach {
            if let key = $0.key as? String {
                dict[key] = $0.value
            }
        }
        return dict
    }
}
