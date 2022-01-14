//
//  TextRecognitionProcessor.swift
//  Depo
//
//  Created by Hady on 1/13/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

struct TextRecognitionProcessor {
    private let remoteWords: [RecognizedText]?
    private let recognizedLines: [RecognizedLine]?

    // remote words
    init(remoteWords: [RecognizedText]) {
        self.remoteWords = remoteWords
        self.recognizedLines = nil
    }

    // on-device
    init(recognizedLines: [RecognizedLine]) {
        self.remoteWords = nil
        self.recognizedLines = recognizedLines
    }

    func sortedLines() -> [RecognizedLine] {
        let lines: [RecognizedLine]

        if let remoteWords = remoteWords {
            lines = recognizeRemoteLines(words: remoteWords)
        }
        else if let recognizedLines = recognizedLines {
            lines = recognizedLines
        }
        else {
            assertionFailure("")
            lines = []
        }

        return lines.sorted {
            $0.bounds.topLeft.y < $1.bounds.topLeft.y && $0.bounds.topLeft.x < $1.bounds.topLeft.x
        }
    }

    private func recognizeRemoteLines(words: [RecognizedText]) -> [RecognizedLine] {
        var result: [RecognizedLine] = []
        var processed: [RecognizedText: Bool] = [:]

        for word in words {
            guard processed[word] != true else { continue }
            processed[word] = true

            var wordsInCurrentLine = [word]

            var nextWord = nearestWord(after: word, in: words)
            while let next = nextWord, processed[next] != true {
                wordsInCurrentLine.append(next)
                processed[next] = true
                nextWord = nearestWord(after: next, in: words)
            }

            var previousWord = nearestWord(before: word, in: words)
            while let previous = previousWord, processed[previous] != true {
                wordsInCurrentLine.insert(previous, at: 0)
                processed[previous] = true
                previousWord = nearestWord(before: previous, in: words)
            }

            let firstWord = wordsInCurrentLine.first!
            let lastWord = wordsInCurrentLine.last!
            result.append(
                RecognizedLine(
                    words: wordsInCurrentLine,
                    bounds: TextBounds(
                        topLeft: firstWord.bounds.topLeft,
                        topRight: lastWord.bounds.topRight,
                        bottomRight: lastWord.bounds.bottomRight,
                        bottomLeft: firstWord.bounds.bottomLeft
                    )
                )
            )
        }

        return result
    }

    private func nearestWord(after word: RecognizedText, in words: [RecognizedText]) -> RecognizedText? {
        var result: RecognizedText?
        var leastTopDistance: CGFloat!
        var leastBottomDistance: CGFloat!
        for aWord in words {
            guard isOnSameLine(first: word, second: aWord) else { continue }

            let topDistance = CGPointDistance(from: word.bounds.topRight, to: aWord.bounds.topLeft)
            let bottomDistance = CGPointDistance(from: word.bounds.bottomRight, to: aWord.bounds.bottomLeft)
            if leastTopDistance == nil {
                leastTopDistance = topDistance
                leastBottomDistance = bottomDistance
                result = aWord
            } else if topDistance < leastTopDistance || bottomDistance < leastBottomDistance {
                leastTopDistance = topDistance
                leastBottomDistance = bottomDistance
                result = aWord
            }
        }

        return result
    }

    private func nearestWord(before word: RecognizedText, in words: [RecognizedText]) -> RecognizedText? {
        var result: RecognizedText?
        var leastTopDistance: CGFloat!
        var leastBottomDistance: CGFloat!
        for aWord in words {
            guard isOnSameLine(first: aWord, second: word) else { continue }

            let topDistance = CGPointDistance(from: word.bounds.topLeft, to: aWord.bounds.topRight)
            let bottomDistance = CGPointDistance(from: word.bounds.bottomLeft, to: aWord.bounds.bottomRight)
            if leastTopDistance == nil {
                leastTopDistance = topDistance
                leastBottomDistance = bottomDistance
                result = aWord
            } else if topDistance < leastTopDistance || bottomDistance < leastBottomDistance {
                leastTopDistance = topDistance
                leastBottomDistance = bottomDistance
                result = aWord
            }
        }

        return result
    }

    private func isOnSameLine(first: RecognizedText, second: RecognizedText) -> Bool {
        let wordHeight = CGPointDistance(from: first.bounds.topRight, to: first.bounds.bottomRight)

        let minY = first.bounds.topRight.y - wordHeight / 2
        let maxY = first.bounds.bottomRight.y + wordHeight / 2
        let horizontalSpacing = CGPointDistance(from: first.bounds.midRight, to: second.bounds.midLeft)
        return second.bounds.topLeft.y >= minY && second.bounds.bottomLeft.y <= maxY && horizontalSpacing <= wordHeight / 1.5
    }
}
