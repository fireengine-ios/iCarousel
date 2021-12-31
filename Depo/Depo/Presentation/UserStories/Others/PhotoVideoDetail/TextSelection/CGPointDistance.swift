//
//  CGPointDistance.swift
//  TextSelection
//
//  Created by Hady on 12/8/21.
//

import CoreGraphics

func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

//TODO: performance concern. Calculating square roots is not fast
func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt(CGPointDistanceSquared(from: from, to: to))
}
