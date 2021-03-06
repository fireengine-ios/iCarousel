//
//  ScrollGradientView.swift
//  Depo
//
//  Created by Konstantin Studilin on 05.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ScrollGradientView: UIView {
    private lazy var gradientLayer: CAGradientLayer = {
       let layer = CAGradientLayer()
        let topColor = UIColor.white.withAlphaComponent(0.05).darker(by: 30).cgColor
        let middleColor = UIColor.white.withAlphaComponent(0.05).darker(by: 10).cgColor
        let bottomColor = UIColor.white.withAlphaComponent(0.6).cgColor
        layer.colors = [topColor, middleColor, bottomColor]
        layer.locations = [0, 0.5, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
    
    //MARK: - Public
    
    func addGradientLayer() {
        layer.addSublayer(gradientLayer)
    }
    
    func showAnimated() {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.isHidden = false
            self.layoutSubviews()
        }
    }
    
    func hideAnimated() {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.isHidden = true
            self.layoutSubviews()
        }
    }
    
}
