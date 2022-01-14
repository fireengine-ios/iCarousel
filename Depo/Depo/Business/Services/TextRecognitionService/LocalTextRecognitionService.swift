//
//  LocalTextRecognitionService.swift
//  Depo
//
//  Created by Hady on 1/13/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import Vision
import UIKit

@available(iOS 13.0, *)
final class LocalTextRecognitionService {
    func process(image: UIImage, completion: @escaping ([RecognizedLine]) -> Void) {
        guard let cgImage = image.cgImage else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNRecognizeTextRequest { [weak self] request, error in
                self?.recognizeTextHandler(image: image, request: request, error: error, completion: completion)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage)
            do {
                try handler.perform([request])
            } catch {
                completion([])
                debugLog("Unable to perform text recognition request. \(error)")
            }
        }
    }

    func recognizeTextHandler(image: UIImage, request: VNRequest, error: Error?,
                              completion: ([RecognizedLine]) -> Void) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            completion([])
            return
        }

        let recognizedLines = observations.compactMap { observation in
            return observation.topCandidates(1).first
        }

        var lines: [RecognizedLine] = []
        for line in recognizedLines {
            let string = line.string
            print("localLine", string)

            var ranges: [Range<String.Index>] = []
            guard var currentWordStartIndex = string.indices.first else {
                continue
            }

            for index in string.indices {
                let nextIndex = string.index(after: index)
                if string[index] == " " || nextIndex == string.endIndex {
                    ranges.append(currentWordStartIndex..<nextIndex)
                    currentWordStartIndex = nextIndex
                }
            }

            var wordsInLine: [RecognizedText] = []

            for range in ranges {
                guard let boxObservation = try? line.boundingBox(for: range) else { continue }

                wordsInLine.append(
                    RecognizedText(
                        text: string[range].trimmingCharacters(in: .whitespaces),
                        bounds: boxObservation.normalizedBounds(imageSize: image.size)
                    )
                )
            }

            guard let boxObservation = try? line.boundingBox(for: string.startIndex..<string.endIndex) else {
                continue
            }

            lines.append(RecognizedLine(
                words: wordsInLine,
                bounds: boxObservation.normalizedBounds(imageSize: image.size),
                text: string
            ))
        }

        completion(lines)
    }
}

private extension VNRectangleObservation {
    func normalizedBounds(imageSize: CGSize) -> TextBounds {
        var bottomLeft = self.bottomLeft
        var topLeft = self.topLeft
        var topRight = self.topRight
        var bottomRight = self.bottomRight

        bottomLeft.y = 1.0 - bottomLeft.y
        topLeft.y = 1.0 - topLeft.y
        topRight.y = 1.0 - topRight.y
        bottomRight.y = 1.0 - bottomRight.y

        let imageWidth = Int(imageSize.width)
        let imageHeight = Int(imageSize.height)
        bottomLeft = VNImagePointForNormalizedPoint(bottomLeft, imageWidth, imageHeight)
        topLeft = VNImagePointForNormalizedPoint(topLeft, imageWidth, imageHeight)
        topRight = VNImagePointForNormalizedPoint(topRight, imageWidth, imageHeight)
        bottomRight = VNImagePointForNormalizedPoint(bottomRight, imageWidth, imageHeight)

        return TextBounds(
            topLeft: topLeft, topRight: topRight,
            bottomRight: bottomRight, bottomLeft: bottomLeft
        )
    }
}
