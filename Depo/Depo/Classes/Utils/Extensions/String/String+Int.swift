//
//  String+Int.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/23/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

extension String {
    var int64: Int64? {
        return Int64(self)
    }
    
    var int: Int? {
        return Int(self)
    }
}
