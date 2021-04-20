//
//  String+CyrillicSorting.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 1/24/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

extension String {
    func compareWithCyrillicPriority(with string: String) -> Bool {
        let firstUnicodes = unicodeScalars
        let secondUnicodes = string.unicodeScalars
        var firstCounter = firstUnicodes.startIndex
        var secondCounter = secondUnicodes.startIndex
        
        while firstCounter != firstUnicodes.endIndex, secondCounter != secondUnicodes.endIndex {
            switch firstUnicodes[firstCounter].compareWithCyrillicPriority(with: secondUnicodes[secondCounter]) {
            case .orderedAscending:
                return false
            case .orderedDescending:
                return true
            default:
                break
            }
            
            firstCounter = firstUnicodes.index(after: firstCounter)
            secondCounter = secondUnicodes.index(after: secondCounter)
        }
        
        // if a string shorter its priority should be higher
        return count < string.count
    }
}

extension Unicode.Scalar {
    enum AlphabeticType {
        case cyrillic, latin, neutral
    }
    
    private static let latinRanges    = [0x41...0x5A, 0x61...0x7A, 0xC0...0xFF, 0x100...0x17F]
    private static let cyrillicRanges = [0x400...0x4FF, 0x500...0x52F]
    
    func compareWithCyrillicPriority(with unicode: Unicode.Scalar) -> ComparisonResult {
        if self == unicode {
            return .orderedSame
        }
        
        let firstAlphabeticType = getAlphabeticType()
        let secondAlphabeticType = unicode.getAlphabeticType()
        
        if firstAlphabeticType == secondAlphabeticType {
            if self == unicode {
                return .orderedSame
            } else if self > unicode {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        }
        
        if firstAlphabeticType == .cyrillic {
            return .orderedDescending
        }
        
        if secondAlphabeticType == .cyrillic {
            return .orderedAscending
        }
        
        if firstAlphabeticType == .latin {
            return .orderedDescending
        }
        
        if secondAlphabeticType == .latin {
            return .orderedAscending
        }
        
        return .orderedSame
    }
    
    func getAlphabeticType() -> AlphabeticType {
        if isCyrillic() {
            return .cyrillic
        } else if isLatin() {
            return .latin
        } else {
            return .neutral
        }
    }
    
    func isCyrillic() -> Bool {
        return isInRanges(ranges: Unicode.Scalar.cyrillicRanges)
    }
    
    func isLatin() -> Bool {
        return isInRanges(ranges: Unicode.Scalar.latinRanges)
    }
    
    func isInRanges(ranges: [CountableClosedRange<Int>]) -> Bool {
        for r in ranges {
            if r ~= Int(value) {
                return true
            }
        }
        
        return false
    }
}
