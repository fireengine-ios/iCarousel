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
    
    func prepareHtmlString(with content: String, hexColor: String) -> String {
        var htmlString = content
        htmlString = "<style>" +
                "html *" +
                "{" +
                "color: \(hexColor)"  +
                "}</style> \(content)"
        return htmlString
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
    
    var isHTMLString: Bool {
        let htmlTagRegex = try! NSRegularExpression(pattern: "<[^>]+>")
        let range = NSRange(location: 0, length: self.utf16.count)
        return htmlTagRegex.firstMatch(in: self, range: range) != nil
    }
    
    var getAsHtml: NSAttributedString  {
        if let data = self.data(using: String.Encoding.unicode, allowLossyConversion: true) {
          let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
          ]
          if let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) {
            
//              attributedString.setBaseColor(baseColor: AppColor.label.color)
//              attributedString.setBaseFont(baseFont: .appFont(.regular, size: 12))
            // Assign attributed string to attribute of your choice
            return attributedString
          }
        }
        return NSAttributedString(string: "")
    }
    
    var getAsHtmldarkMode: NSAttributedString  {
        if let data = self.data(using: String.Encoding.unicode, allowLossyConversion: true) {
          let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
          ]
          if let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) {
            
              attributedString.setBaseColor(baseColor: AppColor.label.color)
              attributedString.setBaseFont(baseFont: .appFont(.regular, size: 12))
            // Assign attributed string to attribute of your choice
            return attributedString
          }
        }
        return NSAttributedString(string: "")
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
    
    var firstLine: String {
        return components(separatedBy: .newlines).first ?? ""
    }
    
    var removeFirstLine: String {
        var element = components(separatedBy: .newlines)
        element.removeFirst()
        return element.joined()
    }
}

extension String {
    private var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }

    public func convertHtmlToAttributedStringWithCSS(font: UIFont?, csscolor: String, lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)"
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error)
            return nil
        }
    }
}
