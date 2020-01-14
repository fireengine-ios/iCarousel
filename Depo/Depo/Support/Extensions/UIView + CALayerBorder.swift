//
//  UIView + CALayerBorder.swift
//  Depo
//
//  Created by Maxim Soldatov on 1/14/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

public extension UIView {
    
    enum ViewSide {
        case top
        case right
        case bottom
        case left
    }
    
    func addBorder(side: ViewSide, thickness: CGFloat, color: UIColor, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {
        
        switch side {
        case .top:

            let border: CALayer = getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                             y: 0 + topOffset,
                                             width: self.frame.size.width - leftOffset - rightOffset,
                                             height: thickness), color: color)
            self.layer.addSublayer(border)
        case .right:

            let border: CALayer = getOneSidedBorder(frame: CGRect(x: self.frame.size.width-thickness-rightOffset,
                                             y: 0 + topOffset, width: thickness,
                                             height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        case .bottom:

            let border: CALayer = getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                             y: self.frame.size.height-thickness-bottomOffset,
                                             width: self.frame.size.width - leftOffset - rightOffset, height: thickness), color: color)
            self.layer.addSublayer(border)
        case .left:
            let border: CALayer = getOneSidedBorder(frame: CGRect(x: 0 + leftOffset,
                                             y: 0 + topOffset,
                                             width: thickness,
                                             height: self.frame.size.height - topOffset - bottomOffset), color: color)
            self.layer.addSublayer(border)
        }
    }
    


    private func getOneSidedBorder(frame: CGRect, color: UIColor) -> CALayer {
        let border:CALayer = CALayer()
        border.frame = frame
        border.backgroundColor = color.cgColor
        return border
    }
    
}
