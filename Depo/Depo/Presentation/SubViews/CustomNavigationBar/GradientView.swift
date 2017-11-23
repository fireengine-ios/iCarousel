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
    
    func setup(withFrame newFrame: CGRect, startColor: UIColor, endColoer: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
        
        frame = newFrame
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColoer.cgColor]
        //        gl.locations = [0.5, 0.45]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.addSublayer(gradientLayer)
    }
    
//    func fillFully(view: UIView, startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
//        translatesAutoresizingMaskIntoConstraints = false
////        let horisontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[item1]-(0)-|",
////                                                                   options: [], metrics: nil,
////                                                                   views: ["item1" : self])
////        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[item1]-(0)-|",
////                                                                 options: [], metrics: nil,
////                                                                 views: ["item1" : self])
//    
////        view.addConstraints(horisontalConstraints + verticalConstraints)
//        
//        setup(withFrame: bounds, startColor: startColor, endColoer: endColor, startPoint: startPoint, endPoint: endPoint)
//    }
}
