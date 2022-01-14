//
//  TextBounds.swift
//  Depo
//
//  Created by Hady on 1/13/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

public struct TextBounds {
    public let topLeft: CGPoint
    public let topRight: CGPoint
    public let bottomRight: CGPoint
    public let bottomLeft: CGPoint

    public var boundingBox: CGRect {
        let minX = min(topLeft.x, bottomLeft.x)
        let maxX = max(topRight.x, bottomRight.x)
        let minY = min(topLeft.y, topRight.y)
        let maxY = max(bottomLeft.y, bottomRight.y)
        return CGRect(x: minX, y: minY,
                      width: maxX - minX,
                      height: maxY - minY)
    }

    public var midLeft: CGPoint {
        CGPoint(x: (topLeft.x + bottomLeft.x) / 2, y: (topLeft.y + bottomLeft.y) / 2)
    }

    public var midRight: CGPoint {
        CGPoint(x: (topRight.x + topRight.x) / 2, y: (topRight.y + bottomRight.y) / 2)
    }
}

extension TextBounds: Hashable {
    public static func == (lhs: TextBounds, rhs: TextBounds) -> Bool {
        return lhs.topLeft == rhs.topLeft &&
        lhs.topRight == rhs.topRight &&
        lhs.bottomLeft == rhs.bottomLeft &&
        lhs.bottomRight == rhs.bottomRight
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(topLeft.x)
        hasher.combine(topLeft.y)
        hasher.combine(topRight.x)
        hasher.combine(topRight.y)
        hasher.combine(bottomRight.x)
        hasher.combine(bottomRight.y)
        hasher.combine(bottomLeft.x)
        hasher.combine(bottomLeft.y)
    }
}

