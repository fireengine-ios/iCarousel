//
//  UIView+Extensions.swift
//  Depo
//
//  Created by Burak Donat on 2.06.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addRoundedShadows(cornerRadius: CGFloat,
                           shadowColor: CGColor,
                           opacity: Float,
                           radius: CGFloat,
                           offset: CGSize? = .zero) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true;
        layer.shadowColor = shadowColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset ?? .zero
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func addGradient(firstColor : CGColor, secondColor: CGColor, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil) {
        self.layer.sublayers = self.layer.sublayers?.filter { theLayer in
            !theLayer.isKind(of: CAGradientLayer.classForCoder())
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [firstColor, secondColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = startPoint ?? CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = endPoint ??  CGPoint(x: 0.5, y: 1.0)
        self.layer.insertSublayer(gradient, at: 0)
        
    }
    
}
