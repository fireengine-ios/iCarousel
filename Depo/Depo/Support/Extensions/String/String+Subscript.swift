//
//  String+Subscript.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 12/5/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

extension String {

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (i: Int) -> String.Index {
        return self.index( self.startIndex, offsetBy: i)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let currentString = self as NSString
        return currentString.appendingPathComponent(path)
    }
    
    func removingWhiteSpaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func fileName() -> String {
        return NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent ?? ""
    }
    
    func fileExtension() -> String {
        return NSURL(fileURLWithPath: self).pathExtension ?? ""
    }

}
