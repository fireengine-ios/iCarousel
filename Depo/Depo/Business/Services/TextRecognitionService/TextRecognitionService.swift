//
//  TextRecognitionService.swift
//  Depo
//
//  Created by Hady on 12/27/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class TextRecognitionService {
    private let remoteService = RemoteTextRecognitionService()

    func process(fileUUID: String, image: UIImage,
                 completion: @escaping (ImageTextSelectionData?) -> Void,
                 completionDispatchQueue: DispatchQueue = .main) {
        remoteService.process(fileUUID: fileUUID) { response in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let response = response else {
                    completionDispatchQueue.async {
                        completion(nil)
                    }
                    return
                }

                let result = self.processRemoteResponse(response, image: image)
                completionDispatchQueue.async {
                    completion(result)
                }
            }
        }
    }

    private func processRemoteResponse(_ response: RemoteTextRecognitionModel?, image: UIImage) -> ImageTextSelectionData {
        guard let response = response else {
            return .empty
        }

        let recognizedWords = mapAndNormalizeRemoteResponse(response, image: image)
        let processor = TextRecognitionProcessor(remoteWords: recognizedWords)
        return ImageTextSelectionData(lines: processor.sortedLines())
    }

    private func mapAndNormalizeRemoteResponse(_ response: RemoteTextRecognitionModel, image: UIImage) -> [RecognizedText] {
        let remoteImageSize = CGSize(width: response.width, height: response.height)
        func mapX(_ x: Int) -> CGFloat { image.size.width  * CGFloat(x) / remoteImageSize.width }
        func mapY(_ y: Int) -> CGFloat { image.size.height * CGFloat(y) / remoteImageSize.height }

        return response
            .words
            .map { word in
                RecognizedText(text: word.text, bounds: TextBounds(
                    topLeft: CGPoint(x: mapX(word.x1), y: mapY(word.y1)),
                    topRight: CGPoint(x: mapX(word.x2), y: mapY(word.y2)),
                    bottomRight: CGPoint(x: mapX(word.x3), y: mapY(word.y3)),
                    bottomLeft: CGPoint(x: mapX(word.x4), y: mapY(word.y4))
                ))
            }
    }

    private func processLocalResult(lines: [RecognizedLine]) -> ImageTextSelectionData {
        let processor = TextRecognitionProcessor(recognizedLines: lines)
        return ImageTextSelectionData(lines: processor.sortedLines())
    }
}
