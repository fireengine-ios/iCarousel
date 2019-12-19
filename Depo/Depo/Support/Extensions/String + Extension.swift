//
//  String + Extension.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

extension String {
    
    func htmlAttributedForPrivacyPolicy(using font: UIFont) -> NSMutableAttributedString? {
        
        let boldFontAttribute = [NSAttributedStringKey.font: UIFont.TurkcellSaturaBolFont(size: 28)]
        
        do {
            let htmlCSSString = "<style>" +
                "html *" +
                "{" +
                "font-size: \(font.pointSize)pt !important;" +
                "font-family: \(font.familyName) !important;" +
            "}</style> \(self)"
            
            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            let text = try NSMutableAttributedString(data: data,
                                                     options: [.documentType: NSAttributedString.DocumentType.html,
                                                               .characterEncoding: String.Encoding.utf8.rawValue],
                                                     documentAttributes: nil)
            
            let range: NSRange = text.mutableString.range(of: TextConstants.privacyPolicyHeadLine, options: .caseInsensitive)
            text.addAttributes(boldFontAttribute, range: range)
            return text
        } catch {
            assertionFailure()
            return NSMutableAttributedString()
        }
    }
    
    var hasCharacters: Bool {
        return !self.isEmpty
    }
    
    var firstLetter: String {
        if let character = first {
            return String(describing: character).uppercased()
        }
        return ""
    }
}

extension Optional where Wrapped == String {
    var hasCharacters: Bool {
        return !(self?.isEmpty ?? true)
    }
}
