//
//  RecognizedLine.swift
//  TextSelection
//
//  Created by Hady on 12/8/21.
//

import CoreGraphics

struct RecognizedLine {
    let words: [RecognizedText]
    let bounds: RecognizedText.Bounds

    init(words: [RecognizedText]) {
        self.words = words
        self.bounds = RecognizedText.Bounds(
            topLeft: words.first!.bounds.topLeft,
            topRight: words.last!.bounds.topRight,
            bottomRight: words.last!.bounds.bottomRight,
            bottomLeft: words.first!.bounds.bottomLeft
        )
    }

    var firstWord: RecognizedText {
        return words.first!
    }

    var lastWord: RecognizedText {
        return words.last!
    }

    var height: CGFloat {
        return CGPointDistance(from: firstWord.bounds.topLeft, to: firstWord.bounds.bottomLeft)
    }
}
