//
//  UIView+Rorate.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIView {
    func infinityRotate360Degrees(duration: CFTimeInterval = 2.0) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.greatestFiniteMagnitude;
        layer.add(rotateAnimation, forKey: nil)
    }
}
