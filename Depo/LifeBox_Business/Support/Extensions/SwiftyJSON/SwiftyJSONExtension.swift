//
//  SwiftyJSONExtension.swift
//  Depo
//
//  Created by Alexander Gurin on 7/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON


let Milisec: Double = 1000.0

extension JSON {
    
    public var date: Date? {
        get {
            guard let doubleTime = self.number?.doubleValue else {
                if let string = self.string {
                    if let doubleValue = Double(string) {
                        return Date(timeIntervalSince1970: doubleValue / Milisec)
                    }
                }
                
                return  nil
            }
            return Date(timeIntervalSince1970: doubleTime / Milisec)
        }
        set {
            if let newValue = newValue {
                let doubleTime = newValue.timeIntervalSince1970 * Milisec
                self.object = NSNumber(value: doubleTime)
            } else {
                self.object = NSNull()
            }
        }
    }
    
    public var boolFromString: Bool? {
        get {
            guard let boolString = self.string else {
                return nil
            }
            if boolString == "true" {
                return true
            } else if boolString == "false" {
                return false
            }
            return nil
        }
    }
    
    var bytesType: BytesType? {
        guard let string = self.string, let bytesType = BytesType(rawValue: string) else {
            return nil
        }
        return bytesType
    }
    
//    public var dateValue: Date {
//        get {
//            return self.numberValue.doubleValue
//        }
//        set {
//            self.object = NSNumber(value: newValue)
//        }
//    }
}
