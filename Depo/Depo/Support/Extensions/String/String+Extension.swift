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
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont.TurkcellSaturaBolFont(size: 28)]
        
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
            text.addAttribute(.foregroundColor, value: AppColor.blackColor.color, range: NSRange(location: 0, length: text.length))
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
    
    var nonEmptyString: String? {
        self.isEmpty ? nil : self
    }
}

extension Optional where Wrapped == String {
    var hasCharacters: Bool {
        return self?.isEmpty == false
    }
}

//MARK: - path extension related

extension String {
    
    func getPathExtension() -> String? {
        guard let fileNameExtensionSlice = self.split(separator: ".").last else {
            return nil
        }
        return String(fileNameExtensionSlice)
    }
    
    func isPathExtensionGif() -> Bool {
        return getPathExtension()?.lowercased() == "gif"
    }
    
    var fileName: String {
        (self as NSString).deletingPathExtension
    }
    
    func makeFileName(with fileExtension: String) -> String {
        [fileName, fileExtension].joined(separator: ".")
    }
}

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
