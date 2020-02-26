//
//  Int64+Bytes.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/23/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

extension Int64 {
    var bytesString: String {
        return ByteCountFormatter.string(fromByteCount: self, countStyle: .binary)
    }
    
    var intValue: Int {
        return Int(exactly: self) ?? NSNumber(value: self).intValue
    }
    
}
