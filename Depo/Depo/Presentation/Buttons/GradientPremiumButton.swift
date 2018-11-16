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
    
    // MARK: Utility methods
    private func setup() {
        layer.masksToBounds = true
        setupDesign()
        
        addGradient()
    }
    
    private func setupDesign() {
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .selected)
        
        titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
    }
    
    private func addGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        
        gradientLayer.colors = [ColorConstants.lrTiffanyBlueGradient.cgColor,
                                ColorConstants.orangeGradient.cgColor,
                                UIColor.lrTealishTwo.withAlphaComponent(NumericConstants.alphaForColorsPremiumButton).cgColor,]
        gradientLayer.startPoint = GradientPoint.start
        gradientLayer.endPoint = GradientPoint.end
        gradientLayer.isOpaque = true
        gradientLayer.shouldRasterize = true
        gradientLayer.rasterizationScale = UIScreen.main.scale
    }
}
