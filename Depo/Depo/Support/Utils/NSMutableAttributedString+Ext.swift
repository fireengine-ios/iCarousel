//
//  NSMUta.swift
//  Depo
//
//  Created by yilmaz edis on 7.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

extension NSMutableAttributedString {
    /// Replaces the base font (typically Times) with the given font, while preserving traits like bold and italic
    func setBaseColor(baseColor: UIColor) {
        let wholeRange = NSRange(location: 0, length: length)
        beginEditing()
        enumerateAttribute(.font, in: wholeRange, options: []) { object, range, _ in
            self.removeAttribute(.foregroundColor, range: range)
            self.addAttribute(.foregroundColor, value: baseColor, range: range)
        }
        endEditing()
    }
    
    /// Replaces the base font (typically Times) with the given font, while preserving traits like bold and italic
    func setBaseFont(baseFont: UIFont, preserveFontSizes: Bool = false) {
        let baseDescriptor = baseFont.fontDescriptor
        let wholeRange = NSRange(location: 0, length: length)
        beginEditing()
        enumerateAttribute(.font, in: wholeRange, options: []) { object, range, _ in
            guard let font = object as? UIFont else { return }
            // Instantiate a font with our base font's family, but with the current range's traits
            let traits = font.fontDescriptor.symbolicTraits
            guard let descriptor = baseDescriptor.withSymbolicTraits(traits) else { return }
            let newSize = preserveFontSizes ? descriptor.pointSize : baseDescriptor.pointSize
            let newFont = UIFont(descriptor: descriptor, size: newSize)
            self.removeAttribute(.font, range: range)
            self.addAttribute(.font, value: newFont, range: range)
        }
        endEditing()
    }
}
