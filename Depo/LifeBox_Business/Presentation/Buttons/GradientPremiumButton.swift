//
//  GradientPremiumButton.swift
//  Depo_LifeTech
//
//  Created by Timafei Harhun on 11/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

private enum GradientPoint {
    static var start: CGPoint = CGPoint(x: 1.0, y: 0.5)
    static var end: CGPoint = CGPoint(x: 0.0, y: 0.5)
}

final class GradientPremiumButton: UIButton {

    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        return CGSize(width: size.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      height: size.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom)
    }
    
    func addSelectedAnimation() {
        addAnimation()
    }
    
    func addSingleSelectedAnimation() {
        addSingleAnimation()
    }
    
    // MARK: Utility methods
    private func setup() {
        layer.masksToBounds = true
        setupDesign()

        addGradient()
    }
    
    private func setupDesign() {
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .selected)
        
        titleLabel?.adjustsFontSizeToFitWidth()
        setDefaultTitleEdgeInsets()
    }
    
    private func setDefaultTitleEdgeInsets() {
        titleEdgeInsets = UIEdgeInsetsMake(6, 14, 6, 14)
    }
    
    private func addGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        
        gradientLayer.colors = [ColorConstants.lrTiffanyBlueGradient.color.cgColor,
                                ColorConstants.orangeGradient.color.cgColor,
                                UIColor.lrTealishTwo.withAlphaComponent(NumericConstants.alphaForColorsPremiumButton).cgColor,]
        gradientLayer.startPoint = GradientPoint.start
        gradientLayer.endPoint = GradientPoint.end
        gradientLayer.isOpaque = true
        gradientLayer.shouldRasterize = true
        gradientLayer.rasterizationScale = UIScreen.main.scale
    }
    
    private func addAnimation() {
        layer.removeAllAnimations()
        let selectedAnimation = CASpringAnimation(keyPath: "transform.scale")
        selectedAnimation.speed = NumericConstants.speedForAnimation
        selectedAnimation.duration = NumericConstants.durationAnimationForPremiumButton
        selectedAnimation.fromValue = NumericConstants.defaultScaleForPremiumButton
        selectedAnimation.toValue = NumericConstants.scaleForPremiumButton
        selectedAnimation.autoreverses = true
        selectedAnimation.repeatCount = NumericConstants.repeatCountForPremiumButton
        selectedAnimation.initialVelocity = NumericConstants.initialVelocityForAnimation
        selectedAnimation.damping = NumericConstants.dampingForAnimation
        
        let animationGroup = CAAnimationGroup()
        animationGroup.beginTime = CACurrentMediaTime() + NumericConstants.delayForStartAnimation
        animationGroup.duration = NumericConstants.durationBetweenAnimation
        animationGroup.repeatCount = NumericConstants.repeatCountForAnimation
        animationGroup.animations = [selectedAnimation]

        layer.add(animationGroup, forKey: "selectedAnimation")
    }
    
    private func addSingleAnimation() {
        layer.removeAllAnimations()
        let selectedAnimation = CASpringAnimation(keyPath: "transform.scale")
        selectedAnimation.speed = NumericConstants.speedForAnimation
        selectedAnimation.duration = NumericConstants.durationAnimationForPremiumButton
        selectedAnimation.fromValue = NumericConstants.defaultScaleForPremiumButton
        selectedAnimation.toValue = NumericConstants.scaleForPremiumButton
        selectedAnimation.autoreverses = true
        selectedAnimation.initialVelocity = NumericConstants.initialVelocityForAnimation
        selectedAnimation.damping = NumericConstants.dampingForAnimation
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = NumericConstants.durationBetweenAnimation
        animationGroup.animations = [selectedAnimation]
        
        layer.add(animationGroup, forKey: "selectedAnimation")
    }
}
