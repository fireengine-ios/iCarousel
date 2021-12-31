//
//  TextRecognitionService.swift
//  Depo
//
//  Created by Hady on 12/27/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

class TextRecognitionService {
    let remoteService: RemoteTextRecognitionService = RemoteTextRecognitionService()

    func process(fileUUID: String, image: UIImage,
                 completion: @escaping ([RecognizedText]) -> Void,
                 dispatchQueue: DispatchQueue = .main) {
        remoteService.process(fileUUID: fileUUID) { [weak self] response in
            DispatchQueue.global().async {
                let result = self?.mapRemoteResponse(response, image: image) ?? []
                dispatchQueue.async {
                    completion(result)
                }
            }
        }
    }

    private func mapRemoteResponse(_ response: RemoteTextRecognitionModel?, image: UIImage) -> [RecognizedText] {
        guard let response = response else { return [] }

        let remoteImageSize = CGSize(width: response.width, height: response.height)
        func mapX(_ x: Int) -> CGFloat { image.size.width  * CGFloat(x) / remoteImageSize.width }
        func mapY(_ y: Int) -> CGFloat { image.size.height * CGFloat(y) / remoteImageSize.height }

        return response
            .words
            .map { word in
                RecognizedText(text: word.text, bounds: RecognizedText.Bounds(
                    topLeft: CGPoint(x: mapX(word.x1), y: mapY(word.y1)),
                    topRight: CGPoint(x: mapX(word.x2), y: mapY(word.y2)),
                    bottomRight: CGPoint(x: mapX(word.x3), y: mapY(word.y3)),
                    bottomLeft: CGPoint(x: mapX(word.x4), y: mapY(word.y4))
                ))
            }
    }
}
