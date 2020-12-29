//
//  ShadowView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 24.10.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    func addShadowView() {
        if (self.layer.sublayers != nil) {
            for l in self.layer.sublayers! {
                l.removeFromSuperlayer()
            }
        }
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0,
                             y: 0,
                             width: frame.size.width,
                             height: frame.size.height)
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: layer.frame.size.width, height: layer.frame.size.height)).cgPath
        layer.shouldRasterize = true
        layer.cornerRadius = 5
        
        self.layer.addSublayer(layer)
    }
    
}
