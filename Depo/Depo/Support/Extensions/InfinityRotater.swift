//
//  UIView+Rorate.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

private let infinityRotate360DegreesKey = "InfinityRotate360Degrees"

protocol InfinityRotater {
    func startInfinityRotate360Degrees(duration: CFTimeInterval)
    func stopInfinityRotate360Degrees()
}
extension InfinityRotater where Self: UIView {
    
    func startInfinityRotate360Degrees(duration: CFTimeInterval) {
        guard layer.animation(forKey: infinityRotate360DegreesKey) == nil else {
            print("⚠️ startInfinityRotate360Degrees called before stop ⚠️")
            return
        }
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = Double.pi * 2.0
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = .infinity
        layer.add(rotateAnimation, forKey: infinityRotate360DegreesKey)
    }
    
    func stopInfinityRotate360Degrees() {
        layer.removeAnimation(forKey: infinityRotate360DegreesKey)
    }
}

final class RotatingImageView: UIImageView, InfinityRotater {}
