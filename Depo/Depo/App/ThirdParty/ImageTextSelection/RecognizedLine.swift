//
//  RecognizedLine.swift
//  TextSelection
//
//  Created by Hady on 12/8/21.
//

import CoreGraphics

public struct RecognizedLine {
    let words: [RecognizedText]
    let bounds: TextBounds
    let text: String
    let height: CGFloat

    init(words: [RecognizedText], bounds: TextBounds, text: String? = nil) {
        self.words = words
        self.bounds = bounds
        self.text = text ?? words.map { $0.text }.joined(separator: " ")
        self.height = CGPointDistance(from: bounds.topLeft, to: bounds.bottomLeft)
    }

    var firstWord: RecognizedText {
        return words.first!
    }

    var lastWord: RecognizedText {
        return words.last!
    }
}
