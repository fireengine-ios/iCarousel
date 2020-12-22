//
//  Text+Size.swift
//  Depo_LifeTech
//
//  Created by 12345 on 10.12.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

/// http://stackoverflow.com/questions/30450434/figure-out-size-of-uilabel-based-on-string-in-swift
/// label way: https://stackoverflow.com/a/39426425/5893286

extension String {
    func height(for width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: maxSize, options: .usesLineFragmentOrigin,
                                            attributes: [.font: font], context: nil)
        return boundingBox.height
    }
    
    func width(for height: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: maxSize, options: .usesLineFragmentOrigin,
                                            attributes: [.font: font], context: nil)
        return boundingBox.width
    }
}

extension NSAttributedString {
    func height(for width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.height
    }
    
    func width(for height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.width
    }
}

/// Design for a string and its substring inside one UILabel
extension NSAttributedString {
    static func attributedText(text: String, word: String, textFont: UIFont, wordFont: UIFont) -> NSAttributedString {
        let textAttrs: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.lrBrownishGrey, .font: textFont]
        let wordAttrs: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.black, .font: wordFont]
        
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttributes(textAttrs, range: NSRange(location: 0, length: text.count))
        
        let wordRange = (text as NSString).range(of: word)
        attrString.addAttributes(wordAttrs, range: wordRange)
        
        return attrString
    }
}
