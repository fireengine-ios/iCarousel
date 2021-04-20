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
        let range = start..<end
        return String(self[range])
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let currentString = self as NSString
        return currentString.appendingPathComponent(path)
    }
    
    func removingWhiteSpaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }

    func removeAllPreFileExtentionBracketValues() -> String {
        var finalString = self
        var trimmedString = finalString
        while true {
            trimmedString = trimmedString.replacingOccurrences(of: "(?!^)(\\s{1}\\([\\d]+\\))+(?=\\.[\\w\\d]+$)", with: "", options: .regularExpression)
            if trimmedString == finalString {
                break
            }
            finalString = trimmedString
        }
        return finalString
    }
    
    /// code https://stackoverflow.com/a/31727051/5893286
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
}
