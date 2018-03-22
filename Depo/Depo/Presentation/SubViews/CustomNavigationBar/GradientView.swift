//
//  GradientView.swift
//  Depo
//
//  Created by Aleksandr on 6/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

//@IBDesignable
class GradientView: UIView {
    
    let gradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CALayer.performWithoutAnimation {
            self.gradientLayer.frame = bounds
        }
    }
    
    func update(withFrame newFrame: CGRect, startColor: UIColor, endColoer: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
        
        frame = newFrame
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColoer.cgColor]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
    
    func setup(withFrame newFrame: CGRect, startColor: UIColor, endColoer: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
        
        frame = newFrame
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColoer.cgColor]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.addSublayer(gradientLayer)
    }
}
