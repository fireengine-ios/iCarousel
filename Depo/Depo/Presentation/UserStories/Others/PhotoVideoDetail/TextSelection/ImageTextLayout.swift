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
    var imageViewSize: CGSize = .zero
    let recognizedWords: [RecognizedText]
    private(set) var sortedWords: [RecognizedText] = []
    private(set) var sortedLines: [RecognizedLine] = []
//    private(set) var sortedBlocks: [RecognizedBlock] = []
    private(set) var isReady = false

    private var imageSize: CGSize { image.size }

    init(image: UIImage, recognizedWords: [RecognizedText]) {
        self.image = image
        self.recognizedWords = recognizedWords
        prepareRecognizedWords { }
    }

    // MARK: - Hit Test & Indices
    
    func findFirstIndex(predicate: (RecognizedText) -> Bool) -> ImageTextSelectionIndex? {
        for (lineIndex, line) in sortedLines.enumerated() {
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

        for (lineIndex, line) in sortedLines.enumerated() {
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
                let lastWordIndex = sortedLines[line].words.count - 1
                upperBound = ImageTextSelectionIndex(line: line, word: lastWordIndex)
            }

            result.append(lowerBound...upperBound)
            lowerBound = ImageTextSelectionIndex(line: line + 1, word: 0)
        }

        return result
    }

    func getWords(inLine line: Int, startIndex: Int, endIndex: Int) -> ArraySlice<RecognizedText> {
        return sortedLines[line].words[startIndex...endIndex]
    }

    func word(at index: ImageTextSelectionIndex) -> RecognizedText {
        return sortedLines[index.line].words[index.word]
    }

    var startIndex: ImageTextSelectionIndex? {
        guard sortedLines.count > 0 else { return nil }
        return ImageTextSelectionIndex(line: 0, word: 0)
    }

    var endIndex: ImageTextSelectionIndex? {
        guard sortedLines.count > 0 else { return nil }
        let lastWordIndex = sortedLines.last!.words.count - 1
        return ImageTextSelectionIndex(line: sortedLines.count - 1, word: lastWordIndex)
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

    // MARK: - Structuring & Storting

    private func prepareRecognizedWords(completion: @escaping () -> Void) {
//        DispatchQueue.global().async {
            self.process()
            self.isReady = true
//        }
    }

    private func process() {
        sortedLines = getSortedLines()
        print("------------lines------------")
        for line in sortedLines {
            print(line.words.map { $0.text }.joined(separator: " "))
        }

        sortedWords = sortedLines.reduce(into: []) { partialResult, line in
            partialResult.append(contentsOf: line.words)
        }

//        let blocks = getSortedBlocks(for: lines)

//        sortedBlocks = blocks
//        sortedWords = blocks.reduce(into: []) { partialResult, block in
//            let wordsInBlock: [RecognizedText] = block.lines.reduce(into: []) { partialResult, line in
//                partialResult.append(contentsOf: line.words)
//            }
//            partialResult.append(contentsOf: wordsInBlock)
//        }
//
//        for block in blocks {
//            print("-------block start--------")
//            for line in block.lines {
//                print(line.words.map { $0.text }.joined(separator: " "))
//            }
//        }

        print("ok")
    }

    private func getSortedLines() -> [RecognizedLine] {
        var result: [RecognizedLine] = []
        var processed: [RecognizedText: Bool] = [:]

        for word in recognizedWords {
            guard processed[word] != true else { continue }
            processed[word] = true

            var wordsInCurrentLine = [word]

            var nextWord = getNextWord(after: word)
            while let next = nextWord, processed[next] != true {
                wordsInCurrentLine.append(next)
                processed[next] = true
                nextWord = getNextWord(after: next)
            }

            var previousWord = getPreviousWord(before: word)
            while let previous = previousWord, processed[previous] != true {
                wordsInCurrentLine.insert(previous, at: 0)
                processed[previous] = true
                previousWord = getPreviousWord(before: previous)
            }

            let line = RecognizedLine(words: wordsInCurrentLine)
            result.append(line)
        }

        return result.sorted {
            $0.firstWord.bounds.topLeft.y < $1.firstWord.bounds.topLeft.y &&
            $0.firstWord.bounds.topLeft.x < $1.firstWord.bounds.topLeft.x
        }

    }

    private func getNextWord(after word: RecognizedText) -> RecognizedText? {
        return recognizedWords.first {
            return $0 != word && isWord($0, continuationTo: word)
        }
    }

    private func getPreviousWord(before word: RecognizedText) -> RecognizedText? {
        return recognizedWords.first {
            return $0 != word && isWord(word, continuationTo: $0)
        }
    }

    private func isWord(_ word: RecognizedText, continuationTo other: RecognizedText) -> Bool {
        let wordHeight = CGPointDistance(from: other.bounds.topRight, to: other.bounds.bottomRight)
        let threshold = wordHeight / 2
        return isPoint(other.bounds.topRight, continuationTo: word.bounds.topLeft, threshold: threshold)
            && isPoint(other.bounds.bottomRight, continuationTo: word.bounds.bottomLeft, threshold: threshold)
    }

    private func isPoint(_ point: CGPoint, continuationTo other: CGPoint, threshold: CGFloat) -> Bool {
        return point.x <= other.x + threshold && point.x >= other.x - threshold
            && point.y <= other.y + threshold && point.y >= other.y - threshold
    }

    private func getSortedBlocks(for lines: [RecognizedLine]) -> [RecognizedBlock] {
        func nextLine(after lineIndex: Int) -> Int? {
            let line = lines[lineIndex]

            var result: Int?
            var smallestDistance: CGFloat?
            for (index, other) in lines.enumerated() {
                guard index != lineIndex else { continue }
                guard other.bounds.topLeft.x >= line.bounds.topLeft.x && other.bounds.topLeft.x < line.bounds.topRight.x
                else { continue }

                let distance = other.firstWord.bounds.topLeft.y - line.firstWord.bounds.bottomLeft.y
                if distance >= 0 && distance <= line.height {
                    if smallestDistance == nil || distance < smallestDistance! {
                        result = index
                        smallestDistance = distance
                    }
                }
            }

            return result
        }

        func previousLine(before lineIndex: Int) -> Int? {
            let line = lines[lineIndex]

            var result: Int?
            var smallestDistance: CGFloat?
            for (index, other) in lines.enumerated() {
                guard index != lineIndex else { continue }
                guard other.bounds.topLeft.x >= line.bounds.topLeft.x && other.bounds.topLeft.x < line.bounds.topRight.x                else { continue }

                let distance = line.firstWord.bounds.topLeft.y - other.firstWord.bounds.bottomLeft.y
                if distance >= 0 && distance <= line.height {
                    if smallestDistance == nil || distance < smallestDistance! {
                        result = index
                        smallestDistance = distance
                    }
                }
            }

            return result
        }

        var processed: [Int: Bool] = [:]
        var result: [RecognizedBlock] = []
        for (index, line) in lines.enumerated() {
            guard processed[index] != true else { continue }
            processed[index] = true

            var linesInCurrentBlock = [line]

            var nextLineIndex = nextLine(after: index)
            while let nextIndex = nextLineIndex, processed[nextIndex] != true {
                linesInCurrentBlock.append(lines[nextIndex])
                processed[nextIndex] = true
                nextLineIndex = nextLine(after: nextIndex)
            }

            var previousLineIndex = previousLine(before: index)
            while let previousIndex = previousLineIndex, processed[previousIndex] != true {
                linesInCurrentBlock.insert(lines[previousIndex], at: 0)
                processed[previousIndex] = true
                previousLineIndex = previousLine(before: previousIndex)
            }

            let block = RecognizedBlock(lines: linesInCurrentBlock)
            result.append(block)
        }

        return result.sorted {
            $0.firstLine.firstWord.bounds.topLeft.y < $1.firstLine.firstWord.bounds.topLeft.y
//            &&
//            $0.firstLine.firstWord.bounds.topLeft.x < $1.firstLine.firstWord.bounds.topLeft.x
        }
    }
}
