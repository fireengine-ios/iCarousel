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
        backgroundColor = UIColor.white
        layer.shadowColor = shadowColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset ?? .zero
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func addGradient(firstColor : CGColor, secondColor: CGColor, startPoint: CGPoint, endPoint: CGPoint) {
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [firstColor, secondColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint

        self.layer.insertSublayer(gradient, at: 0)
        
    }
    
}
