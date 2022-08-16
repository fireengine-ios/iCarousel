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

extension Double {
    static let twoFractionDigits: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "tr-TR")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    var formatted: String {
        return Double.twoFractionDigits.string(for: self) ?? ""
    }
}
