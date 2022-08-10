//
//  Gradient.swift
//  Depo
//
//  Created by Hooman Seven on 08/8/2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
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
