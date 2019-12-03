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
    mutating func removeValueSafely(forKey key: Key) {
        if keys.contains(key) {
            removeValue(forKey: key)
        } else {
            assertionFailure()
        }
    }
}
