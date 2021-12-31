//
//  RecognizedText.swift
//  TextSelection
//
//  Created by Hady on 12/3/21.
//

import Foundation
import CoreGraphics

public struct RecognizedText {
    public let text: String
    public var bounds: RecognizedText.Bounds
}

public extension RecognizedText {
    struct Bounds {
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomRight: CGPoint
        let bottomLeft: CGPoint

        var boundingBox: CGRect {
            let minX = min(topLeft.x, bottomLeft.x)
            let maxX = max(topRight.x, bottomRight.x)
            let minY = min(topLeft.y, topRight.y)
            let maxY = max(bottomLeft.y, bottomRight.y)
            return CGRect(x: minX, y: minY,
                          width: maxX - minX,
                          height: maxY - minY)
        }
    }
}

extension RecognizedText: Hashable {
    public static func == (lhs: RecognizedText, rhs: RecognizedText) -> Bool {
        return lhs.text == rhs.text &&
        lhs.bounds.topLeft == rhs.bounds.topLeft &&
        lhs.bounds.topRight == rhs.bounds.topRight &&
        lhs.bounds.bottomLeft == rhs.bounds.bottomLeft &&
        lhs.bounds.bottomRight == rhs.bounds.bottomRight
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(bounds.topLeft.x)
        hasher.combine(bounds.topLeft.y)
        hasher.combine(bounds.topRight.x)
        hasher.combine(bounds.topRight.y)
        hasher.combine(bounds.bottomRight.x)
        hasher.combine(bounds.bottomRight.y)
        hasher.combine(bounds.bottomLeft.x)
        hasher.combine(bounds.bottomLeft.y)
    }
}
