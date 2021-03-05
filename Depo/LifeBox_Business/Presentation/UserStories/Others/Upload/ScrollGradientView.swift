//
//  ScrollGradientView.swift
//  Depo
//
//  Created by Konstantin Studilin on 05.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class ScrollGradientView: UIView {
    private lazy var gradientLayer: CAGradientLayer = {
       let layer = CAGradientLayer()
        let startColor = UIColor.black.withAlphaComponent(0.5).cgColor
        let endColor = UIColor.white.withAlphaComponent(0.5).cgColor
        layer.colors = [startColor, endColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = layer.frame
    }
    
    func addGradientLayer() {
        layer.addSublayer(gradientLayer)
    }
}
