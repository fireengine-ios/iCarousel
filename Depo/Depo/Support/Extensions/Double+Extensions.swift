//
//  Double+Extensions.swift
//  Depo
//
//  Created by Konstantin Studilin on 17/12/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


extension Double {
    /**
     * loses the fractional part
     */
    var asInt: Int? {
        guard self < Double(Int.max), self > Double(Int.min) else {
            return nil
        }
        return Int(self)
    }
    
    var asInt64: Int64? {
        guard self < Double(Int64.max), self > Double(Int64.min) else {
            return nil
        }
        return Int64(self)
    }
}
