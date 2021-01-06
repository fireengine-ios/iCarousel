//
//  UIview.swift
//  Depo
//
//  Created by Alexander Gurin on 7/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeImage(rect: CGSize) -> UIImage? {
        
//        let scaleByWidh = (size.width >= size.height)
//        var scaled = CGSize(width: 0, height: 0)
//        var scale: CGFloat = 1.0
//        if scaleByWidh {
//            scale = CGFloat(size.width / rect.width)
//        } else {
//            scale = CGFloat(size.height / rect.height)
//        }
//
//        scaled.height = size.height / scale
//        scaled.width  = size.width / scale
//
//        let y = (rect.height - scaled.height) / 2.0
//        let x = (rect.width - scaled.width) / 2.0
//        let drawRect = CGRect(x: x, y: y,
//                                        width: scaled.width,
//                                        height:scaled.height)
        
        let drawRect = CGRect(x: 0, y: 0,
                              width: rect.width,
                              height: rect.height)
        
        UIGraphicsBeginImageContext(rect)
        draw(in: drawRect)
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg
    }
}

extension UIImageView {
    
    func addGradientLayer(colors: [UIColor]) -> CALayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors.map { $0.cgColor }
        layer.addSublayer(gradient)
        return gradient
    }
    
}
