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
    func toInt() -> Int? {
        guard self < Double(Int.max), self > Double(Int.min) else {
            return nil
        }
        return Int(self)
    }
}
