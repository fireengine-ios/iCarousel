//
//  UIButton+Animate.swift
//  Depo_LifeTech
//
//  Created by Timafei Harhun on 11/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIButton {
    
    func addSelectedAnimation() {
        let selectedAnimation = CASpringAnimation(keyPath: "transform.scale")
        selectedAnimation.duration = NumericConstants.animationDuration
        selectedAnimation.fromValue = NumericConstants.defaultScaleForPremiumButton
        selectedAnimation.toValue = NumericConstants.scaleForPremiumButton
        selectedAnimation.repeatCount = NumericConstants.repeatCountForPremiumButton
        selectedAnimation.autoreverses = true
        
        let animationGroup = CAAnimationGroup()
        animationGroup.beginTime = CACurrentMediaTime() + NumericConstants.delayForStartAnimation
        animationGroup.duration = NumericConstants.durationBetweenAnimation
        animationGroup.repeatCount = NumericConstants.repeatCountForAnimation
        animationGroup.animations = [selectedAnimation]
        
        layer.add(animationGroup, forKey: "selectedAnimation")
    }
    
}
