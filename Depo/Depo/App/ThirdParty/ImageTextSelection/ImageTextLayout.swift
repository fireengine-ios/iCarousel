//
//  ImageTextLayout.swift
//  TextSelection
//
//  Created by Hady on 12/8/21.
//

import Foundation
import UIKit

final class ImageTextLayout {
    let image: UIImage
    let lines: [RecognizedLine]
    let words: [RecognizedText]

    var imageViewSize: CGSize = .zero

    private var imageSize: CGSize { image.size }

    init(image: UIImage, lines: [RecognizedLine], words: [RecognizedText]) {
        self.image = image
        self.lines = lines
        self.words = words
    }

    // MARK: - Hit Test & Indices

    func findFirstIndex(predicate: (RecognizedText) -> Bool) -> ImageTextSelectionIndex? {
        for (lineIndex, line) in lines.enumerated() {
            for (wordIndex, word) in line.words.enumerated() {
                if predicate(word) {
                    return ImageTextSelectionIndex(line: lineIndex, word: wordIndex)
                }
            }
        }

        return nil
    }

    func findLastIndex(predicate: (RecognizedText) -> Bool) -> ImageTextSelectionIndex? {
        var result: ImageTextSelectionIndex?

        for (lineIndex, line) in lines.enumerated() {
            for (wordIndex, word) in line.words.enumerated() {
                if predicate(word) {
                    result = ImageTextSelectionIndex(line: lineIndex, word: wordIndex)
                }
            }
        }

        return result
    }

    func rangesOfLinesBetween(first: ImageTextSelectionIndex,
                              last: ImageTextSelectionIndex) -> [ClosedRange<ImageTextSelectionIndex>] {
        var result: [ClosedRange<ImageTextSelectionIndex>] = []

        var lowerBound = first
        while lowerBound.line <= last.line {
            let line = lowerBound.line
            let upperBound: ImageTextSelectionIndex
            if line == last.line {
                upperBound = last
            } else {
                let lastWordIndex = lines[line].words.count - 1
                upperBound = ImageTextSelectionIndex(line: line, word: lastWordIndex)
            }

            result.append(lowerBound...upperBound)
            lowerBound = ImageTextSelectionIndex(line: line + 1, word: 0)
        }

        return result
    }

    func getWords(inLine line: Int, startIndex: Int, endIndex: Int) -> ArraySlice<RecognizedText> {
        return lines[line].words[startIndex...endIndex]
    }

    func word(at index: ImageTextSelectionIndex) -> RecognizedText {
        return lines[index.line].words[index.word]
    }

    var startIndex: ImageTextSelectionIndex? {
        guard lines.count > 0 else {
            return nil
        }

        return ImageTextSelectionIndex(line: 0, word: 0)
    }

    var endIndex: ImageTextSelectionIndex? {
        guard let lastLine = lines.last else {
            return nil
        }

        let lastLineIndex = lines.count - 1
        let lastWordIndex = lastLine.words.count - 1
        return ImageTextSelectionIndex(line: lastLineIndex, word: lastWordIndex)
    }

    // MARK: - Size & Position Conversion

    func imagePoint(for viewPoint: CGPoint) -> CGPoint {
        let resolutionView = imageViewSize.width / imageViewSize.height
        let resolutionImage = imageSize.width / imageSize.height

        var scale1: CGFloat
        var scale2: CGFloat
        if resolutionView > resolutionImage {
            scale1 = imageViewSize.height / imageSize.height
            scale2 = imageSize.height / imageViewSize.height
        } else {
            scale1 = imageViewSize.width / imageSize.width
            scale2 = imageSize.width / imageViewSize.width
        }

        let imageWidthScaled = imageSize.width * scale1
        let imageHeightScaled = imageSize.height * scale1
        let imagePointXScaled = (imageViewSize.width - imageWidthScaled) / 2
        let imagePointYScaled = (imageViewSize.height - imageHeightScaled) / 2

        let x = (viewPoint.x - imagePointXScaled) * scale2
        let y = (viewPoint.y - imagePointYScaled) * scale2

        return CGPoint(x: x, y: y)
    }

    func imageViewPoint(for imagePoint: CGPoint) -> CGPoint {
        let resolutionView = imageViewSize.width / imageViewSize.height
        let resolutionImage = imageSize.width / imageSize.height

        var scale: CGFloat
        if resolutionView > resolutionImage {
            scale = imageViewSize.height / imageSize.height
        } else {
            scale = imageViewSize.width / imageSize.width
        }

        let imageWidthScaled = imageSize.width * scale
        let imageHeightScaled = imageSize.height * scale
        let imagePointXScaled = (imageViewSize.width - imageWidthScaled) / 2
        let imagePointYScaled = (imageViewSize.height - imageHeightScaled) / 2

        let x = imagePointXScaled + imagePoint.x * scale
        let y = imagePointYScaled + imagePoint.y * scale

        return CGPoint(x: x, y: y)
    }

    func imageViewDimension(for imageDimension: CGFloat) -> CGFloat {
        let resolutionView = imageViewSize.width / imageViewSize.height
        let resolutionImage = imageSize.width / imageSize.height

        var scale: CGFloat
        if resolutionView > resolutionImage {
            scale = imageViewSize.height / imageSize.height
        } else {
            scale = imageViewSize.width / imageSize.width
        }

        return imageDimension * scale
    }
}
